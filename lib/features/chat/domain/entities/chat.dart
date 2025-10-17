import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Pure Domain Entity for Chat
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - 순수 Dart 타입만 사용 (Firestore 의존성 제거)
/// - 불변 객체 (Freezed)
/// - 비즈니스 로직에 집중
///
/// **DTO와의 차이**:
/// - DTO: Firestore ↔ Data 변환 (Infrastructure)
/// - Entity: 비즈니스 로직 (Domain)
///
/// **설계 원칙**:
/// - Single Responsibility: 채팅방 데이터 표현
/// - Value Objects: 모든 필드 불변
/// - No Infrastructure: Firestore 타입 없음
@freezed
sealed class Chat with _$Chat {
  const Chat._();

  const factory Chat({
    /// 채팅방 고유 ID
    required String id,

    /// 채팅방 식별자
    required String chatId,

    /// 채팅방 타입 (1:1, group 등)
    required String chatType,

    /// 참여자 ID 목록
    required List<String> participantIds,

    /// 채팅방 이름
    required String chatName,

    /// 마지막 메시지 내용
    required String lastMessageContent,

    /// 마지막 메시지 시간
    DateTime? lastMessageAt,

    /// 읽음 여부
    required bool isRead,

    /// 생성 시간
    DateTime? createdAt,

    /// 사용자별 마지막 읽은 시간
    required Map<String, DateTime> lastReadTimestamps,

    // ========== TODO: Profile Feature로 이동 예정 ==========
    // 현재는 DTO 호환성을 위해 유지
    // Phase 4에서 제거 예정

    /// 사용자 이메일 (TODO: Profile feature로 이동)
    @Default('') String email,

    /// 사용자 표시 이름 (TODO: Profile feature로 이동)
    @Default('') String displayName,

    /// 사용자 프로필 사진 URL (TODO: Profile feature로 이동)
    @Default('') String photoUrl,

    /// 사용자 UID (TODO: Profile feature로 이동)
    @Default('') String uid,

    /// 사용자 생성 시간 (TODO: Profile feature로 이동)
    DateTime? createdTime,

    /// 전화번호 (TODO: Profile feature로 이동)
    @Default('') String phoneNumber,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  // ========== Business Logic Methods ==========

  /// 특정 사용자의 마지막 읽은 시간 조회
  DateTime? getLastReadFor(String userId) {
    return lastReadTimestamps[userId];
  }

  /// 특정 사용자가 채팅방 참여자인지 확인
  bool hasParticipant(String userId) {
    return participantIds.contains(userId);
  }

  /// 채팅방에 읽지 않은 메시지가 있는지 확인
  bool hasUnreadMessages(String userId) {
    final lastRead = getLastReadFor(userId);
    if (lastRead == null || lastMessageAt == null) return true;
    return lastMessageAt!.isAfter(lastRead);
  }

  /// 1:1 채팅방 여부
  bool get isDirectChat => chatType == '1:1' || chatType == 'direct';

  /// 그룹 채팅방 여부
  bool get isGroupChat => chatType == 'group';

  /// 채팅방 참여자 수
  int get participantCount => participantIds.length;

  /// 채팅방이 활성화 상태인지 (메시지가 1개 이상)
  bool get isActive => lastMessageContent.isNotEmpty;

  /// 상대방 ID 조회 (1:1 채팅방 전용)
  ///
  /// **사용 조건**: 1:1 채팅방이고, 현재 사용자 ID를 알아야 함
  String? getOtherUserId(String currentUserId) {
    if (!isDirectChat || participantCount != 2) return null;
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// 채팅방 표시 이름 (그룹: chatName, 1:1: 상대방 이름)
  String getDisplayName(String currentUserId) {
    if (isGroupChat) return chatName;
    // 1:1 채팅: displayName 사용 (TODO: Profile feature 통합 후 개선)
    return displayName.isNotEmpty ? displayName : '알 수 없음';
  }

  /// 채팅방 복사 (일부 필드 변경)
  ///
  /// **Note**: Freezed의 copyWith는 자동 생성됨
  /// 여기서는 비즈니스 로직 관련 복사만 정의
}
