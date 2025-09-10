import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/versus_box_size_data.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/notifications/domain/models/vote_notification.dart' as domain;
import '/features/notifications/domain/usecases/get_post_data_use_case.dart';

/// 알림 UI 처리를 위한 델리게이트 인터페이스
/// 
/// GlobalNotificationManager와 UI 계층 간의 의존성을 분리하기 위한 추상화
abstract class INotificationUIDelegate {
  /// 투표 알림을 UI에 표시
  /// 
  /// [notification] 표시할 알림 객체
  /// [context] UI 컨텍스트 
  /// [onVote] 투표 선택 시 콜백
  /// [onDismiss] 알림 닫기 시 콜백
  Future<void> showVotingNotification({
    required domain.Notification notification,
    required BuildContext context,
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? description,
    String? authorName,
    VersusBoxSizeData? sizeData,
    required Future<void> Function(String selectedOption) onVote,
    required void Function(bool hasVoted) onDismiss,
  });

  /// 현재 표시 가능한 UI 컨텍스트가 있는지 확인
  bool isUIContextAvailable();

  /// UI 컨텍스트 준비 대기
  Future<BuildContext?> waitForUIContext({Duration timeout = const Duration(seconds: 10)});
}

/// 알림 데이터 추출을 위한 유틸리티 클래스
class NotificationDataExtractor {
  /// 알림에서 투표 관련 데이터 추출
  static Future<NotificationVoteData> extractVoteData(domain.Notification notification) async {

    // content 필드에서 데이터 파싱 시도
    if (notification.content.isNotEmpty) {
      try {
        final contentData = jsonDecode(notification.content) as Map<String, dynamic>;
        
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

    return NotificationVoteData.empty();
  }

  static NotificationVoteData _extractFromPostData(Map<String, dynamic> postData) {
    return NotificationVoteData(
      question: postData['questionTitle'] ?? '',
      optionA: postData['optionA'] ?? '',
      optionB: postData['optionB'] ?? '',
      imageUrlA: postData['imageUrlA'],
      imageUrlB: postData['imageUrlB'],
      imageUrlsA: postData['imageUrlsA'] is List ? (postData['imageUrlsA'] as List).cast<String>() : null,
      imageUrlsB: postData['imageUrlsB'] is List ? (postData['imageUrlsB'] as List).cast<String>() : null,
      description: postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'] ?? '',
      aspectRatioA: postData['aspectRatioA']?.toDouble(),
      aspectRatioB: postData['aspectRatioB']?.toDouble(),
      layoutType: postData['layoutType'],
      authorName: postData['authorName'],
    );
  }

  static Future<NotificationVoteData> _extractFromFirestore(String postId) async {
    try {
      // GetPostDataUseCase를 DI container에서 가져옴 (Clean Architecture 준수)
      final getPostDataUseCase = GetIt.instance<GetPostDataUseCase>();
      final postData = await getPostDataUseCase.execute(postId: postId);

      if (postData == null) {
        return NotificationVoteData.empty();
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
        if (optionAData['mediaUrls'] is List && (optionAData['mediaUrls'] as List).isNotEmpty) {
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
        if (optionBData['mediaUrls'] is List && (optionBData['mediaUrls'] as List).isNotEmpty) {
          final mediaList = (optionBData['mediaUrls'] as List).cast<String>();
          imageUrlsB = mediaList;
          imageUrlB = mediaList.first;
        }
      } else {
        optionB = postData['optionB'] ?? postData['textB'] ?? '';
      }

      return NotificationVoteData(
        question: postData['questionTitle'] ?? '',
        optionA: optionA,
        optionB: optionB,
        imageUrlA: imageUrlA,
        imageUrlB: imageUrlB,
        imageUrlsA: imageUrlsA,
        imageUrlsB: imageUrlsB,
        description: postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'] ?? '',
        authorName: postData['authorName'] ?? postData['authorDisplayName'] ?? '익명',
      );
    } catch (e) {
      return NotificationVoteData.empty();
    }
  }
}

/// 투표 알림에서 추출된 데이터를 담는 클래스
class NotificationVoteData {
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

  const NotificationVoteData({
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

  factory NotificationVoteData.empty() {
    return const NotificationVoteData(
      question: '',
      optionA: '',
      optionB: '',
      description: '',
    );
  }

  bool get isEmpty => question.isEmpty && optionA.isEmpty && optionB.isEmpty;
}

