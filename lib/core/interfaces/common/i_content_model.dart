/// 공통 컨텐츠 모델 인터페이스
/// 
/// Posts와 기타 컨텐츠 타입에서 공유하는 기본 속성들을 정의합니다.
/// Clean Architecture의 도메인 레이어에 위치하며, 
/// notifications 피처가 구체적인 Posts 모델에 의존하지 않도록 합니다.
abstract class IContentModel {
  /// 컨텐츠 고유 ID
  String get id;
  
  /// 컨텐츠 제목 또는 설명
  String get title;
  
  /// 컨텐츠 본문 또는 내용
  String get content;
  
  /// 컨텐츠 생성자 ID
  String get creatorId;
  
  /// 생성 날짜
  DateTime get createdAt;
  
  /// 컨텐츠 타입 (post, comment, etc.)
  ContentType get contentType;
  
  /// 컨텐츠가 활성화되어 있는지 여부
  bool get isActive;
  
  /// 컨텐츠가 공개되어 있는지 여부
  bool get isPublic;
  
  /// 메타데이터 (추가 정보)
  Map<String, dynamic>? get metadata;
}

/// 컨텐츠 타입 열거형
enum ContentType {
  post,
  comment,
  message,
  notification,
  other,
}

/// Versus 전용 컨텐츠 모델 인터페이스
/// 
/// A vs B 형태의 비교 컨텐츠를 위한 확장 인터페이스
abstract class IVersusContentModel extends IContentModel {
  /// A 옵션 제목
  String get optionATitle;
  
  /// B 옵션 제목  
  String get optionBTitle;
  
  /// A 옵션 이미지 URL 목록
  List<String> get optionAImageUrls;
  
  /// B 옵션 이미지 URL 목록
  List<String> get optionBImageUrls;
  
  /// A 옵션 투표 수
  int get votesA;
  
  /// B 옵션 투표 수
  int get votesB;
  
  /// 투표 시작 시간
  DateTime? get voteStartTime;
  
  /// 투표 종료 시간
  DateTime? get voteEndTime;
  
  /// 투표 상태
  VoteStatus get voteStatus;
  
  /// 레이아웃 타입 (horizontal, vertical, single)
  String? get layoutType;
  
  /// 타겟 오디언스 설정
  Map<String, dynamic>? get targetAudience;
}

/// 투표 상태 열거형
enum VoteStatus {
  pending,    // 투표 시작 전
  active,     // 투표 진행 중
  completed,  // 투표 완료
  expired,    // 투표 만료
}