import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/value_objects/target_audience.dart';

part 'post_creation_dto.freezed.dart';

/// Data Transfer Object for post creation from Presentation layer
/// Simplifies CreatePostUseCase interface by bundling all creation parameters
@freezed
class PostCreationDto with _$PostCreationDto {
  const factory PostCreationDto({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    @Default(false) bool isAnonymous,
  }) = _PostCreationDto;

  /// Factory constructor from Provider's PostFormData
  /// Maps Presentation layer data structure to Domain layer DTO
  factory PostCreationDto.fromFormData({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
  }) {
    return PostCreationDto(
      userId: userId,
      title: title,
      description: description,
      imagesA: imagesA,
      imagesB: imagesB,
      targetAudience: targetAudience,
      isAnonymous: isAnonymous,
    );
  }
}
