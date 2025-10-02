import 'dart:io';
import '../../domain/models/target_audience.dart';

/// Data Transfer Object for post creation from Presentation layer
/// Simplifies CreatePostUseCase interface by bundling all creation parameters
class PostCreationDto {
  final String userId;
  final String title;
  final String description;
  final List<File> imagesA;
  final List<File> imagesB;
  final TargetAudience? targetAudience;
  final bool isAnonymous;

  const PostCreationDto({
    required this.userId,
    required this.title,
    required this.description,
    required this.imagesA,
    required this.imagesB,
    this.targetAudience,
    this.isAnonymous = false,
  });

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

  @override
  String toString() {
    return 'PostCreationDto('
        'userId: $userId, '
        'title: $title, '
        'description: $description, '
        'imagesA: ${imagesA.length} files, '
        'imagesB: ${imagesB.length} files, '
        'targetAudience: $targetAudience, '
        'isAnonymous: $isAnonymous)';
  }
}
