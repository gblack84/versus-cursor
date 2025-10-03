# Creation Feature - 사용 가이드 & 아키텍처

## 🏗️ 아키텍처 개요

### Clean Architecture v4.0 구조
```
lib/features/creation/
├── domain/              # 비즈니스 규칙 (독립적)
│   ├── models/         # 도메인 엔티티
│   │   ├── aggregates/   # PostCreation (Aggregate Root)
│   │   ├── core/         # PostCore, PostContent
│   │   └── value_objects/ # TargetAudience, MediaInfo
│   ├── repositories/   # Repository 인터페이스
│   │   ├── i_post_creation_repository_v2.dart
│   │   └── i_media_repository.dart
│   ├── usecases/      # 비즈니스 로직
│   │   ├── create_post_usecase.dart
│   │   ├── moderate_content_usecase.dart
│   │   ├── validate_post_usecase.dart
│   │   └── audience/
│   ├── services/      # 도메인 서비스 (인터페이스)
│   └── failures/      # 도메인 예외 (Phase 3)
│
├── data/               # 데이터 레이어
│   ├── repositories/   # Repository 구현체
│   │   ├── post_creation_repository_v2_impl.dart
│   │   └── media_repository_impl.dart
│   ├── datasources/   # 원격/로컬 데이터 소스
│   │   ├── firebase_post_creation_datasource.dart
│   │   └── firebase_storage_datasource.dart
│   ├── dto/          # Data Transfer Objects
│   │   ├── post_creation_dto.dart
│   │   └── target_audience_dto.dart
│   └── mappers/      # 데이터 변환
│       ├── creation_firestore_mapper.dart
│       └── post_creation_mapper.dart
│
├── presentation/       # UI 레이어
│   ├── providers/     # 상태 관리 (Phase 5)
│   │   ├── create_post_provider_v2.dart
│   │   └── media/
│   │       ├── media_state_coordinator.dart
│   │       ├── media_selection_provider.dart
│   │       ├── media_upload_provider.dart
│   │       └── media_validation_provider.dart
│   ├── screens/       # 화면 위젯
│   │   └── create_post/
│   │       ├── create_post_screen.dart
│   │       └── pro_image_editor_page.dart
│   ├── widgets/       # UI 컴포넌트
│   │   ├── create_post/
│   │   ├── media/
│   │   └── dialogs/
│   └── constants/     # UI 상수
│
└── docs/              # 문서
    ├── FEATURE_OVERVIEW.md
    ├── API_REFERENCE.md
    └── USAGE_GUIDE.md
```

### 계층 간 의존성 규칙
```
Presentation → Domain ← Data

✅ 허용:
- Presentation이 Domain 참조
- Data가 Domain 참조
- Presentation이 Provider 사용

❌ 금지:
- Domain이 다른 레이어 참조
- Presentation이 Data 직접 참조
- Domain이 Firebase 직접 참조
```

### Phase 5 MediaStateCoordinator 통합
```
CreatePostProviderV2
     ↓ (의존성 주입)
MediaStateCoordinator
     ↓ (통합 관리)
├── MediaSelectionProvider (파일 선택)
├── MediaUploadProvider (업로드)
└── MediaValidationProvider (검증)
```

## 🚀 빠른 시작

### 1. 의존성 설정
```yaml
# pubspec.yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.0
  cloud_firestore: ^5.5.0
  firebase_storage: ^12.3.2

  # 상태 관리
  provider: ^6.1.2
  get_it: ^7.6.0

  # 이미지 처리
  wechat_assets_picker: ^9.5.1
  pro_image_editor: ^5.4.2
  cached_network_image: ^3.4.1

  # AI & 검열
  http: ^1.2.2  # Perspective API, Gemini AI

  # UI
  bot_toast: ^4.1.3
```

### 2. 초기화
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 의존성 주입 설정
  setupDependencies();

  // BotToast 초기화
  runApp(
    BotToastInit(
      child: MyApp(),
    ),
  );
}
```

### 3. GetIt 설정 (CreationModule)
```dart
// app/di/creation_module.dart
class CreationModule {
  static void registerDependencies() {
    final getIt = GetIt.instance;

    // Repositories
    getIt.registerLazySingleton<IPostCreationRepositoryV2>(
      () => PostCreationRepositoryV2Impl()
    );
    getIt.registerLazySingleton<IMediaRepository>(
      () => MediaRepositoryImpl()
    );

    // UseCases
    getIt.registerLazySingleton(() => CreatePostUseCase(
      postRepository: getIt(),
      mediaRepository: getIt(),
      manageTargetAudienceUseCase: getIt(),
    ));
    getIt.registerLazySingleton(() => ModerateContentUseCase(getIt()));
    getIt.registerLazySingleton(() => ValidatePostUseCase(getIt()));

    // Phase 5: Media Providers
    getIt.registerFactory(() => MediaSelectionProvider());
    getIt.registerFactory(() => MediaUploadProvider());
    getIt.registerFactory(() => MediaValidationProvider());
    getIt.registerFactory(() => MediaStateCoordinator(
      selectionProvider: getIt(),
      uploadProvider: getIt(),
      validationProvider: getIt(),
    ));

    // Main Provider
    getIt.registerLazySingleton(() => CreatePostProviderV2(
      createPostUseCase: getIt(),
      moderateContentUseCase: getIt(),
      validatePostUseCase: getIt(),
      mediaCoordinator: getIt(),
    ));
  }
}
```

## 📖 사용 예제

### 기본 게시물 생성 구현
```dart
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final CreatePostProviderV2 _provider;

  @override
  void initState() {
    super.initState();
    _provider = CreationModule.getCreatePostProvider();
  }

  Future<void> _handleSubmit() async {
    // 1. 폼 유효성 검증
    final isValid = await _provider.validateFormFields();
    if (!isValid) {
      BotToast.showText(
        text: _provider.errorMessage ?? '모든 필수 항목을 입력해주세요',
        contentColor: Colors.red.shade600,
      );
      return;
    }

    // 2. 타겟 오디언스 다이얼로그 표시
    final targetAudience = await TargetAudienceDialog.show(context);
    if (targetAudience == null) return; // 사용자가 취소

    // 3. 게시물 생성
    try {
      await _provider.createPost(
        currentUserUid,
        targetAudience: targetAudience,
      );

      // 성공 - 이전 페이지로
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // 에러 처리는 아래 "에러 처리 패턴" 섹션 참조
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('질문 작성')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 텍스트 입력 위젯
            TextInputWidget(),

            // 이미지 선택 위젯
            ImageSelectionWidget(),

            // 제출 버튼
            Consumer<CreatePostProviderV2>(
              builder: (context, provider, _) {
                return NextButton(
                  showButton: provider.canSubmit,
                  onPressed: provider.canSubmit ? _handleSubmit : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 이미지 선택 및 업로드
```dart
class ImageSelectionExample extends StatelessWidget {
  Future<void> _selectImages(BuildContext context) async {
    // wechat_assets_picker 설정
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 4,
        requestType: RequestType.image,
        gridCount: 4,
        pickerTheme: ThemeData.dark(),
      ),
    );

    if (assets != null && assets.isNotEmpty) {
      // 파일 변환 및 Provider 업데이트
      final files = await _convertAssetsToFiles(assets);

      final provider = CreationModule.getCreatePostProvider();
      provider.updateImagesA(files);
    }
  }

  Future<List<File>> _convertAssetsToFiles(
    List<AssetEntity> assets
  ) async {
    final files = <File>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) files.add(file);
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectImages(context),
      child: Text('이미지 선택'),
    );
  }
}
```

### 이미지 편집 (ProImageEditor)
```dart
class ImageEditingExample extends StatelessWidget {
  Future<void> _editImage(
    BuildContext context,
    String imageUrl,
    int index,
  ) async {
    // 1. Firebase Storage URL에서 이미지 다운로드
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    // 2. ProImageEditor로 편집
    final editedBytes = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (_) => ProImageEditorPage(
          imageBytes: bytes,
          imageUrl: imageUrl,
        ),
      ),
    );

    if (editedBytes != null) {
      // 3. 편집된 이미지 업로드
      final tempFile = await _createTempFile(editedBytes);

      final provider = CreationModule.getCreatePostProvider();
      final coordinator = provider.mediaCoordinator;

      await coordinator.editAndUploadImage('A', index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () => _editImage(context, imageUrl, index),
    );
  }
}
```

### 타겟 오디언스 설정
```dart
class TargetAudienceExample extends StatelessWidget {
  Future<void> _showTargetAudienceDialog(BuildContext context) async {
    final audience = await TargetAudienceDialog.show(context);

    if (audience != null) {
      final provider = CreationModule.getCreatePostProvider();
      provider.updateTargetAudience(audience);
    }
  }

  // Quick Collection 모드 사용
  TargetAudience _createQuickCollection() {
    return TargetAudience(
      collectionType: 'quick',
      targetCount: 50,
    );
  }

  // Custom 모드 사용
  TargetAudience _createCustomAudience() {
    return TargetAudience(
      collectionType: 'custom',
      targetCount: 30,
      selectedInterests: ['technology', 'sports'],
      selectedAgeGroup: '20-29',
      selectedGender: 'all',
      activeUserOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showTargetAudienceDialog(context),
      child: Text('타겟 오디언스 설정'),
    );
  }
}
```

### AI 콘텐츠 검열 처리
```dart
class ModerationExample extends StatelessWidget {
  Future<void> _handleModeration() async {
    final provider = CreationModule.getCreatePostProvider();

    // 1. 텍스트 검열 (Perspective API)
    final textResult = await provider.validateField(
      'title',
      titleController.text,
    );

    if (textResult.toxicity > 0.7) {
      BotToast.showText(
        text: '부적절한 표현이 포함되어 있습니다',
        contentColor: Colors.red.shade600,
      );
      return;
    }

    // 2. 이미지 검열 (Cloud Vision + Gemini AI)
    // createPost() 호출 시 자동으로 실행됨
    try {
      await provider.createPost(userId);
    } on AIModerationFailure catch (e) {
      // AI 검열 거부
      BotToast.showText(
        text: e.getUserMessage(),
        contentColor: Colors.red.shade600,
      );
    } on MediaProcessingFailure catch (e) {
      // 이미지 처리 실패
      BotToast.showText(
        text: e.getUserMessage(),
        contentColor: Colors.red.shade600,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleModeration,
      child: Text('검열 및 생성'),
    );
  }
}
```

## 🔄 상태 관리 패턴

### ChangeNotifier 패턴 (Phase 5)
```dart
// CreatePostProviderV2 상태 감시
class PostCreationStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProviderV2>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator(
            value: provider.uploadProgress,
          );
        }

        if (provider.errorMessage != null) {
          return Text(
            provider.errorMessage!,
            style: TextStyle(color: Colors.red),
          );
        }

        return Text('준비됨: ${provider.canSubmit}');
      },
    );
  }
}
```

### MediaStateCoordinator 패턴 (Phase 5)
```dart
// 통합 미디어 상태 관리
class MediaStateExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = CreationModule.getCreatePostProvider();
    final coordinator = provider.mediaCoordinator;

    return Column(
      children: [
        // A박스 이미지 목록
        ...coordinator.getImagesA().map((url) =>
          CachedNetworkImage(imageUrl: url)
        ),

        // 업로드 진행률
        LinearProgressIndicator(
          value: coordinator.getUploadProgress(),
        ),

        // 업로드 완료 여부
        if (coordinator.areAllImagesUploaded())
          Text('모든 이미지 업로드 완료'),
      ],
    );
  }
}
```

### MultiProvider 패턴
```dart
// create_post_screen.dart
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      // Phase 5: MediaStateCoordinator 통합된 Provider
      ChangeNotifierProvider(
        create: (_) => CreationModule.getCreatePostProvider(),
      ),
      // Phase 5: MediaSelectionProvider (UI 상태 관리용)
      ChangeNotifierProvider(
        create: (_) => CreationModule.getMediaSelectionProvider(),
      ),
      // Phase 5: MediaValidationProvider (검증 상태 관리용)
      ChangeNotifierProvider(
        create: (_) => CreationModule.getMediaValidationProvider(),
      ),
    ],
    child: Scaffold(/* ... */),
  );
}
```

## 🛠️ 고급 기능

### 스마트 레이아웃 시스템 활용
```dart
class SmartLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = CreationModule.getCreatePostProvider();
    final coordinator = provider.mediaCoordinator;

    // 이미지 비율 자동 분석
    final ratiosA = coordinator.getAspectRatiosA();
    final ratiosB = coordinator.getAspectRatiosB();

    // AspectRatioAnalyzer로 최적 레이아웃 결정
    final layoutType = AspectRatioAnalyzer.determineOptimalLayout(
      aspectRatiosA: ratiosA,
      aspectRatiosB: ratiosB,
    );

    // DynamicBoxCalculator로 박스 크기 계산
    final boxSizes = DynamicBoxCalculator.calculate(
      layoutType: layoutType,
      aspectRatiosA: ratiosA,
      aspectRatiosB: ratiosB,
      containerWidth: MediaQuery.of(context).size.width,
      containerHeight: 400,
    );

    return Column(
      children: [
        // 레이아웃 타입 표시
        Text('레이아웃: ${layoutType.toString()}'),

        // 동적 박스 크기 적용
        SizedBox(
          width: boxSizes.boxWidthA,
          height: boxSizes.boxHeightA,
          child: MediaSelectionBox(/* ... */),
        ),
      ],
    );
  }
}
```

### 커스텀 에러 처리 (Phase 3)
```dart
class CreationErrorHandler {
  static void handleError(Object error, BuildContext context) {
    String errorMessage = '포스트 생성 중 오류가 발생했습니다';

    if (error is FirestoreWriteFailure) {
      errorMessage = error.getUserMessage();
      // '데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.'
    } else if (error is AIModerationFailure) {
      errorMessage = error.getUserMessage();
      // 'AI 검열에서 다음 문제가 감지되었습니다: 선정적 콘텐츠, 폭력적 내용'
    } else if (error is MediaProcessingFailure) {
      errorMessage = error.getUserMessage();
      // '이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.'
    } else if (error is PostValidationFailure) {
      errorMessage = error.getUserMessage();
      // '필수 항목을 입력해주세요: 제목, 설명'
    } else if (error is NetworkFailure) {
      errorMessage = '인터넷 연결을 확인하고 다시 시도해주세요';
    }

    BotToast.showText(
      text: errorMessage,
      duration: const Duration(seconds: 3),
      contentColor: Colors.red.shade600,
      textStyle: const TextStyle(color: Colors.white),
    );
  }
}

// 사용 예제
try {
  await provider.createPost(userId, targetAudience: audience);
} catch (e) {
  CreationErrorHandler.handleError(e, context);
}
```

### 배치 이미지 업로드 최적화
```dart
class BatchUploadExample extends StatelessWidget {
  Future<void> _batchUploadImages(List<File> files) async {
    // MediaUploadService 병렬 업로드 활용
    final uploadResults = await Future.wait(
      files.map((file) => _uploadSingleImage(file)),
    );

    // 업로드 직후 프리캐싱
    for (final url in uploadResults) {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      );
    }

    print('업로드 완료: ${uploadResults.length}개 이미지');
  }

  Future<String> _uploadSingleImage(File file) async {
    final repository = GetIt.instance<IMediaRepository>();
    final urls = await repository.uploadImages([file]);
    return urls.first;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _batchUploadImages(selectedFiles),
      child: Text('일괄 업로드'),
    );
  }
}
```

### 테스트 모드 (Admin/Tester)
```dart
// 개발/테스트용 빠른 게시물 생성
class TestPostCreation extends StatelessWidget {
  Future<void> _createTestPost() async {
    final provider = CreationModule.getCreatePostProvider();

    provider.updateTitle('테스트 질문 ${DateTime.now()}');
    provider.updateDescription('테스트 설명');
    provider.updateTextA('옵션 A');
    provider.updateTextB('옵션 B');

    // Test 모드 타겟 오디언스
    final testAudience = TargetAudience(
      collectionType: 'test',
      targetCount: 1,
    );

    await provider.createPost(
      currentUserUid,
      targetAudience: testAudience,
    );

    print('테스트 게시물 생성 완료');
  }

  @override
  Widget build(BuildContext context) {
    return kDebugMode
      ? ElevatedButton(
          onPressed: _createTestPost,
          child: Text('테스트 게시물 생성'),
        )
      : SizedBox.shrink();
  }
}
```

## 🔐 보안 고려사항

### 1. AI 검열 시스템
- **3단계 검증**: Perspective API (텍스트) → Cloud Vision (이미지) → Gemini AI (로직)
- **얼굴 평가 BLOCK**: 얼굴 평가 관련 콘텐츠 자동 차단
- **신뢰도 기반 거부**: confidenceScore 0.7 이상 시 거부
- **상세 거부 사유**: detectedCategories로 구체적 피드백

### 2. 이미지 보안
- **3단계 리사이징**: original, display (800px), thumbnail (150px)
- **JPEG 압축**: 85% 품질로 최적화
- **Firebase Storage 보안**: 사용자별 경로 분리 (`user_uploads/{userId}/`)
- **URL 만료 처리**: Firestore에 영구 URL 저장

### 3. 타겟 오디언스 보안
- **역할 검증**: Admin/Tester 역할 확인 (Test 모드)
- **중복 알림 방지**: NotificationManager 큐 시스템
- **AI 매칭 안전성**: Gemini AI로 부적절한 타게팅 차단

### 4. 데이터 보호
- **Firestore Security Rules**: 사용자별 읽기/쓰기 권한 제어
- **HTTPS 통신**: 모든 Firebase 통신 암호화
- **민감 정보 암호화**: 사용자 정보 암호화 저장

## 🧪 테스트

### 단위 테스트
```dart
// test/creation/create_post_usecase_test.dart
void main() {
  group('CreatePostUseCase Tests', () {
    late CreatePostUseCase useCase;
    late MockPostRepository mockPostRepository;
    late MockMediaRepository mockMediaRepository;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockMediaRepository = MockMediaRepository();
      useCase = CreatePostUseCase(
        postRepository: mockPostRepository,
        mediaRepository: mockMediaRepository,
        manageTargetAudienceUseCase: mockAudienceUseCase,
      );
    });

    test('게시물 생성 성공 테스트', () async {
      // Arrange
      final dto = PostCreationDto(
        userId: 'test_user',
        title: 'Test Title',
        description: 'Test Description',
        imagesA: [testImageFile],
      );

      when(mockPostRepository.createPost(any, any))
        .thenAnswer((_) async => 'test_post_id');

      // Act
      final result = await useCase.execute(dto: dto);

      // Assert
      expect(result.isSuccess, true);
      expect(result.valueOrNull?.id, 'test_post_id');
    });

    test('유효성 검증 실패 테스트', () async {
      // Arrange
      final dto = PostCreationDto(
        userId: 'test_user',
        title: '', // 빈 제목
        description: 'Test Description',
      );

      // Act
      final result = await useCase.execute(dto: dto);

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<CreationValidationFailure>());
    });
  });
}
```

### 통합 테스트
```dart
// integration_test/creation_flow_test.dart
void main() {
  testWidgets('전체 게시물 생성 플로우 테스트', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // CreatePostScreen 진입
    await tester.tap(find.text('질문 작성'));
    await tester.pumpAndSettle();

    // 제목 입력
    await tester.enterText(
      find.byKey(Key('title_field')),
      'Test Question Title',
    );

    // 설명 입력
    await tester.enterText(
      find.byKey(Key('description_field')),
      'Test Description',
    );

    // A 옵션 텍스트 입력
    await tester.enterText(
      find.byKey(Key('textA_field')),
      'Option A',
    );

    // B 옵션 텍스트 입력
    await tester.enterText(
      find.byKey(Key('textB_field')),
      'Option B',
    );

    // 다음 버튼 탭
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // 타겟 오디언스 다이얼로그 확인
    expect(find.text('타겟 오디언스 설정'), findsOneWidget);

    // Quick Collection 선택
    await tester.tap(find.text('Quick Collection'));
    await tester.pumpAndSettle();

    // 확인 버튼
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 성공 확인 (이전 페이지로 돌아감)
    expect(find.text('질문 작성'), findsNothing);
  });
}
```

### 위젯 테스트
```dart
// test/creation/widgets/media_selection_box_test.dart
void main() {
  testWidgets('MediaSelectionBox 렌더링 테스트', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaSelectionBox(
            box: 'A',
            images: ['https://example.com/image.jpg'],
            aspectRatios: [1.5],
            layoutType: 'horizontal',
          ),
        ),
      ),
    );

    // 이미지 위젯 확인
    expect(find.byType(CachedNetworkImage), findsOneWidget);

    // 액션 아이콘 확인
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate), findsOneWidget);
  });
}
```

## 🚀 배포 체크리스트

### 개발 환경
- [ ] Firebase 프로젝트 생성
- [ ] Firestore 활성화
- [ ] Firebase Storage 활성화
- [ ] Firebase Functions 배포
- [ ] Perspective API 키 설정
- [ ] Gemini AI API 키 설정
- [ ] Cloud Vision API 활성화

### 프로덕션 준비
- [ ] API 키 환경변수 설정
- [ ] Firestore Security Rules 배포
- [ ] Storage Rules 배포
- [ ] AI 검열 임계값 조정
- [ ] 이미지 용량 제한 설정
- [ ] 에러 로깅 구성 (Sentry)
- [ ] 분석 도구 연동 (Firebase Analytics)

### 성능 최적화
- [ ] 이미지 프리캐싱 활성화
- [ ] 병렬 업로드 설정
- [ ] memCacheWidth 최적화
- [ ] 디버그 로그 제거
- [ ] 스마트 레이아웃 캐싱 활성화

### 플랫폼별 설정
- [ ] iOS: Info.plist 카메라/갤러리 권한
- [ ] Android: AndroidManifest.xml 권한
- [ ] Web: CORS 설정
- [ ] macOS: 파일 접근 권한

## 📚 추가 리소스

### 공식 문서
- [Firebase Firestore 문서](https://firebase.google.com/docs/firestore)
- [Firebase Storage 문서](https://firebase.google.com/docs/storage)
- [Perspective API 문서](https://developers.perspectiveapi.com/)
- [Gemini AI 문서](https://ai.google.dev/gemini-api/docs)
- [ProImageEditor 문서](https://pub.dev/packages/pro_image_editor)
- [wechat_assets_picker 문서](https://pub.dev/packages/wechat_assets_picker)

### 프로젝트 문서
- [Feature Overview](./FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](./API_REFERENCE.md) - API 상세 명세
- [CLAUDE.md](/CLAUDE.md) - 프로젝트 전체 가이드

### Architecture 가이드
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Result Pattern in Dart](https://pub.dev/packages/result_dart)

### 문의 및 지원
- 이슈 트래커: GitHub Issues
- 이메일: support@versusspace.com
- 디스코드: VersusSpace 개발자 채널
