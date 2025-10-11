/// PremiumUser pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createPremiumUsersModelData() 제거 → PremiumUserDto.toFirestore()로 이동
/// - PremiumUsersModelDocumentEquality 제거 → == operator 사용
///
/// Represents a premium user subscription status and features
class PremiumUser {
  // ============= Core Fields =============
  final String userId;
  final bool isPremium;
  final DateTime? premiumEndDate;
  final String premiumLevel;
  final DateTime? premiumStartDate;
  final List<String> availableFeatures;
  final int pointsBalance;
  final DateTime? lastUsedPremiumFeature;

  const PremiumUser({
    required this.userId,
    this.isPremium = false,
    this.premiumEndDate,
    this.premiumLevel = '',
    this.premiumStartDate,
    this.availableFeatures = const [],
    this.pointsBalance = 0,
    this.lastUsedPremiumFeature,
  });

  /// Create a copy of this PremiumUser with updated fields
  PremiumUser copyWith({
    String? userId,
    bool? isPremium,
    DateTime? premiumEndDate,
    String? premiumLevel,
    DateTime? premiumStartDate,
    List<String>? availableFeatures,
    int? pointsBalance,
    DateTime? lastUsedPremiumFeature,
  }) {
    return PremiumUser(
      userId: userId ?? this.userId,
      isPremium: isPremium ?? this.isPremium,
      premiumEndDate: premiumEndDate ?? this.premiumEndDate,
      premiumLevel: premiumLevel ?? this.premiumLevel,
      premiumStartDate: premiumStartDate ?? this.premiumStartDate,
      availableFeatures: availableFeatures ?? this.availableFeatures,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      lastUsedPremiumFeature:
          lastUsedPremiumFeature ?? this.lastUsedPremiumFeature,
    );
  }

  @override
  String toString() => 'PremiumUser('
      'userId: $userId, '
      'isPremium: $isPremium, '
      'premiumLevel: $premiumLevel, '
      'pointsBalance: $pointsBalance'
      ')';

  @override
  int get hashCode => Object.hash(
        userId,
        isPremium,
        premiumEndDate,
        premiumLevel,
        premiumStartDate,
        Object.hashAll(availableFeatures),
        pointsBalance,
        lastUsedPremiumFeature,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          isPremium == other.isPremium &&
          premiumEndDate == other.premiumEndDate &&
          premiumLevel == other.premiumLevel &&
          premiumStartDate == other.premiumStartDate &&
          _listEquals(availableFeatures, other.availableFeatures) &&
          pointsBalance == other.pointsBalance &&
          lastUsedPremiumFeature == other.lastUsedPremiumFeature;

  // Helper method for list equality comparison
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// Backward compatibility aliases
@Deprecated('Use PremiumUser instead')
typedef PremiumUsersModel = PremiumUser;
