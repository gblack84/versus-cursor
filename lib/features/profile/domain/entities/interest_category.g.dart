// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InterestCategory _$InterestCategoryFromJson(Map<String, dynamic> json) =>
    _InterestCategory(
      interestId: json['interestId'] as String,
      nameInterest: json['nameInterest'] as String,
      userIds:
          (json['userIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subCategories:
          (json['subCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$InterestCategoryToJson(_InterestCategory instance) =>
    <String, dynamic>{
      'interestId': instance.interestId,
      'nameInterest': instance.nameInterest,
      'userIds': instance.userIds,
      'subCategories': instance.subCategories,
    };
