import 'creation_failure.dart';

/// Creation Failure Extensions
///
/// Custom methods for CreationFailure that provide:
/// - getUserMessage(): 한국어 사용자 친화적 메시지
/// - getSuggestions(): AI 검열 제안사항
///
/// **Freezed Limitation Workaround**:
/// Freezed는 커스텀 메서드를 지원하지 않으므로 Extension으로 분리
extension CreationFailureExtensions on CreationFailure {
  /// 사용자에게 보여줄 한국어 메시지
  ///
  /// 각 Failure 타입에 맞는 상세한 한국어 메시지 반환
  String getUserMessage() {
    return when(
      // Base Content Failures
      createContentFailed: () => '콘텐츠 생성에 실패했습니다',
      imageUploadFailed: () => '이미지 업로드에 실패했습니다',
      moderationFailed: (rejectedReasons) {
        if (rejectedReasons.isEmpty) {
          return '콘텐츠 검열에 실패했습니다';
        }
        return '검열에서 다음 문제가 감지되었습니다: ${rejectedReasons.join(", ")}';
      },
      targetAudienceFailed: () => '타겟 오디언스 오류가 발생했습니다',
      creationValidationFailed: (fieldErrors) {
        if (fieldErrors.isEmpty) {
          return '유효성 검증에 실패했습니다';
        }
        final errorList = fieldErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        return '다음 항목을 확인해주세요: $errorList';
      },

      // Repository Layer Failures
      postCreationRepositoryFailed: (operation, postId) =>
          '게시물 $operation 작업 중 오류가 발생했습니다',
      mediaRepositoryFailed: (mediaType, failedPaths) {
        if (failedPaths.length == 1) {
          return '$mediaType 파일 처리 중 오류가 발생했습니다';
        }
        return '$mediaType 파일 ${failedPaths.length}개 처리 중 오류가 발생했습니다';
      },
      metricsRepositoryFailed: (metricType) =>
          '$metricType 통계 처리 중 오류가 발생했습니다',
      moderationRepositoryFailed: (moderationStep, rejectedReasons) {
        if (rejectedReasons.isEmpty) {
          return '$moderationStep 검열 중 오류가 발생했습니다';
        }
        return '검열에서 다음 문제가 감지되었습니다: ${rejectedReasons.join(", ")}';
      },
      visibilityRepositoryFailed: (visibility) =>
          '$visibility 가시성 설정 중 오류가 발생했습니다',

      // Domain Layer Failures - Firestore
      firestoreWriteFailed: (collectionPath, operation, attemptedData, code) {
        if (code == 'permission-denied' ||
            code == 'FIRESTORE_PERMISSION_DENIED') {
          return '데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.';
        } else if (code == 'unavailable') {
          return '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
        } else if (code == 'not-found' || code == 'POST_NOT_FOUND') {
          return '요청한 게시물을 찾을 수 없습니다.';
        }
        return '데이터 저장에 실패했습니다.';
      },

      // Domain Layer Failures - AI Moderation
      aiModerationFailed: (aiProvider, confidenceScore, detectedCategories,
          suggestions, rejectedReasons) {
        if (detectedCategories.isEmpty) {
          return 'AI 검열에서 부적절한 콘텐츠가 감지되었습니다';
        }

        // 카테고리를 한국어로 변환
        final koreanCategories = detectedCategories.map((category) {
          switch (category.toLowerCase()) {
            case 'sexual':
            case 'sexually_explicit':
              return '선정적 콘텐츠';
            case 'violence':
            case 'violent':
              return '폭력적 내용';
            case 'hate':
            case 'hate_speech':
              return '혐오 표현';
            case 'harassment':
            case 'threat':
              return '괴롭힘/협박';
            case 'toxicity':
            case 'toxic':
              return '유해한 콘텐츠';
            case 'profanity':
            case 'obscene':
              return '욕설';
            case 'spam':
              return '스팸';
            case 'identity_attack':
              return '신원 공격';
            default:
              return category;
          }
        }).join(', ');

        return 'AI 검열에서 다음 문제가 감지되었습니다: $koreanCategories';
      },

      // Domain Layer Failures - Media Processing
      mediaProcessingFailed: (failedStep, affectedFiles, details) {
        switch (failedStep) {
          case MediaProcessingStep.permission:
            if (details != null && details.isNotEmpty) {
              return details;
            }
            return '사진 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
          case MediaProcessingStep.compression:
            return '이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.';
          case MediaProcessingStep.aspectRatioValidation:
            return '이미지 비율이 올바르지 않습니다.';
          case MediaProcessingStep.moderationCheck:
            return '이미지 검토 중 문제가 발생했습니다.';
          case MediaProcessingStep.thumbnailGeneration:
            return '썸네일 생성에 실패했습니다.';
          case MediaProcessingStep.upload:
            return '이미지 업로드에 실패했습니다. 인터넷 연결을 확인해주세요.';
        }
      },

      // Domain Layer Failures - Audience Configuration
      audienceConfigurationFailed: (invalidField, attemptedValue,
          validationRule) {
        return '타겟 오디언스 설정이 올바르지 않습니다: $invalidField';
      },

      // Domain Layer Failures - Post Validation
      postValidationFailed: (missingFields, invalidFields, fieldErrors) {
        if (missingFields.isNotEmpty) {
          // 필드명을 한국어로 변환
          final koreanFields = missingFields.map((field) {
            switch (field) {
              case 'title':
                return '제목';
              case 'description':
                return '설명';
              case 'optionA':
              case 'textA':
                return 'A 옵션';
              case 'optionB':
              case 'textB':
                return 'B 옵션';
              case 'images':
              case 'imagesA':
                return 'A 이미지';
              case 'imagesB':
                return 'B 이미지';
              default:
                return field;
            }
          }).join(', ');
          return '필수 항목을 입력해주세요: $koreanFields';
        }

        if (invalidFields.isNotEmpty) {
          final koreanFields = invalidFields.map((field) {
            switch (field) {
              case 'title':
                return '제목';
              case 'description':
                return '설명';
              case 'optionA':
              case 'textA':
                return 'A 옵션';
              case 'optionB':
              case 'textB':
                return 'B 옵션';
              default:
                return field;
            }
          }).join(', ');
          return '올바르지 않은 항목이 있습니다: $koreanFields';
        }

        return '유효성 검증에 실패했습니다.';
      },
    );
  }

  /// AI 검열 제안사항 가져오기
  ///
  /// AIModerationFailed의 suggestions 반환
  /// 다른 Failure는 null 반환
  String? getSuggestions() {
    return maybeWhen(
      aiModerationFailed: (aiProvider, confidenceScore, detectedCategories,
              suggestions, rejectedReasons) =>
          suggestions,
      orElse: () => null,
    );
  }
}
