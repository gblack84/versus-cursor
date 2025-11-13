/// Sharded Counter Utilities - 공용 샤드 시스템
///
/// **Firebase-Centric Architecture v1.0 - Sharded Counter Pattern**:
/// - FNV-1a 해시 기반 안정적인 샤드 분산
/// - 256개 샤드로 쓰기 부하 분산
/// - Cloud Function으로 자동 집계
///
/// **사용 Feature**: voting, creation
///
/// **Firestore 구조**:
/// ```
/// counters/
///   vote_{postId}/
///     shards/
///       shard_0 to shard_255
///   interaction_{postId}/
///     shards/
///       shard_0 to shard_255
/// ```
///
/// **예시**:
/// ```dart
/// final shardUtils = ShardUtils();
///
/// // Transaction 내부에서 사용
/// await firestore.runTransaction((transaction) async {
///   shardUtils.incrementShard(
///     transaction,
///     counterType: 'vote',
///     entityId: postId,
///     userId: userId,
///     field: 'votesA',
///   );
/// });
/// ```

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ShardUtils {
  /// 샤드 개수 (256개 고정)
  ///
  /// **근거**:
  /// - Firestore 문서당 최대 쓰기 속도: 1회/초
  /// - 256개 샤드: 256회/초 처리 가능
  /// - 10분 투표 타이머에서 최대 153,600명 동시 처리
  /// - 바이럴 대응: 충분한 확장성 확보
  static const int shardCount = 256;

  final FirebaseFirestore _firestore;

  ShardUtils({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// FNV-1a 해시 기반 안정적인 샤드 ID 계산
  ///
  /// **특징**:
  /// - 동일 userId는 항상 동일 샤드 (시간 무관)
  /// - 균등 분산 보장
  /// - 32bit 해시 사용
  ///
  /// **알고리즘**: FNV-1a (Fowler-Noll-Vo hash)
  /// - Offset basis: 2166136261
  /// - Prime: 16777619
  /// - Output: 0-255 범위
  static int stableShardId(String userId) {
    final bytes = utf8.encode(userId);
    var hash = 2166136261; // FNV-1a offset basis (32-bit)

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 16777619) & 0xFFFFFFFF; // FNV-1a prime
    }

    final shardId = hash % shardCount;

    if (kDebugMode) {
      print('[ShardUtils] userId: $userId → shard: $shardId');
    }

    return shardId;
  }

  /// 샤드 문서 참조 생성
  ///
  /// [counterType]: 카운터 타입 (예: 'vote', 'interaction')
  /// [entityId]: 엔티티 ID (예: postId)
  /// [userId]: 사용자 ID (샤드 결정용)
  ///
  /// **반환**: counters/{counterType}_{entityId}/shards/shard_{0-255}
  DocumentReference shardRef({
    required String counterType,
    required String entityId,
    required String userId,
  }) {
    final shardId = stableShardId(userId);
    return _firestore
        .collection('counters')
        .doc('${counterType}_$entityId')
        .collection('shards')
        .doc('shard_$shardId');
  }

  /// 샤드에 카운터 증가 (Transaction 내부 사용)
  ///
  /// [transaction]: Firestore Transaction
  /// [counterType]: 'vote' or 'interaction'
  /// [entityId]: postId
  /// [userId]: 사용자 ID
  /// [field]: 증가할 필드명 (예: 'votesA', 'likeCount')
  /// [incrementBy]: 증가량 (기본 1)
  ///
  /// **동작**:
  /// 1. userId → shardId 계산 (FNV-1a 해시)
  /// 2. counters/{counterType}_{entityId}/shards/shard_{shardId} 참조
  /// 3. FieldValue.increment()로 원자적 증가
  /// 4. Cloud Function이 자동으로 posts/{entityId}에 집계
  void incrementShard(
    Transaction transaction, {
    required String counterType,
    required String entityId,
    required String userId,
    required String field,
    int incrementBy = 1,
  }) {
    final ref = shardRef(
      counterType: counterType,
      entityId: entityId,
      userId: userId,
    );

    transaction.set(
      ref,
      {
        field: FieldValue.increment(incrementBy),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (kDebugMode) {
      print(
          '[ShardUtils] ✨ 샤드 증가: $counterType/$entityId/$field +$incrementBy');
    }
  }

  /// 모든 샤드 합계 계산 (읽기용)
  ///
  /// **주의**: 이 메서드는 비용이 많이 듭니다 (256개 문서 읽기)
  /// Cloud Function의 집계 결과를 사용하는 것을 권장합니다.
  ///
  /// **사용 시점**:
  /// - 디버깅
  /// - Cloud Function 배포 전 테스트
  /// - 실시간 집계 결과 검증
  ///
  /// **반환**: { 'votesA': 150, 'votesB': 120, 'totalVotes': 270 }
  Future<Map<String, int>> aggregateShards({
    required String counterType,
    required String entityId,
  }) async {
    final shards = await _firestore
        .collection('counters')
        .doc('${counterType}_$entityId')
        .collection('shards')
        .get();

    final Map<String, int> totals = {};

    for (final doc in shards.docs) {
      final data = doc.data();
      data.forEach((key, value) {
        if (value is int && key != 'lastUpdated') {
          totals[key] = (totals[key] ?? 0) + value;
        }
      });
    }

    if (kDebugMode) {
      print('[ShardUtils] 📊 집계 결과: $counterType/$entityId → $totals');
    }

    return totals;
  }

  /// 특정 샤드의 데이터 조회 (디버깅용)
  ///
  /// [counterType]: 'vote' or 'interaction'
  /// [entityId]: postId
  /// [userId]: 사용자 ID
  ///
  /// **반환**: { 'votesA': 5, 'votesB': 3, 'lastUpdated': Timestamp }
  Future<Map<String, dynamic>?> getShardData({
    required String counterType,
    required String entityId,
    required String userId,
  }) async {
    final ref = shardRef(
      counterType: counterType,
      entityId: entityId,
      userId: userId,
    );

    final doc = await ref.get();
    return doc.exists ? doc.data() as Map<String, dynamic>? : null;
  }

  /// 모든 샤드 삭제 (정리용)
  ///
  /// **사용 시점**:
  /// - 투표 완료 후 (선택적)
  /// - 게시물 삭제 시
  /// - Cloud Function으로 자동 정리 권장
  Future<void> deleteAllShards({
    required String counterType,
    required String entityId,
  }) async {
    final batch = _firestore.batch();
    final shards = await _firestore
        .collection('counters')
        .doc('${counterType}_$entityId')
        .collection('shards')
        .get();

    for (final doc in shards.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    if (kDebugMode) {
      print('[ShardUtils] 🧹 샤드 정리 완료: $counterType/$entityId');
    }
  }
}
