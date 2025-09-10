/// Domain model for notification display data
/// 
/// This model encapsulates all the data needed to display a notification
/// without exposing UI-specific types to the data layer.
class NotificationDisplayData {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String? description;
  final String? authorName;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String? layoutType;
  
  const NotificationDisplayData({
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description,
    this.authorName,
    this.aspectRatioA,
    this.aspectRatioB,
    this.layoutType,
  });
  
  /// Check if this notification has images
  bool get hasImageA => imageUrlA != null;
  bool get hasImageB => imageUrlB != null;
  
  /// Create from extracted vote data (used by NotificationDataExtractor)
  factory NotificationDisplayData.fromVoteData(Map<String, dynamic> voteData) {
    return NotificationDisplayData(
      question: voteData['question'] ?? '',
      optionA: voteData['optionA'] ?? '',
      optionB: voteData['optionB'] ?? '',
      imageUrlA: voteData['imageUrlA'],
      imageUrlB: voteData['imageUrlB'],
      imageUrlsA: voteData['imageUrlsA'] != null 
          ? List<String>.from(voteData['imageUrlsA']) 
          : null,
      imageUrlsB: voteData['imageUrlsB'] != null 
          ? List<String>.from(voteData['imageUrlsB']) 
          : null,
      description: voteData['description'],
      authorName: voteData['authorName'],
      aspectRatioA: voteData['aspectRatioA']?.toDouble(),
      aspectRatioB: voteData['aspectRatioB']?.toDouble(),
      layoutType: voteData['layoutType'],
    );
  }
}