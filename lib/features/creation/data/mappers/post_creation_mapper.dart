import '../models/post_creation_dto.dart';
import '../../domain/models/aggregates/post_creation.dart';

/// Mapper for converting between PostCreation DTO and Domain entity
///
/// This mapper handles the conversion from Presentation layer DTOs
/// to Domain layer entities. Note that this mapper creates a draft
/// PostCreation entity - the actual image upload and URL population
/// happens in the UseCase.
class PostCreationMapper {
  /// Converts PostCreationDto to PostCreation domain entity
  ///
  /// Creates a draft entity with empty URLs (will be populated after upload).
  /// This is used as an intermediate step before image processing.
  static PostCreation toDraftEntity(PostCreationDto dto) {
    return PostCreation(
      userId: dto.userId,
      title: dto.title,
      description: dto.description,
      optionA: const PostOption(
        imageUrls: [],  // Will be populated after upload
        aspectRatios: [],
      ),
      optionB: const PostOption(
        imageUrls: [],  // Will be populated after upload
        aspectRatios: [],
      ),
      targetAudience: dto.targetAudience,
      createdAt: DateTime.now(),
      status: PostStatus.draft,
      isAnonymous: dto.isAnonymous,
    );
  }

  /// Creates a complete PostCreation entity with uploaded URLs and aspect ratios
  ///
  /// This is called after image upload is complete in the UseCase.
  static PostCreation toEntityWithMedia({
    required PostCreationDto dto,
    required List<String> imageUrlsA,
    required List<double> aspectRatiosA,
    required List<String> imageUrlsB,
    required List<double> aspectRatiosB,
  }) {
    return PostCreation(
      userId: dto.userId,
      title: dto.title,
      description: dto.description,
      optionA: PostOption(
        imageUrls: imageUrlsA,
        aspectRatios: aspectRatiosA,
      ),
      optionB: PostOption(
        imageUrls: imageUrlsB,
        aspectRatios: aspectRatiosB,
      ),
      targetAudience: dto.targetAudience,
      createdAt: DateTime.now(),
      status: PostStatus.published,  // Ready for publishing
      isAnonymous: dto.isAnonymous,
    );
  }
}
