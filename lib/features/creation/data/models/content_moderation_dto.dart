import 'dart:io';

/// Data Transfer Object for content moderation requests
/// Supports different moderation contexts (text, image, full content)
class ContentModerationDto {
  final String? title;
  final String? description;
  final List<File>? imagesA;
  final List<File>? imagesB;
  final ModerationContext context;

  const ContentModerationDto({
    this.title,
    this.description,
    this.imagesA,
    this.imagesB,
    required this.context,
  });

  /// Factory for text-only moderation
  factory ContentModerationDto.text({
    required String title,
    required String description,
  }) {
    return ContentModerationDto(
      title: title,
      description: description,
      context: ModerationContext.text,
    );
  }

  /// Factory for image-only moderation
  factory ContentModerationDto.images({
    required List<File> imagesA,
    List<File>? imagesB,
  }) {
    return ContentModerationDto(
      imagesA: imagesA,
      imagesB: imagesB,
      context: ModerationContext.image,
    );
  }

  /// Factory for full content moderation (text + images)
  factory ContentModerationDto.fullContent({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) {
    return ContentModerationDto(
      title: title,
      description: description,
      imagesA: imagesA,
      imagesB: imagesB,
      context: ModerationContext.fullContent,
    );
  }

  /// Check if has text content to moderate
  bool get hasTextContent => title != null || description != null;

  /// Check if has image content to moderate
  bool get hasImageContent =>
      (imagesA != null && imagesA!.isNotEmpty) ||
      (imagesB != null && imagesB!.isNotEmpty);

  @override
  String toString() {
    return 'ContentModerationDto('
        'context: ${context.name}, '
        'hasText: $hasTextContent, '
        'hasImages: $hasImageContent)';
  }
}

/// Context type for content moderation
enum ModerationContext {
  /// Text-only moderation (title, description)
  text,

  /// Image-only moderation
  image,

  /// Full content moderation (text + images)
  fullContent,
}
