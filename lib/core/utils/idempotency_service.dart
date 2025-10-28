/// Idempotency Service - 공용 중복 방지 시스템
///
/// **Firebase-Centric Architecture v1.0 - Idempotency Pattern**:
/// - eventId 기반 중복 제출 방지
/// - Network retry와 실제 중복 구분
/// - Transaction 내부에서 사용
///
/// **사용 Feature**: voting, creation, chat
///
/// **적용 사례**:
/// - Voting: 투표 중복 방지
/// - Creation: 좋아요/상호작용 중복 방지
/// - Chat: 메시지 중복 전송 방지
///
/// **예시**:
/// ```dart
/// final service = IdempotencyService();
/// final eventId = const Uuid().v4(); // 클라이언트 생성
///
/// await service.executeIdempotent<void>(
///   entityType: 'votes',
///   entityId: postId,
///   userId: userId,
///   eventId: eventId,
///   operation: (transaction) async {
///     // 실제 작업 수행
///   },
/// );
/// ```

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class IdempotencyService {
  final FirebaseFirestore _firestore;

  IdempotencyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Idempotent 작업 실행
  ///
  /// [entityType]: 엔티티 타입 (예: 'votes', 'interactions', 'messages')
  /// [entityId]: 엔티티 ID (예: postId, messageId)
  /// [userId]: 사용자 ID
  /// [eventId]: 클라이언트 생성 고유 ID (UUID v4)
  /// [operation]: 실제 실행할 작업 (Transaction 내부)
  ///
  /// **예외**:
  /// - [IdempotencyViolation]: 동일 사용자가 다른 eventId로 재시도 (실제 중복)
  ///
  /// **성공 케이스**:
  /// - 첫 실행: 작업 실행 + eventId 기록
  /// - 재시도(동일 eventId): 작업 스킵, 에러 없음 (✅ OK)
  Future<T> executeIdempotent<T>({
    required String entityType,
    required String entityId,
    required String userId,
    required String? eventId,
    required Future<T> Function(Transaction transaction) operation,
  }) async {
    if (eventId == null || eventId.isEmpty) {
      throw ArgumentError('eventId는 필수입니다 (UUID v4 권장)');
    }

    return _firestore.runTransaction<T>((transaction) async {
      // Idempotency 체크용 문서 참조
      final idempotencyRef = _firestore
          .collection('idempotency')
          .doc('${entityType}_${entityId}_$userId');

      final existingDoc = await transaction.get(idempotencyRef);

      if (existingDoc.exists) {
        final prevEventId = existingDoc.data()?['eventId'];

        // 동일 eventId: 재전송 (네트워크 재시도)
        if (prevEventId == eventId) {
          if (kDebugMode) {
            print(
                '[Idempotency] ✅ 재전송 감지 (eventId: $eventId) - 정상 스킵');
          }
          // 이전 결과 반환 또는 기본값
          // Note: T가 void인 경우를 위해 null을 반환하고 캐스팅
          return null as T;
        }

        // 다른 eventId: 실제 중복 시도
        throw IdempotencyViolation(
          'User $userId already performed action on $entityType/$entityId '
          '(previous eventId: $prevEventId, current: $eventId)',
        );
      }

      // 첫 실행: 작업 수행
      if (kDebugMode) {
        print('[Idempotency] ✨ 첫 실행 (eventId: $eventId)');
      }

      final result = await operation(transaction);

      // Idempotency 기록 저장
      transaction.set(idempotencyRef, {
        'entityType': entityType,
        'entityId': entityId,
        'userId': userId,
        'eventId': eventId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return result;
    });
  }

  /// Idempotency 기록 정리 (옵션)
  ///
  /// **사용 시점**:
  /// - 투표 완료 후 (voteCompleted = true)
  /// - 메시지 전송 성공 후 24시간 뒤
  /// - Cloud Function으로 자동 정리 권장
  Future<void> cleanupIdempotency({
    required String entityType,
    required String entityId,
    required String userId,
  }) async {
    final docId = '${entityType}_${entityId}_$userId';
    await _firestore.collection('idempotency').doc(docId).delete();

    if (kDebugMode) {
      print('[Idempotency] 🧹 정리 완료: $docId');
    }
  }
}

/// Idempotency 위반 예외
///
/// 동일 사용자가 다른 eventId로 동일 작업을 시도할 때 발생합니다.
/// 이는 실제 중복 시도를 의미하며, 클라이언트에서 명시적으로 처리해야 합니다.
class IdempotencyViolation implements Exception {
  final String message;

  IdempotencyViolation(this.message);

  @override
  String toString() => 'IdempotencyViolation: $message';
}
