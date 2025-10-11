/// 유효성 검사 규칙 및 정규식 상수
///
/// **Clean Architecture v4.0 준수**:
/// - 중앙 집중화된 유효성 검사 규칙
/// - 재사용 가능한 검증 로직
/// - 타입 안전한 정규식 패턴
class ValidationRules {
  ValidationRules._();

  // 정규식 패턴
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$', // E.164 format
  );

  static final RegExp displayNameRegex = RegExp(
    r'^[a-zA-Z0-9가-힣\s]{1,20}$', // 한글, 영문, 숫자, 공백만 허용
  );

  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  // 길이 제한
  static const int minDisplayNameLength = 1;
  static const int maxDisplayNameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxShortDescriptionLength = 100;
  static const int maxBioLength = 500;
  static const int maxInterestNameLength = 30;

  // 파일 크기 제한 (bytes)
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB

  // 지원되는 파일 형식
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'webm',
  ];

  // 유효성 검사 함수
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidDisplayName(String name) {
    return name.length >= minDisplayNameLength &&
        name.length <= maxDisplayNameLength &&
        displayNameRegex.hasMatch(name);
  }

  static bool isValidUrl(String url) {
    return urlRegex.hasMatch(url);
  }

  static bool isValidImageSize(int sizeBytes) {
    return sizeBytes > 0 && sizeBytes <= maxImageSizeBytes;
  }

  static bool isValidVideoSize(int sizeBytes) {
    return sizeBytes > 0 && sizeBytes <= maxVideoSizeBytes;
  }

  static bool isValidImageFormat(String extension) {
    return supportedImageFormats.contains(extension.toLowerCase());
  }

  static bool isValidVideoFormat(String extension) {
    return supportedVideoFormats.contains(extension.toLowerCase());
  }

  // 에러 메시지 생성
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length > maxDisplayNameLength) {
      return 'Display name must be $maxDisplayNameLength characters or less';
    }
    if (!displayNameRegex.hasMatch(value)) {
      return 'Display name can only contain letters, numbers, and spaces';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateShortDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Description is optional
    }
    if (value.length > maxShortDescriptionLength) {
      return 'Description must be $maxShortDescriptionLength characters or less';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    if (value.length > maxBioLength) {
      return 'Bio must be $maxBioLength characters or less';
    }
    return null;
  }
}
