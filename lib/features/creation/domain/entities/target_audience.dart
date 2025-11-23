import 'package:freezed_annotation/freezed_annotation.dart';

part 'target_audience.freezed.dart';
part 'target_audience.g.dart';

/// Pure domain model for target audience configuration
/// 타겟 오디언스 설정을 위한 순수 도메인 모델
///
/// **Freezed Migration**: Equatable에서 Freezed로 마이그레이션
/// - 불변성 자동 보장
/// - copyWith 자동 생성
/// - 복잡한 Firestore 매핑 로직 보존 (criteria 중첩, 나이 그룹 변환)
/// - 비즈니스 로직 getter 보존 (isCustomCriteriaValid, estimatedTime)
@freezed
sealed class TargetAudience with _$TargetAudience {
  const TargetAudience._();

  const factory TargetAudience({
    /// Collection type: 'quick', 'public', or 'custom'
    @Default('quick') String collectionType,

    /// Target response count
    @Default(100) int targetCount,

    /// Premium user flag
    @Default(false) bool isPremium,

    /// Selected interests for custom targeting
    @Default([]) List<String> selectedInterests,

    /// Selected age group for custom targeting (Korean format)
    @Default('전체') String selectedAgeGroup,

    /// Selected gender for custom targeting: 'all', 'male', 'female'
    @Default('all') String selectedGender,

    /// Active users only flag for custom targeting
    @Default(true) bool activeUserOnly,

    /// Creation timestamp
    required DateTime createdAt,

    /// Current status: 'pending', 'active', 'completed'
    @Default('pending') String status,
  }) = _TargetAudience;

  /// Freezed's fromJson for JSON deserialization
  /// Note: This handles simple JSON, complex Firestore logic is in fromMap
  factory TargetAudience.fromJson(Map<String, dynamic> json) =>
      _$TargetAudienceFromJson(json);

  /// Factory constructor for creating from Firestore map
  /// Handles complex Firebase structure with criteria nesting and age group conversion
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

  /// Factory constructor for creating from Provider's Map
  ///
  /// **Phase 5 Migration**: Moved from TargetAudienceDto
  /// Converts UI layer keys to Domain layer format
  /// - UI 'type' → Domain 'collectionType'
  /// - Handles criteria nesting
  /// - Age group conversion (English → Korean)
  factory TargetAudience.fromProviderMap(Map<String, dynamic> map) {
    return TargetAudience(
      collectionType:
          map['type'] as String, // UI 'type' → Domain 'collectionType'
      targetCount: map['targetCount'] as int? ?? 100,
      isPremium: map['isPremium'] as bool? ?? false,
      selectedInterests: map['criteria'] != null
          ? List<String>.from(map['criteria']['interests'] ?? [])
          : const [],
      selectedAgeGroup: _convertAgeGroupFromMap(map['criteria']),
      selectedGender: map['criteria'] != null
          ? map['criteria']['gender'] as String? ?? 'all'
          : 'all',
      activeUserOnly: map['criteria'] != null
          ? map['criteria']['activeUserOnly'] as bool? ?? true
          : true,
      createdAt: DateTime.now(), // Provider maps don't have createdAt
      status: 'pending', // New audience is always pending
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

  // ============================================
  // Business Logic (비즈니스 로직)
  // ============================================

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

  // ============================================
  // Age Group Conversion Helpers (Private)
  // Clean Architecture compliant - no Data layer dependency
  // ============================================

  /// Convert age group from map (Firebase English to Korean)
  ///
  /// Firebase → Domain
  /// - 'all' → '전체'
  /// - '10s' → '10대'
  /// - '20s' → '20대'
  /// - '30s' → '30대'
  /// - '40s' → '40대'
  /// - '50s+' → '50대 이상'
  static String _convertAgeGroupFromMap(Map<String, dynamic>? criteria) {
    if (criteria == null) return '전체';

    final ageGroup = criteria['ageGroup'];
    if (ageGroup == null) return '전체';

    // Inline conversion logic (moved from TargetAudienceMapper)
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

  /// Convert age group to map (Korean to Firebase English)
  ///
  /// Domain → Firebase
  /// - '전체' → 'all'
  /// - '10대' → '10s'
  /// - '20대' → '20s'
  /// - '30대' → '30s'
  /// - '40대' → '40s'
  /// - '50대 이상' → '50s+'
  static String _convertAgeGroupToMap(String ageGroup) {
    if (ageGroup == '전체') return 'all';

    // Inline conversion logic (moved from TargetAudienceMapper)
    const ageMapping = {
      '10대': '10s',
      '20대': '20s',
      '30대': '30s',
      '40대': '40s',
      '50대 이상': '50s+',
    };

    return ageMapping[ageGroup] ?? 'all';
  }
}
