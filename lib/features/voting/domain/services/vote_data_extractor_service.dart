import '../models/vote_display_data.dart';
import '../ports/i_notification_data_port.dart';

/// 알림 데이터 추출을 위한 서비스 클래스
/// 
/// Clean Architecture 원칙에 따라 외부 의존성을 Port를 통해 주입받습니다.
class VoteDataExtractorService {
  final INotificationDataPort _notificationDataPort;
  
  VoteDataExtractorService({
    required INotificationDataPort notificationDataPort,
  }) : _notificationDataPort = notificationDataPort;
  
  /// 알림에서 투표 관련 데이터 추출
  Future<VoteDisplayData> extractVoteData({
    required String? content,
    required String? postId,
  }) async {
    // content 필드에서 데이터 파싱 시도
    if (content != null && content.isNotEmpty) {
      final contentData = _notificationDataPort.parseNotificationContent(content);
      
      if (contentData != null && contentData.containsKey('postData')) {
        final postData = contentData['postData'] as Map<String, dynamic>;
        return _extractFromPostData(postData);
      }
    }
    
    // Firestore에서 게시물 데이터 직접 조회
    if (postId != null) {
      return await _extractFromFirestore(postId);
    }
    
    return VoteDisplayData.empty();
  }
  
  VoteDisplayData _extractFromPostData(Map<String, dynamic> postData) {
    return VoteDisplayData(
      question: postData['questionTitle'] ?? '',
      optionA: postData['optionA'] ?? '',
      optionB: postData['optionB'] ?? '',
      imageUrlA: postData['imageUrlA'],
      imageUrlB: postData['imageUrlB'],
      imageUrlsA: postData['imageUrlsA'] is List
          ? (postData['imageUrlsA'] as List).cast<String>()
          : null,
      imageUrlsB: postData['imageUrlsB'] is List
          ? (postData['imageUrlsB'] as List).cast<String>()
          : null,
      description: postData['description'] ??
          postData['descriptionA'] ??
          postData['descriptionB'] ??
          '',
      aspectRatioA: postData['aspectRatioA']?.toDouble(),
      aspectRatioB: postData['aspectRatioB']?.toDouble(),
      layoutType: postData['layoutType'],
      authorName: postData['authorName'],
    );
  }
  
  Future<VoteDisplayData> _extractFromFirestore(String postId) async {
    try {
      final postData = await _notificationDataPort.getPostData(postId);
      
      if (postData == null) {
        return VoteDisplayData.empty();
      }
      
      String optionA = '';
      String optionB = '';
      String? imageUrlA;
      String? imageUrlB;
      List<String>? imageUrlsA;
      List<String>? imageUrlsB;
      
      // optionA 처리
      if (postData['optionA'] is Map) {
        final optionAData = postData['optionA'] as Map<String, dynamic>;
        optionA = optionAData['title'] ?? '';
        if (optionAData['mediaUrls'] is List &&
            (optionAData['mediaUrls'] as List).isNotEmpty) {
          final mediaList = (optionAData['mediaUrls'] as List).cast<String>();
          imageUrlsA = mediaList;
          imageUrlA = mediaList.first;
        }
      } else {
        optionA = postData['optionA'] ?? postData['textA'] ?? '';
      }
      
      // optionB 처리
      if (postData['optionB'] is Map) {
        final optionBData = postData['optionB'] as Map<String, dynamic>;
        optionB = optionBData['title'] ?? '';
        if (optionBData['mediaUrls'] is List &&
            (optionBData['mediaUrls'] as List).isNotEmpty) {
          final mediaList = (optionBData['mediaUrls'] as List).cast<String>();
          imageUrlsB = mediaList;
          imageUrlB = mediaList.first;
        }
      } else {
        optionB = postData['optionB'] ?? postData['textB'] ?? '';
      }
      
      return VoteDisplayData(
        question: postData['questionTitle'] ?? '',
        optionA: optionA,
        optionB: optionB,
        imageUrlA: imageUrlA,
        imageUrlB: imageUrlB,
        imageUrlsA: imageUrlsA,
        imageUrlsB: imageUrlsB,
        description: postData['description'] ??
            postData['descriptionA'] ??
            postData['descriptionB'] ??
            '',
        authorName:
            postData['authorName'] ?? postData['authorDisplayName'] ?? '익명',
      );
    } catch (e) {
      return VoteDisplayData.empty();
    }
  }
}