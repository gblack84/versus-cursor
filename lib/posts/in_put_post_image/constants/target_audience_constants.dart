/// 타겟 오디언스 관련 상수들
class TargetAudienceConstants {
  // 수집 방식
  static const Map<String, CollectionTypeInfo> collectionTypes = {
    'quick': CollectionTypeInfo(
      id: 'quick',
      title: '빠른 수집',
      subtitle: 'AI가 최적의 타겟을 자동으로 선정합니다',
      icon: '🎯',
      description: '추천',
    ),
    'public': CollectionTypeInfo(
      id: 'public',
      title: '전체 공개',
      subtitle: '모든 사용자에게 무작위로 발송합니다',
      icon: '🌐',
      description: '',
    ),
    'custom': CollectionTypeInfo(
      id: 'custom',
      title: '맞춤 설정',
      subtitle: '세부 조건을 직접 설정할 수 있습니다',
      icon: '⚙️',
      description: '',
    ),
  };

  // 목표 응답 수 옵션
  static const List<int> targetCountOptions = [10, 50, 100, 500];
  
  // 관심사 목록
  static const List<String> interests = [
    '스포츠',
    '게임',
    '음악',
    '영화',
    '패션',
    '음식',
    '여행',
    '기술',
    '예술',
    '독서',
  ];

  // 연령대 옵션
  static const Map<String, String> ageGroups = {
    '전체': '전체',
    '10대': '10대',
    '20대': '20대',
    '30대': '30대',
    '40대': '40대',
    '50대 이상': '50대 이상',
  };

  // 성별 옵션
  static const Map<String, GenderInfo> genderOptions = {
    'all': GenderInfo(id: 'all', label: '전체'),
    'male': GenderInfo(id: 'male', label: '남성'),
    'female': GenderInfo(id: 'female', label: '여성'),
  };

  // 시간 제한 (초)
  static const int freeTimeLimit = 600;  // 10분
  static const int premiumTimeLimit = 300;  // 5분

  // UI 관련 상수
  static const double dialogWidth = 400.0;
  static const double dialogMaxHeight = 600.0;
  static const double stepIndicatorHeight = 60.0;
  static const double contentPadding = 24.0;
  static const double itemSpacing = 16.0;
  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;
}

/// 수집 방식 정보
class CollectionTypeInfo {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String description;

  const CollectionTypeInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });
}

/// 성별 정보
class GenderInfo {
  final String id;
  final String label;

  const GenderInfo({
    required this.id,
    required this.label,
  });
}