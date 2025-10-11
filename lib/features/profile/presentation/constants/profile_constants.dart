/// 프로필 기능 관련 상수
///
/// **Clean Architecture v4.0 준수**:
/// - 중앙 집중화된 상수 관리
/// - Magic numbers/strings 제거
/// - 타입 안전성 보장
class ProfileConstants {
  ProfileConstants._();

  // 프로필 제한
  static const int maxDisplayNameLength = 20;
  static const int maxShortDescriptionLength = 100;
  static const int maxBioLength = 500;

  // 관심사 제한
  static const int maxExpertiseCount = 4;
  static const int maxHobbiesCount = 8;
  static const int minInterestSelectionCount = 1;

  // 친구 제한
  static const int maxFriendsCount = 500;
  static const int friendRequestsPerPage = 20;

  // 포인트 시스템
  static const int defaultPointsA = 0;
  static const int defaultPointsQ = 0;
  static const int maxPointsDisplay = 999999;

  // 프로필 이미지
  static const int maxProfileImageSizeMB = 5;
  static const int maxProfileImageSizeBytes = maxProfileImageSizeMB * 1024 * 1024;
  static const double defaultAvatarRadius = 40.0;

  // 캐시 설정
  static const Duration profileCacheDuration = Duration(minutes: 5);
  static const Duration interestsCacheDuration = Duration(minutes: 10);

  // API 타임아웃
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // 언어 옵션
  static const List<String> supportedLanguages = [
    '한국어',
    'English',
    'Español',
    'Français',
    '日本語',
    '中文',
  ];

  // 성별 옵션
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
  ];
}
