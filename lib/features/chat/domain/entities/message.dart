import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Pure Domain Entity for Message
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - 순수 Dart 타입만 사용 (Firestore 의존성 제거)
/// - 불변 객체 (Freezed)
/// - 비즈니스 로직에 집중
///
/// **메시지 타입**:
/// - text: 일반 텍스트 메시지
/// - image: 이미지 메시지
/// - video: 비디오 메시지
/// - vote_request: 투표 요청 카드
///
/// **DTO와의 차이**:
/// - DTO: Firestore ↔ Data 변환 (Infrastructure)
/// - Entity: 비즈니스 로직 (Domain)
@freezed
class Message with _$Message {
  const Message._();

  const factory Message({
    // ========== Basic Message Fields ==========
    /// 메시지 고유 ID
    required String id,

    /// 부모 채팅방 경로
    required String parentPath,

    /// 메시지 ID (messageId 필드)
    required String messageId,

    /// 발신자 ID
    required String senderId,

    /// 메시지 내용
    required String content,

    /// 첨부 파일 URL
    @Default('') String attachmentUrl,

    /// 첨부 파일 타입
    @Default('') String attachmentType,

    /// 메시지 생성 시간
    DateTime? timeStamp,

    /// 읽음 여부
    required bool isRead,

    /// 메시지 타입 (text, image, video, vote_request)
    @Default('text') String messageType,

    // ========== Media Fields ==========
    /// 미디어 타입 (text, image, video)
    @Default('text') String mediaType,

    /// 이미지 URL
    @Default('') String imageUrl,

    /// 비디오 URL
    @Default('') String videoUrl,

    /// 썸네일 URL
    @Default('') String thumbnailUrl,

    /// 미디어 크기 (bytes)
    @Default(0) int mediaSize,

    /// 미디어 너비
    double? mediaWidth,

    /// 미디어 높이
    double? mediaHeight,

    // ========== Message Lifecycle ==========
    /// 서버에 전달된 시간
    DateTime? deliveredAt,

    /// 수신자가 본 시간
    DateTime? seenAt,

    // ========== Vote Card Fields ==========
    /// 투표 요청을 받는 사용자 ID
    @Default('') String receiverId,

    /// 연결된 게시물 ID
    @Default('') String votePostId,

    /// 투표 제목
    @Default('') String voteTitle,

    /// 투표 설명
    @Default('') String voteDescription,

    /// 옵션 A 텍스트
    @Default('') String voteOptionAText,

    /// 옵션 B 텍스트
    @Default('') String voteOptionBText,

    /// 옵션 A 단일 이미지 (legacy)
    @Default('') String voteOptionAImage,

    /// 옵션 B 단일 이미지 (legacy)
    @Default('') String voteOptionBImage,

    /// 옵션 A 이미지 목록
    @Default([]) List<String> voteOptionAImages,

    /// 옵션 B 이미지 목록
    @Default([]) List<String> voteOptionBImages,

    /// 투표 상태 (pending, completed, expired)
    @Default('pending') String voteStatus,

    /// 투표 카드 상태
    @Default('') String cardStatus,

    /// 투표 종료 시간
    DateTime? voteEndTime,

    /// 투표 결과 (legacy - Map<String, dynamic>)
    @Default({}) Map<String, dynamic> voteResults,

    /// 사용자별 투표 정보 (userId → {option: 'A'/'B', votedAt: DateTime})
    @Default({}) Map<String, dynamic> userVotes,

    /// 옵션 A 이미지 비율
    double? voteAspectRatioA,

    /// 옵션 B 이미지 비율
    double? voteAspectRatioB,

    /// 옵션 A 투표 수
    @Default(0) int voteResultsA,

    /// 옵션 B 투표 수
    @Default(0) int voteResultsB,

    /// 옵션 A 투표 비율 (%)
    @Default(0.0) double votePercentA,

    /// 옵션 B 투표 비율 (%)
    @Default(0.0) double votePercentB,

    // ========== Metadata ==========
    /// 추가 메타데이터
    @Default({}) Map<String, dynamic> metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  // ========== Business Logic Methods ==========

  // ----- Message Type Checks -----

  /// 텍스트 메시지 여부
  bool get isTextMessage => messageType == 'text';

  /// 이미지 메시지 여부
  bool get isImageMessage => messageType == 'image' || mediaType == 'image';

  /// 비디오 메시지 여부
  bool get isVideoMessage => messageType == 'video' || mediaType == 'video';

  /// 투표 요청 메시지 여부
  bool get isVoteRequest => messageType == 'vote_request';

  /// 미디어 메시지 여부 (이미지 또는 비디오)
  bool get hasMedia => isImageMessage || isVideoMessage;

  // ----- Message Lifecycle -----

  /// 메시지가 전송됨 (delivered)
  bool get isDelivered => deliveredAt != null;

  /// 메시지가 읽힘 (seen)
  bool get isSeen => seenAt != null;

  /// 메시지 상태 (sent, delivered, seen)
  String get deliveryStatus {
    if (isSeen) return 'seen';
    if (isDelivered) return 'delivered';
    return 'sent';
  }

  // ----- Vote Logic -----

  /// 투표가 진행 중인지
  bool get isVotePending => voteStatus == 'pending';

  /// 투표가 완료되었는지
  bool get isVoteCompleted => voteStatus == 'completed';

  /// 투표가 만료되었는지
  bool get isVoteExpired => voteStatus == 'expired';

  /// 투표가 종료되었는지 (완료 또는 만료)
  bool get isVoteEnded => isVoteCompleted || isVoteExpired;

  /// 투표 종료까지 남은 시간 (초)
  int? get voteRemainingSeconds {
    if (voteEndTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(voteEndTime!)) return 0;
    return voteEndTime!.difference(now).inSeconds;
  }

  /// 투표 참여자 수
  int get voteParticipantCount => userVotes.length;

  /// 총 투표 수
  int get totalVoteCount => voteResultsA + voteResultsB;

  /// 투표 승자 ('A', 'B', 'tie', null)
  String? get voteWinner {
    if (!isVoteCompleted || totalVoteCount == 0) return null;
    if (voteResultsA > voteResultsB) return 'A';
    if (voteResultsB > voteResultsA) return 'B';
    return 'tie';
  }

  // ----- User Vote Helpers -----

  /// 특정 사용자의 투표 정보 가져오기
  Map<String, dynamic>? getUserVote(String userId) {
    return userVotes[userId] as Map<String, dynamic>?;
  }

  /// 특정 사용자가 투표했는지 확인
  bool hasUserVoted(String userId) {
    return userVotes.containsKey(userId);
  }

  /// 특정 사용자의 투표 선택 가져오기 ('A' 또는 'B')
  String? getUserVoteChoice(String userId) {
    final vote = getUserVote(userId);
    return vote?['option'] as String?;
  }

  /// 특정 사용자의 투표 시간 가져오기
  DateTime? getUserVoteTime(String userId) {
    final vote = getUserVote(userId);
    final timestamp = vote?['votedAt'];

    if (timestamp is DateTime) return timestamp;
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 특정 사용자가 옵션 A에 투표했는지
  bool hasUserVotedA(String userId) {
    return getUserVoteChoice(userId) == 'A';
  }

  /// 특정 사용자가 옵션 B에 투표했는지
  bool hasUserVotedB(String userId) {
    return getUserVoteChoice(userId) == 'B';
  }

  // ----- Media Helpers -----

  /// 미디어 가로세로 비율
  double? get mediaAspectRatio {
    if (mediaWidth == null || mediaHeight == null || mediaHeight == 0) {
      return null;
    }
    return mediaWidth! / mediaHeight!;
  }

  /// 미디어가 가로 방향인지
  bool get isMediaLandscape {
    final ratio = mediaAspectRatio;
    return ratio != null && ratio > 1.0;
  }

  /// 미디어가 세로 방향인지
  bool get isMediaPortrait {
    final ratio = mediaAspectRatio;
    return ratio != null && ratio < 1.0;
  }

  /// 미디어 파일 크기 (MB)
  double get mediaSizeInMB {
    return mediaSize / (1024 * 1024);
  }

  // ----- Content Helpers -----

  /// 메시지에 내용이 있는지
  bool get hasContent => content.isNotEmpty;

  /// 메시지에 첨부파일이 있는지
  bool get hasAttachment => attachmentUrl.isNotEmpty;

  /// 메시지 내용 미리보기 (최대 100자)
  String get contentPreview {
    if (isVoteRequest) return '📊 투표 요청: $voteTitle';
    if (isImageMessage) return '📷 이미지';
    if (isVideoMessage) return '🎥 비디오';
    if (content.isEmpty) return '(내용 없음)';
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  // ----- Vote Option Images -----

  /// 투표 옵션 A에 이미지가 있는지
  bool get hasVoteOptionAImages =>
      voteOptionAImages.isNotEmpty || voteOptionAImage.isNotEmpty;

  /// 투표 옵션 B에 이미지가 있는지
  bool get hasVoteOptionBImages =>
      voteOptionBImages.isNotEmpty || voteOptionBImage.isNotEmpty;

  /// 투표 옵션에 이미지가 있는지 (A 또는 B)
  bool get hasVoteImages => hasVoteOptionAImages || hasVoteOptionBImages;

  // ----- Parent Chat -----

  /// 부모 채팅방 ID 추출
  String get parentChatId {
    // parentPath 형식: "chats/chatId"
    final parts = parentPath.split('/');
    return parts.length >= 2 ? parts[1] : '';
  }
}
