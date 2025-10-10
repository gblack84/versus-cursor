import 'package:cloud_firestore/cloud_firestore.dart';

/// PremiumStatus DTO
///
/// **책임**: Firestore premium_users 컬렉션 문서 구조와 Dart 객체 간 변환
class PremiumStatusDto {
  final String? userId;
  final bool? isPremium;
  final DateTime? premiumStartDate;
  final DateTime? premiumEndDate;
  final String? subscriptionTier;
  final Map<String, dynamic>? subscription;

  const PremiumStatusDto({
    this.userId,
    this.isPremium,
    this.premiumStartDate,
    this.premiumEndDate,
    this.subscriptionTier,
    this.subscription,
  });

  /// Firestore → DTO
  factory PremiumStatusDto.fromFirestore(Map<String, dynamic> data) {
    return PremiumStatusDto(
      userId: data['userId'] as String?,
      isPremium: data['isPremium'] as bool?,
      premiumStartDate: (data['premiumStartDate'] as Timestamp?)?.toDate(),
      premiumEndDate: (data['premiumEndDate'] as Timestamp?)?.toDate(),
      subscriptionTier: data['subscriptionTier'] as String?,
      subscription: data['subscription'] as Map<String, dynamic>?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (isPremium != null) 'isPremium': isPremium,
      if (premiumStartDate != null)
        'premiumStartDate': Timestamp.fromDate(premiumStartDate!),
      if (premiumEndDate != null)
        'premiumEndDate': Timestamp.fromDate(premiumEndDate!),
      if (subscriptionTier != null) 'subscriptionTier': subscriptionTier,
      if (subscription != null) 'subscription': subscription,
    };
  }
}
