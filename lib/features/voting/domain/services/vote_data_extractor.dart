import 'dart:convert';
import 'package:get_it/get_it.dart';
import '/features/voting/domain/models/vote_display_data.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/notifications/domain/models/vote_notification.dart' as domain;
import '/features/notifications/domain/usecases/get_post_data_use_case.dart';

/// 알림 데이터 추출을 위한 유틸리티 클래스
class VoteDataExtractor {
  /// 알림에서 투표 관련 데이터 추출
  static Future<VoteDisplayData> extractVoteData(
      domain.Notification notification) async {
    // content 필드에서 데이터 파싱 시도
    if (notification.content.isNotEmpty) {
      try {
        final contentData =
            jsonDecode(notification.content) as Map<String, dynamic>;

        if (contentData.containsKey('postData')) {
          final postData = contentData['postData'] as Map<String, dynamic>;
          return _extractFromPostData(postData);
        }
      } catch (e) {
        // content 파싱 실패 시 Firestore에서 직접 조회
      }
    }

    // Firestore에서 게시물 데이터 직접 조회
    if (notification is domain.VoteNotification) {
      return await _extractFromFirestore(notification.postId);
    }

    return VoteDisplayData.empty();
  }

  static VoteDisplayData _extractFromPostData(
      Map<String, dynamic> postData) {
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

  static Future<VoteDisplayData> _extractFromFirestore(
      String postId) async {
    try {
      // GetPostDataUseCase를 DI container에서 가져옴 (Clean Architecture 준수)
      final getPostDataUseCase = GetIt.instance<GetPostDataUseCase>();
      final postData = await getPostDataUseCase.execute(postId: postId);

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