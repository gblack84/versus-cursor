import '../../domain/models/post_display.dart';
import '../dto/post_display_dto.dart';

/// Mapper for converting PostDisplayDto to PostDisplay domain model
/// DTO → Domain 모델 변환 담당
///
/// 책임:
/// - Firestore 필드를 Domain 필드로 1:1 매핑
/// - 타입 변환 및 기본값 처리
/// - 복잡한 파싱 로직 캡슐화
class PostDisplayMapper {
  /// Convert DTO to Domain model
  static PostDisplay toDomain(PostDisplayDto dto) {
    // Extract option A data
    final optionA = dto.getOptionData('optionA');
    final optionAText = optionA['text'] as String?;
    final optionAImages = dto.getOptionImages('optionA');
    final optionAAspectRatios = dto.getOptionAspectRatios('optionA');

    // Extract option B data
    final optionB = dto.getOptionData('optionB');
    final optionBText = optionB['text'] as String?;
    final optionBImages = dto.getOptionImages('optionB');
    final optionBAspectRatios = dto.getOptionAspectRatios('optionB');

    // Parse createdAt - support multiple formats
    final parsedDate = dto.getDateTime('createdAt') ?? dto.getDateTime('postCreatedDate');
    final createdAt = parsedDate ?? DateTime.now();

    return PostDisplay(
      id: dto.id,
      questionTitle: dto.getString('questionTitle') ?? '',
      userId: dto.getString('userid') ?? dto.getString('uid') ?? '',
      displayName: dto.getString('username') ?? dto.getString('userName') ?? '',
      photoUrl: dto.getString('userPhotoUrl') ?? '',
      description: dto.getString('description'),
      optionAText: optionAText,
      optionAImages: optionAImages,
      optionAAspectRatios: optionAAspectRatios,
      optionBText: optionBText,
      optionBImages: optionBImages,
      optionBAspectRatios: optionBAspectRatios,
      createdAt: createdAt,
      likeCount: dto.getInt('likecount') ?? 0,
      commentCount: dto.getInt('commentcount') ?? 0,
      shareCount: dto.getInt('sharecount') ?? 0,
      isAnonymous: dto.getBool('isAnonymous') ?? false,
      votesA: dto.getInt('votesA') ?? 0,
      votesB: dto.getInt('votesB') ?? 0,
      voteStatus: dto.getString('voteStatus') ?? 'pending',
      voteStartTime: dto.getDateTime('voteStartTime'),
      voteEndTime: dto.getDateTime('voteEndTime'),
      layoutType: dto.getString('layoutType') ?? 'vertical',
      status: dto.getString('status') ?? 'published',
      targetAudience: dto.getMap('targetAudience'),
    );
  }

  /// Convert Domain model to DTO (for writes - if needed later)
  static PostDisplayDto fromDomain(PostDisplay post) {
    return PostDisplayDto(
      id: post.id,
      rawData: {
        'questionTitle': post.questionTitle,
        'userid': post.userId,
        'username': post.displayName,
        'userPhotoUrl': post.photoUrl,
        'description': post.description,
        'optionA': {
          'text': post.optionAText,
          'images': post.optionAImages,
          'aspectRatios': post.optionAAspectRatios,
        },
        'optionB': {
          'text': post.optionBText,
          'images': post.optionBImages,
          'aspectRatios': post.optionBAspectRatios,
        },
        'createdAt': post.createdAt,
        'likecount': post.likeCount,
        'commentcount': post.commentCount,
        'sharecount': post.shareCount,
        'isAnonymous': post.isAnonymous,
        'votesA': post.votesA,
        'votesB': post.votesB,
        'voteStatus': post.voteStatus,
        'voteStartTime': post.voteStartTime,
        'voteEndTime': post.voteEndTime,
        'layoutType': post.layoutType,
        'status': post.status,
        'targetAudience': post.targetAudience,
      },
    );
  }
}
