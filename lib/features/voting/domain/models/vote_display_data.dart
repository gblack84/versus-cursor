/// 투표 알림에서 추출된 데이터를 담는 클래스
class VoteDisplayData {
  final String question;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final String description;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String? layoutType;
  final String? authorName;

  const VoteDisplayData({
    required this.question,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.description = '',
    this.aspectRatioA,
    this.aspectRatioB,
    this.layoutType,
    this.authorName,
  });

  factory VoteDisplayData.empty() {
    return const VoteDisplayData(
      question: '',
      optionA: '',
      optionB: '',
      description: '',
    );
  }

  bool get isEmpty => question.isEmpty && optionA.isEmpty && optionB.isEmpty;
}