import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/app/state/app_state.dart';
import '/services/moderation/models/image_moderation_model.dart';
import 'media_upload_service.dart';
import '/services/cache/image_cache_helper.dart';
import '/features/posts/presentation/screens/create_post/in_put_post_image_model.dart';
import '/core/utils/debug_helper.dart';

/// 이미지 업로드 프로세스를 조율하는 서비스 클래스
///
/// @deprecated Use ImageUploadProvider instead for better architecture separation.
/// This class violates Clean Architecture by mixing UI (BuildContext) with data layer.
/// Migration path:
/// 1. Use ImageUploadService for pure data operations
/// 2. Use ImageUploadProvider for UI state management
///
/// 더 나은 아키텍처 분리를 위해 ImageUploadProvider를 사용하세요.
/// 이 클래스는 UI(BuildContext)를 데이터 레이어와 혼합하여 클린 아키텍처를 위반합니다.
@Deprecated('Use ImageUploadProvider and ImageUploadService instead')
class ImageUploadOrchestrator {
  final BuildContext context;
  final AppState appState;
  final String box;
  final InPutPostImageModel? model; // 편집 모드 감지를 위해 추가

  ImageUploadOrchestrator({
    required this.context,
    required this.appState,
    required this.box,
    this.model,
  });

  /// 멀티 이미지 업로드 처리
  Future<ImageUploadResult> handleMultiImageUpload({
    required Uint8List editedImageBytes,
    required List<File> allFiles,
    required int currentEditIndex,
    required List<AssetEntity> selectedAssets,
    bool isAddMode = false,
    int? currentIndex,
    List<String>? existingImageUrls,
    List<double>? existingAspectRatios,
    List<String>? existingAssetIds,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  }) async {
    final reorderedUrls = <String>[];
    final reorderedRatios = <double>[];
    final reorderedAssetIds = <String>[];

    try {
      // 1. 편집된 이미지 업로드 및 검열
      onModerationProgress?.call(1, allFiles.isEmpty ? 1 : allFiles.length);

      final editedResult = await MediaUploadService.uploadAndWaitForModeration(
        imageBytes: editedImageBytes,
        box: box,
        timeout: const Duration(seconds: 15),
      );

      // 편집된 이미지 검열 결과 저장
      bool firstImageRejected = false;
      String? firstImageRejectionReason;

      if (editedResult['isApproved'] != true) {
        firstImageRejected = true;
        firstImageRejectionReason =
            editedResult['rejectionReason'] ?? '커뮤니티 가이드라인 위반';
        print('[ImageUploadOrchestrator] 첫 번째 이미지 검열 실패');
      }

      // Vision API 데이터를 model에 저장 (첫 번째 이미지)
      if (model != null && editedResult['moderation'] != null) {
        final moderation = editedResult['moderation'] as ImageModerationModel;
        final visionData = _extractVisionData(moderation);

        if (box == 'A') {
          model!.visionResultA = visionData;
        } else {
          model!.visionResultB = visionData;
        }
      }

      final editedDisplayUrl = editedResult['urls']['display'] as String;
      final editedAspectRatio = editedResult['aspectRatio'] as double;

      // 2. 첫 번째 이미지가 승인된 경우에만 추가
      if (!firstImageRejected) {
        if (isAddMode && currentIndex != null) {
          // 기존 이미지들을 그대로 복사
          if (existingImageUrls != null && existingAspectRatios != null) {
            reorderedUrls.addAll(existingImageUrls);
            reorderedRatios.addAll(existingAspectRatios);
          }

          // 새 이미지를 추가
          reorderedUrls.add(editedDisplayUrl);
          reorderedRatios.add(editedAspectRatio);
        } else {
          // 편집된 이미지를 맨 앞에 배치
          reorderedUrls.add(editedDisplayUrl);
          reorderedRatios.add(editedAspectRatio);
        }

        // 첫 번째 이미지 즉시 프리캐싱
        await _precacheImage(editedDisplayUrl);
      }

      onProgress?.call(0.4);

      // 3. 나머지 이미지들 처리
      final rejectionReasonsMap = <String, List<int>>{}; // 거부 이유별 이미지 번호
      int rejectedCount = 0;

      if (!isAddMode &&
          existingImageUrls != null &&
          existingImageUrls.isNotEmpty) {
        // 기존 URL 재사용 모드
        await _reuseExistingImages(
          existingImageUrls: existingImageUrls,
          existingAspectRatios: existingAspectRatios ?? [],
          currentEditIndex: currentEditIndex,
          reorderedUrls: reorderedUrls,
          reorderedRatios: reorderedRatios,
        );
        onProgress?.call(0.8);
        // 재사용 모드에서는 첫 번째 이미지만 검열했으므로
        // 첫 번째 이미지가 거부되었다면 전체 거부 (시나리오 2)로 이미 처리됨
      } else {
        // 새로 업로드 모드
        final uploadResult = await _uploadRemainingImages(
          allFiles: allFiles,
          currentEditIndex: currentEditIndex,
          reorderedUrls: reorderedUrls,
          reorderedRatios: reorderedRatios,
          onProgress: onProgress,
        );

        rejectedCount = uploadResult['rejectedCount'] as int;
        final resultRejectionMap =
            uploadResult['rejectionReasonsMap'] as Map<String, List<int>>;

        // 결과를 rejectionReasonsMap에 병합
        resultRejectionMap.forEach((reason, numbers) {
          rejectionReasonsMap.putIfAbsent(reason, () => []).addAll(numbers);
        });

        // 첫 번째 이미지가 거부된 경우 추가
        if (firstImageRejected) {
          rejectedCount++;
          rejectionReasonsMap
              .putIfAbsent(firstImageRejectionReason!, () => [])
              .add(0);
        }

        // 전체 이미지 개수와 거부된 이미지 개수 확인
        final totalImages = allFiles.length;
        final approvedCount = totalImages - rejectedCount;

        print(
            '[ImageUploadOrchestrator] 전체 이미지: $totalImages, 거부: $rejectedCount, 승인: $approvedCount');

        // 시나리오 판단
        if (approvedCount == 0) {
          // 시나리오 2: 모든 이미지가 거부됨
          // 편집 모드일 경우 빈 배열로 DB 업데이트
          if (model != null && model!.isEditMode) {
            await _updateFirestoreAfterRejection(
              approvedUrls: [],
              box: box,
            );
          }

          // 거부 이유 메시지 생성
          final messages = <String>[];
          rejectionReasonsMap.forEach((reason, numbers) {
            final adjustedNumbers = numbers.map((n) => n + 1).toList()..sort();
            messages.add('$reason: ${adjustedNumbers.join(",")}');
          });

          return ImageUploadResult(
            success: false,
            rejectionReason: messages.join('\n'),
            scenarioType: 2,
          );
        } else if (rejectedCount > 0) {
          // 시나리오 1: 일부 이미지만 거부됨
          onProgress?.call(1.0);

          // AppState 업데이트 먼저 수행
          _updateAppState(
            reorderedUrls: reorderedUrls,
            reorderedRatios: reorderedRatios,
            reorderedAssetIds: reorderedAssetIds,
          );

          // 편집 모드일 경우 승인된 이미지만으로 DB 업데이트
          if (model != null && model!.isEditMode) {
            await _updateFirestoreAfterRejection(
              approvedUrls: reorderedUrls,
              box: box,
            );
          }

          // 거부 이유 메시지 생성
          final messages = <String>[];
          rejectionReasonsMap.forEach((reason, numbers) {
            final adjustedNumbers = numbers.map((n) => n + 1).toList()..sort();
            messages.add('$reason: ${adjustedNumbers.join(",")}');
          });

          return ImageUploadResult(
            success: true,
            imageUrls: reorderedUrls,
            aspectRatios: reorderedRatios,
            assetIds: reorderedAssetIds,
            rejectionReason: messages.join('\n'),
          );
        }
      }

      // 4. AssetEntity ID 순서 맞추기
      _reorderAssetIds(
        isAddMode: isAddMode,
        existingAssetIds: existingAssetIds,
        selectedAssets: selectedAssets,
        currentEditIndex: currentEditIndex,
        reorderedAssetIds: reorderedAssetIds,
      );

      // 5. AppState 업데이트
      _updateAppState(
        reorderedUrls: reorderedUrls,
        reorderedRatios: reorderedRatios,
        reorderedAssetIds: reorderedAssetIds,
      );

      // 6. 편집 모드일 경우 DB 업데이트
      if (model != null && model!.isEditMode && rejectedCount > 0) {
        await _updateFirestoreAfterRejection(
          approvedUrls: reorderedUrls,
          box: box,
        );
      }

      onProgress?.call(1.0);

      return ImageUploadResult(
        success: true,
        imageUrls: reorderedUrls,
        aspectRatios: reorderedRatios,
        assetIds: reorderedAssetIds,
      );
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 단일 이미지 업로드 처리
  Future<ImageUploadResult> handleSingleImageUpload({
    required Uint8List imageBytes,
    required List<AssetEntity> selectedAssets,
    bool isEditMode = false,
    Function(double)? onProgress,
    Function()? onModerationStart,
  }) async {
    try {
      onModerationStart?.call();

      final result = await MediaUploadService.uploadAndWaitForModeration(
        imageBytes: imageBytes,
        box: box,
        timeout: const Duration(seconds: 15),
      );

      // Vision API 데이터를 model에 저장
      if (model != null && result['moderation'] != null) {
        final moderation = result['moderation'] as ImageModerationModel;
        final visionData = _extractVisionData(moderation);

        if (box == 'A') {
          model!.visionResultA = visionData;
        } else {
          model!.visionResultB = visionData;
        }
      }

      // 검열 결과 확인
      if (result['isApproved'] != true) {
        // 편집 모드일 경우 빈 배열로 DB 업데이트
        if (model != null && model!.isEditMode) {
          await _updateFirestoreAfterRejection(
            approvedUrls: [],
            box: box,
          );
        }

        return ImageUploadResult(
          success: false,
          rejectionReason: result['rejectionReason'] ?? '커뮤니티 가이드라인 위반',
        );
      }

      final displayUrl = result['urls']['display'] as String;
      final aspectRatio = result['aspectRatio'] as double;

      onProgress?.call(0.9);

      // 편집 모드가 아닐 때만 AppState에 추가
      if (!isEditMode) {
        appState.update(() {
          if (box == 'A') {
            appState.addToUploadImageA(displayUrl);
            appState.addToUploadImageAspectRatioA(aspectRatio);
            if (selectedAssets.isNotEmpty) {
              appState.addToAssetEntityIdsA(selectedAssets.first.id);
            }
          } else {
            appState.addToUploadImageB(displayUrl);
            appState.addToUploadImageAspectRatioB(aspectRatio);
            if (selectedAssets.isNotEmpty) {
              appState.addToAssetEntityIdsB(selectedAssets.first.id);
            }
          }
        });
      }

      // 프리캐싱
      await _precacheImage(displayUrl);
      onProgress?.call(1.0);

      return ImageUploadResult(
        success: true,
        imageUrls: [displayUrl],
        aspectRatios: [aspectRatio],
      );
    } catch (e) {
      return ImageUploadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 이미지 프리캐싱
  Future<void> _precacheImage(String url) async {
    await ImageCacheHelper.preloadImages(context, [url]);
  }

  /// 기존 이미지 재사용
  Future<void> _reuseExistingImages({
    required List<String> existingImageUrls,
    required List<double> existingAspectRatios,
    required int currentEditIndex,
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
  }) async {
    for (int i = 0; i < existingImageUrls.length; i++) {
      if (i != currentEditIndex) {
        reorderedUrls.add(existingImageUrls[i]);
        if (i < existingAspectRatios.length) {
          reorderedRatios.add(existingAspectRatios[i]);
        }
      }
    }
  }

  /// 나머지 이미지 업로드
  Future<Map<String, dynamic>> _uploadRemainingImages({
    required List<File> allFiles,
    required int currentEditIndex,
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
    Function(double)? onProgress,
  }) async {
    final uploadFutures = <Future<Map<String, dynamic>>>[];
    final fileBytesFutures = <Future<Uint8List>>[];

    // 파일 읽기를 먼저 병렬로 처리
    for (int i = 0; i < allFiles.length; i++) {
      if (i != currentEditIndex) {
        fileBytesFutures.add(allFiles[i].readAsBytes());
      }
    }

    if (fileBytesFutures.isNotEmpty) {
      final allFileBytes = await Future.wait(fileBytesFutures);

      // 업로드 작업을 병렬로 시작
      for (final fileBytes in allFileBytes) {
        uploadFutures.add(MediaUploadService.uploadAndWaitForModeration(
          imageBytes: fileBytes,
          box: box,
          timeout: const Duration(seconds: 15),
        ).catchError((e) {
          print('[ImageUploadOrchestrator] 이미지 업로드 실패 (건너뜀): $e');
          return <String, dynamic>{
            'urls': {'display': '', 'original': '', 'thumbnail': ''},
            'aspectRatio': 1.0,
            'isApproved': true, // 에러 시 기본값
          };
        }));
      }

      onProgress?.call(0.6);

      // 모든 업로드 완료 대기
      final results = await Future.wait(uploadFutures);

      // 결과 처리 및 프리캐싱
      final precacheFutures = <Future<void>>[];
      int imageIndex = 1; // 편집된 이미지가 0번이므로 1부터 시작
      int rejectedCount = 0; // 거부된 이미지 개수 추적
      final rejectionReasonsMap = <String, List<int>>{}; // 거부 이유별 이미지 번호

      for (final result in results) {
        // 검열 결과 확인
        if (result['isApproved'] == true) {
          final displayUrl = result['urls']['display'];
          if (displayUrl != null && displayUrl.isNotEmpty) {
            reorderedUrls.add(displayUrl);
            reorderedRatios.add(result['aspectRatio']);

            // 백그라운드 프리캐싱
            precacheFutures.add(_precacheImage(displayUrl));
          }
        } else {
          print('[ImageUploadOrchestrator] ${imageIndex}번째 이미지 검열 실패');
          rejectedCount++;
          final reason = result['rejectionReason'] ?? '커뮤니티 가이드라인 위반';
          rejectionReasonsMap.putIfAbsent(reason, () => []).add(imageIndex);
        }
        imageIndex++;
      }

      // 나머지 이미지들은 백그라운드에서 계속 프리캐싱
      Future.wait(precacheFutures).then((_) {
        print('모든 이미지 프리캐싱 완료');
      });

      return {
        'rejectedCount': rejectedCount,
        'rejectionReasonsMap': rejectionReasonsMap,
      };
    }

    return {
      'rejectedCount': 0,
      'rejectionReasonsMap': <String, List<int>>{},
    };
  }

  /// AssetEntity ID 재정렬
  void _reorderAssetIds({
    required bool isAddMode,
    required List<String>? existingAssetIds,
    required List<AssetEntity> selectedAssets,
    required int currentEditIndex,
    required List<String> reorderedAssetIds,
  }) {
    if (isAddMode) {
      // 추가 모드: 기존 ID들 + 새 ID
      if (existingAssetIds != null) {
        reorderedAssetIds.addAll(existingAssetIds);
      }
      if (selectedAssets.isNotEmpty &&
          currentEditIndex < selectedAssets.length) {
        reorderedAssetIds.add(selectedAssets[currentEditIndex].id);
      }
    } else if (selectedAssets.isNotEmpty) {
      // 편집 모드: 편집된 이미지의 AssetEntity ID를 맨 앞에
      if (currentEditIndex < selectedAssets.length) {
        reorderedAssetIds.add(selectedAssets[currentEditIndex].id);
      }
      // 나머지 AssetEntity ID들
      for (int i = 0; i < selectedAssets.length; i++) {
        if (i != currentEditIndex) {
          reorderedAssetIds.add(selectedAssets[i].id);
        }
      }
    }
  }

  /// Vision API 데이터 추출 (확장된 버전)
  Map<String, dynamic> _extractVisionData(ImageModerationModel moderation) {
    return {
      'safeSearch': {
        'adult': moderation.safeSearchResults.adult,
        'violence': moderation.safeSearchResults.violence,
        'racy': moderation.safeSearchResults.racy,
        'medical': moderation.safeSearchResults.medical,
        'spoof': moderation.safeSearchResults.spoof,
      },
      'labels': moderation.labels
          .map((label) => {
                'description': label.description,
                'score': label.score,
              })
          .toList(),
      'detectedText':
          moderation.detectedText.isNotEmpty ? moderation.detectedText : null,
      'logos': moderation.logos
          .map((logo) => {
                'description': logo.description,
                'score': logo.score,
              })
          .toList(),
      'objects': moderation.objects
          .map((obj) => {
                'name': obj.name,
                'score': obj.score,
              })
          .toList(),
      'dominantColors': moderation.dominantColors
          .map((color) => {
                'red': color.color['red'] ?? 0,
                'green': color.color['green'] ?? 0,
                'blue': color.color['blue'] ?? 0,
                'score': color.score,
              })
          .toList(),
      'faces': moderation.faces
          .map((face) => {
                'joy': face.joyLikelihood,
                'sorrow': face.sorrowLikelihood,
                'anger': face.angerLikelihood,
                'surprise': face.surpriseLikelihood,
              })
          .toList(),
      'moderationStatus': moderation.moderationStatus,
      'moderatedAt': moderation.moderatedAt?.toIso8601String(),
    };
  }

  /// AppState 업데이트
  void _updateAppState({
    required List<String> reorderedUrls,
    required List<double> reorderedRatios,
    required List<String> reorderedAssetIds,
  }) {
    appState.update(() {
      if (box == 'A') {
        appState.uploadImageA = reorderedUrls;
        appState.uploadImageAspectRatioA = reorderedRatios;
        appState.assetEntityIdsA = reorderedAssetIds;
      } else {
        appState.uploadImageB = reorderedUrls;
        appState.uploadImageAspectRatioB = reorderedRatios;
        appState.assetEntityIdsB = reorderedAssetIds;
      }
    });
  }

  /// Firestore에서 거부된 이미지 후 업데이트
  Future<void> _updateFirestoreAfterRejection({
    required List<String> approvedUrls,
    required String box,
  }) async {
    // 편집 모드가 아니거나 postRef가 없으면 무시
    if (model == null || !model!.isEditMode || model!.existingPostRef == null) {
      return;
    }

    try {
      final postRef = model!.existingPostRef!;

      // 필드 이름 결정
      final optionField = box == 'A' ? 'optionA' : 'optionB';
      final pollOptionField =
          box == 'A' ? 'option_1_media_urls' : 'option_2_media_urls';

      // 트랜잭션으로 원자성 보장
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // posts_record 업데이트
        transaction.update(postRef, {
          '$optionField.mediaUrls': approvedUrls,
        });

        // poll_details 서브컬렉션 업데이트
        final pollDetailsQuery =
            await postRef.collection('pollDetails').limit(1).get();

        if (pollDetailsQuery.docs.isNotEmpty) {
          final pollDetailsRef = pollDetailsQuery.docs.first.reference;
          transaction.update(pollDetailsRef, {
            pollOptionField: approvedUrls,
            // 첫 번째 이미지 URL도 업데이트 (단일 URL 필드)
            '${pollOptionField.replaceAll('_urls', '_url')}':
                approvedUrls.isNotEmpty ? approvedUrls.first : '',
          });
        }
      });

      DebugHelper.log(
          '[ImageUploadOrchestrator] 거부된 이미지 후 Firestore 업데이트 성공 - $box 박스');
    } catch (e) {
      DebugHelper.logError('Firestore 업데이트 중 오류', e);
      // 에러가 발생해도 사용자 경험은 방해하지 않음
    }
  }
}

/// 이미지 업로드 결과 클래스
class ImageUploadResult {
  final bool success;
  final List<String>? imageUrls;
  final List<double>? aspectRatios;
  final List<String>? assetIds;
  final String? rejectionReason;
  final String? error;
  final int? scenarioType; // 1: 일부 거부, 2: 모든 거부

  ImageUploadResult({
    required this.success,
    this.imageUrls,
    this.aspectRatios,
    this.assetIds,
    this.rejectionReason,
    this.error,
    this.scenarioType,
  });
}
