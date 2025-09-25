import 'package:equatable/equatable.dart';

/// Pure domain model for target audience configuration
/// 타겟 오디언스 설정을 위한 순수 도메인 모델
class TargetAudience extends Equatable {
  /// Collection type: 'quick', 'public', or 'custom'
  final String collectionType;

  /// Target response count
  final int targetCount;

  /// Premium user flag
  final bool isPremium;

  /// Selected interests for custom targeting
  final List<String> selectedInterests;

  /// Selected age group for custom targeting
  final String selectedAgeGroup;

  /// Selected gender for custom targeting: 'all', 'male', 'female'
  final String selectedGender;

  /// Active users only flag for custom targeting
  final bool activeUserOnly;

  /// Creation timestamp
  final DateTime createdAt;

  /// Current status: 'pending', 'active', 'completed'
  final String status;

  const TargetAudience({
    this.collectionType = 'quick',
    this.targetCount = 100,
    this.isPremium = false,
    this.selectedInterests = const [],
    this.selectedAgeGroup = '전체',
    this.selectedGender = 'all',
    this.activeUserOnly = true,
    required this.createdAt,
    this.status = 'pending',
  });

  /// Factory constructor for creating from map
  factory TargetAudience.fromMap(Map<String, dynamic> map) {
    return TargetAudience(
      collectionType: map['type'] ?? 'quick',
      targetCount: map['targetCount'] ?? 100,
      isPremium: map['isPremium'] ?? false,
      selectedInterests: map['criteria'] != null
          ? List<String>.from(map['criteria']['interests'] ?? [])
          : const [],
      selectedAgeGroup: _convertAgeGroupFromMap(map['criteria']),
      selectedGender: map['criteria'] != null
          ? map['criteria']['gender'] ?? 'all'
          : 'all',
      activeUserOnly: map['criteria'] != null
          ? map['criteria']['activeUserOnly'] ?? true
          : true,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  /// Convert to map for Firestore storage (Firebase Functions compatible)
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'type': collectionType,
      'targetCount': targetCount,
      'isPremium': isPremium,
      'createdAt': createdAt,
      'status': status,
    };

    // Add custom criteria if collection type is custom
    if (collectionType == 'custom') {
      data['criteria'] = {
        'interests': selectedInterests,
        'ageGroup': _convertAgeGroupToMap(selectedAgeGroup),
        'gender': selectedGender,
        'activeUserOnly': activeUserOnly,
      };
    }

    return data;
  }

  /// Create a copy with updated fields
  TargetAudience copyWith({
    String? collectionType,
    int? targetCount,
    bool? isPremium,
    List<String>? selectedInterests,
    String? selectedAgeGroup,
    String? selectedGender,
    bool? activeUserOnly,
    DateTime? createdAt,
    String? status,
  }) {
    return TargetAudience(
      collectionType: collectionType ?? this.collectionType,
      targetCount: targetCount ?? this.targetCount,
      isPremium: isPremium ?? this.isPremium,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedAgeGroup: selectedAgeGroup ?? this.selectedAgeGroup,
      selectedGender: selectedGender ?? this.selectedGender,
      activeUserOnly: activeUserOnly ?? this.activeUserOnly,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Check if custom criteria is valid
  bool get isCustomCriteriaValid {
    if (collectionType != 'custom') return true;

    // At least one criteria should be set for custom
    return selectedInterests.isNotEmpty ||
        selectedAgeGroup != '전체' ||
        selectedGender != 'all';
  }

  /// Calculate estimated completion time
  String get estimatedTime {
    if (isPremium) {
      return '약 3-5분';
    } else {
      if (targetCount <= 50) {
        return '약 5-10분';
      } else if (targetCount <= 100) {
        return '약 10-15분';
      } else {
        return '약 15-30분';
      }
    }
  }

  /// Convert age group from map (English to Korean)
  static String _convertAgeGroupFromMap(Map<String, dynamic>? criteria) {
    if (criteria == null) return '전체';

    final ageGroup = criteria['ageGroup'] ?? 'all';
    const ageMapping = {
      'all': '전체',
      '10s': '10대',
      '20s': '20대',
      '30s': '30대',
      '40s': '40대',
      '50s+': '50대 이상',
    };

    return ageMapping[ageGroup] ?? '전체';
  }

  /// Convert age group to map (Korean to English)
  static String _convertAgeGroupToMap(String ageGroup) {
    if (ageGroup == '전체') return 'all';

    const ageMapping = {
      '10대': '10s',
      '20대': '20s',
      '30대': '30s',
      '40대': '40s',
      '50대 이상': '50s+',
    };

    return ageMapping[ageGroup] ?? 'all';
  }

  @override
  List<Object?> get props => [
    collectionType,
    targetCount,
    isPremium,
    selectedInterests,
    selectedAgeGroup,
    selectedGender,
    activeUserOnly,
    createdAt,
    status,
  ];
}