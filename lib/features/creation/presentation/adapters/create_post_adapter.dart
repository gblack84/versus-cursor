import 'dart:io';
import '/core_exports.dart';
import '../providers/create_post_provider_v2.dart';
import '../../domain/entities/post_creation.dart';
import '../../domain/models/media_content.dart';
import '../../domain/models/post_stats.dart';

/// Adapter pattern implementation to bridge legacy AppState with Clean Architecture
///
/// This adapter enables gradual migration from legacy code to Clean Architecture
/// by providing a bridge between the old AppState and new CreatePostProviderV2.
/// It maintains backward compatibility while allowing incremental refactoring.
class CreatePostAdapter {
  final CreatePostProviderV2 _cleanProvider;
  final AppState _legacyState;

  CreatePostAdapter({
    required CreatePostProviderV2 cleanProvider,
    required AppState legacyState,
  })  : _cleanProvider = cleanProvider,
        _legacyState = legacyState;

  /// 이미지 업데이트 - A박스
  void updateImagesA(List<String> urls) {
    // Clean Architecture로 전달 (File 객체로 변환)
    final files = urls.map((url) {
      // URL이 Firebase Storage URL인 경우 그대로 사용
      if (url.startsWith('http')) {
        return File(url); // URL을 임시 File 경로로 사용
      }
      // 로컬 파일 경로인 경우
      return File(url);
    }).toList();

    _cleanProvider.updateImagesA(files);

    // 레거시 상태도 업데이트 (backward compatibility)
    _legacyState.update(() {
      _legacyState.uploadImageA.clear();
      _legacyState.uploadImageA.addAll(urls);
    });
  }

  /// 이미지 업데이트 - B박스
  void updateImagesB(List<String> urls) {
    final files = urls.map((url) {
      if (url.startsWith('http')) {
        return File(url);
      }
      return File(url);
    }).toList();

    _cleanProvider.updateImagesB(files);

    _legacyState.update(() {
      _legacyState.uploadImageB.clear();
      _legacyState.uploadImageB.addAll(urls);
    });
  }

  /// 임시 이미지 파일 업데이트 - A박스
  void updateTempImagesA(List<File> files) {
    _cleanProvider.updateImagesA(files);

    _legacyState.update(() {
      _legacyState.tempImageFilesA.clear();
      _legacyState.tempImageFilesA.addAll(files);
    });
  }

  /// 임시 이미지 파일 업데이트 - B박스
  void updateTempImagesB(List<File> files) {
    _cleanProvider.updateImagesB(files);

    _legacyState.update(() {
      _legacyState.tempImageFilesB.clear();
      _legacyState.tempImageFilesB.addAll(files);
    });
  }

  /// 텍스트 업데이트 - 제목
  void updateTitle(String title) {
    _cleanProvider.updateTitle(title);
    _legacyState.update(() {
      _legacyState.questionTitle = title;
    });
  }

  /// 텍스트 업데이트 - 설명
  void updateDescription(String description) {
    _cleanProvider.updateDescription(description);
    _legacyState.update(() {
      _legacyState.questionDescription = description;
    });
  }

  /// 텍스트 업데이트 - A박스
  void updateTextA(String text) {
    _cleanProvider.updateTextA(text);
    _legacyState.update(() {
      _legacyState.uploadTextA = text;
    });
  }

  /// 텍스트 업데이트 - B박스
  void updateTextB(String text) {
    _cleanProvider.updateTextB(text);
    _legacyState.update(() {
      _legacyState.uploadTextB = text;
    });
  }

  /// Aspect Ratio 업데이트 - A박스
  void updateAspectRatiosA(List<double> ratios) {
    // Clean Architecture에서는 내부적으로 관리
    // 레거시만 업데이트
    _legacyState.update(() {
      _legacyState.uploadImageAspectRatioA.clear();
      _legacyState.uploadImageAspectRatioA.addAll(ratios);
    });
  }

  /// Aspect Ratio 업데이트 - B박스
  void updateAspectRatiosB(List<double> ratios) {
    _legacyState.update(() {
      _legacyState.uploadImageAspectRatioB.clear();
      _legacyState.uploadImageAspectRatioB.addAll(ratios);
    });
  }

  /// Legacy AppState의 데이터를 CreatePostProviderV2로 동기화
  void syncLegacyToClean() {
    // 텍스트 필드 동기화
    if (_legacyState.questionTitle.isNotEmpty) {
      _cleanProvider.updateTitle(_legacyState.questionTitle);
    }
    if (_legacyState.questionDescription.isNotEmpty) {
      _cleanProvider.updateDescription(_legacyState.questionDescription);
    }
    if (_legacyState.uploadTextA.isNotEmpty) {
      _cleanProvider.updateTextA(_legacyState.uploadTextA);
    }
    if (_legacyState.uploadTextB.isNotEmpty) {
      _cleanProvider.updateTextB(_legacyState.uploadTextB);
    }

    // 이미지 동기화 (임시 파일 우선, 없으면 업로드된 URL 사용)
    if (_legacyState.tempImageFilesA.isNotEmpty) {
      _cleanProvider.updateImagesA(_legacyState.tempImageFilesA);
    } else if (_legacyState.uploadImageA.isNotEmpty) {
      final files = _legacyState.uploadImageA.map((url) => File(url)).toList();
      _cleanProvider.updateImagesA(files);
    }

    if (_legacyState.tempImageFilesB.isNotEmpty) {
      _cleanProvider.updateImagesB(_legacyState.tempImageFilesB);
    } else if (_legacyState.uploadImageB.isNotEmpty) {
      final files = _legacyState.uploadImageB.map((url) => File(url)).toList();
      _cleanProvider.updateImagesB(files);
    }
  }

  /// 익명 모드 토글
  void toggleAnonymous() {
    _cleanProvider.toggleAnonymous();
    // 레거시에는 익명 필드가 없으면 추가 필요
  }

  /// 싱글 모드 토글
  void toggleSingleMode() {
    _cleanProvider.toggleSingleMode();
    // 레거시 상태 업데이트 필요시 추가
  }

  /// 타겟 오디언스 설정
  void setTargetAudience(Map<String, dynamic> targetAudience) {
    // Clean Architecture에서는 TargetAudience 객체 사용
    // 레거시에서는 targetAudienceData 필드 사용
    _legacyState.update(() {
      // AppState에 targetAudience 필드가 없으므로 임시로 저장
      // TODO: AppState에 targetAudience 필드 추가 필요
    });
  }

  /// 상태 동기화 - Clean → Legacy
  void syncToLegacy() {
    final formData = _cleanProvider.formData;

    _legacyState.update(() {
      _legacyState.questionTitle = formData.title;
      _legacyState.questionDescription = formData.description;
      _legacyState.uploadTextA = formData.textA;
      _legacyState.uploadTextB = formData.textB;

      // 이미지는 이미 업로드된 URL이 있을 때만 동기화
      if (_legacyState.uploadImageA.isEmpty && formData.imagesA.isNotEmpty) {
        _legacyState.tempImageFilesA.clear();
        _legacyState.tempImageFilesA.addAll(formData.imagesA);
      }

      if (_legacyState.uploadImageB.isEmpty && formData.imagesB.isNotEmpty) {
        _legacyState.tempImageFilesB.clear();
        _legacyState.tempImageFilesB.addAll(formData.imagesB);
      }
    });
  }

  /// 상태 동기화 - Legacy → Clean
  void syncFromLegacy() {
    _cleanProvider.updateTitle(_legacyState.questionTitle);
    _cleanProvider.updateDescription(_legacyState.questionDescription);
    _cleanProvider.updateTextA(_legacyState.uploadTextA);
    _cleanProvider.updateTextB(_legacyState.uploadTextB);

    // 임시 파일이 있으면 사용, 없으면 업로드된 URL 사용
    if (_legacyState.tempImageFilesA.isNotEmpty) {
      _cleanProvider.updateImagesA(_legacyState.tempImageFilesA);
    } else if (_legacyState.uploadImageA.isNotEmpty) {
      final files = _legacyState.uploadImageA
          .map((url) => File(url))
          .toList();
      _cleanProvider.updateImagesA(files);
    }

    if (_legacyState.tempImageFilesB.isNotEmpty) {
      _cleanProvider.updateImagesB(_legacyState.tempImageFilesB);
    } else if (_legacyState.uploadImageB.isNotEmpty) {
      final files = _legacyState.uploadImageB
          .map((url) => File(url))
          .toList();
      _cleanProvider.updateImagesB(files);
    }
  }

  /// 모든 데이터 클리어
  void clearAll() {
    _cleanProvider.resetForm();

    _legacyState.update(() {
      _legacyState.uploadImageA.clear();
      _legacyState.uploadImageB.clear();
      _legacyState.tempImageFilesA.clear();
      _legacyState.tempImageFilesB.clear();
      _legacyState.uploadImageAspectRatioA.clear();
      _legacyState.uploadImageAspectRatioB.clear();
      _legacyState.questionTitle = '';
      _legacyState.questionDescription = '';
      _legacyState.uploadTextA = '';
      _legacyState.uploadTextB = '';
    });
  }

  /// 레거시 메서드 - 점진적으로 제거 예정
  @Deprecated('Use updateImagesA instead')
  void legacyUpdateImagesA(List<String> urls) {
    _legacyState.update(() {
      _legacyState.uploadImageA.clear();
      _legacyState.uploadImageA.addAll(urls);
    });
  }

  @Deprecated('Use updateImagesB instead')
  void legacyUpdateImagesB(List<String> urls) {
    _legacyState.update(() {
      _legacyState.uploadImageB.clear();
      _legacyState.uploadImageB.addAll(urls);
    });
  }

  /// 유효성 검사 상태 가져오기
  bool get canSubmit => _cleanProvider.canSubmit;
  bool get isLoading => _cleanProvider.isLoading;
  String? get errorMessage => _cleanProvider.errorMessage;
  double get uploadProgress => _cleanProvider.uploadProgress;

  /// MediaContent를 PostOption으로 변환하는 helper 메서드
  PostOption _mediaContentToPostOption(MediaContent mediaContent) {
    return PostOption(
      text: mediaContent.text,
      imageUrls: mediaContent.imageUrls,
      videoUrls: mediaContent.videoUrl.isNotEmpty ? [mediaContent.videoUrl] : null,
      aspectRatios: mediaContent.aspectRatio != null ? [mediaContent.aspectRatio!] : [],
      metadata: {
        'mediaType': mediaContent.mediaType,
        'layoutType': mediaContent.layoutType,
        'thumbnailUrl': mediaContent.thumbnailUrl,
        if (mediaContent.youtubeUrl.isNotEmpty) 'youtubeUrl': mediaContent.youtubeUrl,
        if (mediaContent.duration != null) 'duration': mediaContent.duration,
        if (mediaContent.fileSize != null) 'fileSize': mediaContent.fileSize,
        if (mediaContent.dimensions.isNotEmpty) 'dimensions': mediaContent.dimensions,
      },
    );
  }

  /// Legacy State를 PostCreation 도메인 모델로 변환 (Phase 4)
  PostCreation createPostFromLegacyState() {
    // 옵션 A 미디어 컨텐츠 생성
    final mediaContentA = MediaContent(
      text: _legacyState.uploadTextA,
      imageUrls: _legacyState.uploadImageA,
      videoUrl: '', // 비디오는 나중에 추가
      aspectRatio: _legacyState.uploadImageAspectRatioA.isNotEmpty
          ? _legacyState.uploadImageAspectRatioA.first
          : 1.0,
    );

    // 옵션 B 미디어 컨텐츠 생성
    final mediaContentB = MediaContent(
      text: _legacyState.uploadTextB,
      imageUrls: _legacyState.uploadImageB,
      videoUrl: '',
      aspectRatio: _legacyState.uploadImageAspectRatioB.isNotEmpty
          ? _legacyState.uploadImageAspectRatioB.first
          : 1.0,
    );

    // MediaContent를 PostOption으로 변환
    final optionA = _mediaContentToPostOption(mediaContentA);
    final optionB = _mediaContentToPostOption(mediaContentB);

    // 현재 사용자 정보 (TODO: 실제 사용자 정보 연동 필요)
    const userId = 'test_user';
    const displayName = 'Test User';
    const photoUrl = 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/test-o1k5j9/assets/48cr6evvqdtw/Frame_5.png';

    // 통계 데이터 초기화
    final stats = PostStats(
      participantCount: 0,
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      shareCount: 0,
      commentCount: 0,
    );

    // PostCreation 모델 생성
    return PostCreation(
      id: '', // Firestore에서 자동 생성될 예정
      userId: userId,
      title: _legacyState.questionTitle,
      description: _legacyState.questionDescription,
      optionA: optionA,
      optionB: optionB,
      createdAt: DateTime.now(),
      status: PostStatus.draft,
      likeCount: stats.likeCount ?? 0,
      commentCount: stats.commentCount ?? 0,
      voteConfig: VoteConfiguration(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 24)),
        allowAnonymous: false,
      ),
      isAnonymous: false, // 기본값
      category: 'general', // 기본 카테고리
      tags: [], // 태그는 나중에 추가
      metadata: {
        'creatorInfo': {
          'displayName': displayName,
          'photoUrl': photoUrl,
        },
        'stats': {
          'viewCount': stats.viewCount,
          'shareCount': stats.shareCount,
        },
        'targetAudience': {
          'mode': 'public', // 기본 공개 모드
        },
      },
    );
  }
}