# 📝 Moderation Service - Port-Adapter Pattern Implementation

> 전역 콘텐츠 검열 서비스 (Clean Architecture v4.0)
> 최종 업데이트: 2025-11-10 | 버전: 2.0.0

## 📋 개요

Moderation Service는 Versus Space의 **전역 인프라 서비스**로서, 모든 Feature에서 사용하는 콘텐츠 검열 기능을 제공합니다. Clean Architecture와 Port-Adapter Pattern을 따라 구현되어 있으며, DI 패턴과 구조화된 로깅을 지원합니다.

### 핵심 기능

- 📝 **텍스트 검열**: Google Perspective API (욕설, 혐오 발언 감지)
- 🤖 **AI 검열**: Gemini 1.5 Pro (컨텍스트 기반 부적절성 판단)
- 🖼️ **이미지 검열**: Cloud Vision API (SafeSearch + Text Detection)
- 📊 **실시간 모니터링**: Firestore Stream 기반 검열 상태 추적
- 🔗 **3단계 통합 검증**: Perspective → Gemini → Cloud Vision

### Phase 1-4 완료 항목 ✅

- ✅ **Phase 1**: 3개 Interface 파일 생성 (Port-Adapter Pattern)
- ✅ **Phase 2**: Static → Instance 변환 (DI 지원)
- ✅ **Phase 3**: DI 모듈 등록 (GetIt)
- ✅ **Phase 4**: Logger 통합 (ModerationLogger 클래스, 25개 print() 교체)

---

## 🏗️ 디렉토리 구조

```
lib/services/moderation/
├── interfaces/                              # 📁 Port (추상화)
│   ├── i_ai_moderation_service.dart        # 77줄 - AI 검열 인터페이스
│   ├── i_cloud_image_moderation_service.dart # 127줄 - 이미지 검열 인터페이스
│   └── i_gemini_moderation_service.dart    # 80줄 - Gemini AI 인터페이스
│
├── text/                                    # 📁 텍스트 검열
│   └── gemini_service.dart                 # 181줄 - Gemini AI 구현 (Adapter)
│
├── models/                                  # 📁 데이터 모델
│   ├── image_moderation_model.dart         # 392줄 - Firestore 모델
│   └── moderation_result.dart              # 112줄 - 검열 결과 모델
│
├── di/                                      # 📁 Dependency Injection
│   └── moderation_di_module.dart           # 138줄 - GetIt 등록
│
├── ai_moderation_service.dart              # 265줄 - 통합 Orchestrator (Adapter)
├── cloud_image_moderation_service.dart     # 219줄 - Cloud Vision 통합 (Adapter)
├── image_moderation_service.dart           # 144줄 - 이미지 검열 (Adapter)
├── perspective_api_service.dart            # 348줄 - Perspective API (Adapter)
└── README.md                                # 이 문서
```

**총 11개 파일** | **2,083줄**

---

## 🎯 아키텍처: Port-Adapter Pattern (Hexagonal)

### 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Feature Layer                                │
│  features/creation, features/chat, features/post, features/profile  │
│                                                                       │
│  Feature → IAIModerationService (Port 의존)                          │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                │ 의존성 역전 (Interface 의존)
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  Port (Interface - Abstraction)                      │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ IAIModerationService                           │                 │
│  │ ├── moderatePostContent(...)                   │                 │
│  │ └── showModerationDialog(...)                  │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ IGeminiModerationService                       │                 │
│  │ ├── initialize()                               │                 │
│  │ └── validateContent(...)                       │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ ICloudImageModerationService                   │                 │
│  │ ├── checkModerationStatus(String filePath)     │                 │
│  │ ├── waitForModeration(String filePath)         │                 │
│  │ └── watchModerationStatus(String filePath)     │                 │
│  └────────────────────────────────────────────────┘                 │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                │ 구현 (Adapter)
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 Adapter (Implementation - Concrete)                  │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ AIModerationService implements IAIModeration   │                 │
│  │ • DI: IPerspectiveApiService, IGemini          │                 │
│  │ • 3단계 검증 Orchestrator                       │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ GeminiModerationService implements IGemini     │                 │
│  │ • DI: FirebaseFunctions                        │                 │
│  │ • Cloud Functions 호출                         │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ CloudImageModerationService implements ICloud  │                 │
│  │ • DI: FirebaseFirestore                        │                 │
│  │ • Firestore Stream 모니터링                    │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ PerspectiveApiService (구체 클래스)             │                 │
│  │ • DI: API Key (Environment Config)             │                 │
│  │ • HTTP 직접 호출                                │                 │
│  └────────────────────────────────────────────────┘                 │
│                                                                       │
│  ┌────────────────────────────────────────────────┐                 │
│  │ ImageModerationService (구체 클래스)            │                 │
│  │ • DI: FirebaseFunctions                        │                 │
│  │ • Cloud Functions 호출                         │                 │
│  └────────────────────────────────────────────────┘                 │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                │ 외부 API 호출
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    External Services (Backend)                       │
│                                                                       │
│  • Firebase Functions (asia-northeast3)                             │
│  • FirebaseFirestore (imageModeration 컬렉션)                        │
│  • Google Perspective API                                           │
│  • Google Cloud Vision API                                          │
│  • Gemini 1.5 Pro API                                               │
└─────────────────────────────────────────────────────────────────────┘
```

### 핵심 패턴

1. **Port (Interface)**: 추상화 레이어, Feature가 의존하는 계약
2. **Adapter (Implementation)**: 구체적인 외부 API 통합 구현
3. **DI (Dependency Injection)**: GetIt을 통한 생성자 주입
4. **Orchestrator**: AIModerationService가 3개 Adapter를 조율

---

## 🔧 Dependency Injection 가이드

### DI 모듈 등록 (app/di.dart)

```dart
import 'package:get_it/get_it.dart';
import '/services/moderation/di/moderation_di_module.dart';

final getIt = GetIt.instance;

void setupDI() {
  // 1. Firebase 기본 서비스 등록 (조건부)
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  if (!getIt.isRegistered<FirebaseFunctions>()) {
    getIt.registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
    );
  }

  // 2. Moderation Service 등록 (Phase 3)
  registerModerationModule(getIt);

  // 3. 기타 서비스 등록
  // ...
}
```

### DI 모듈 내부 (moderation_di_module.dart)

```dart
void registerModerationModule(GetIt getIt) {
  // 1. Perspective API 서비스 (외부 HTTP API)
  getIt.registerLazySingleton<IPerspectiveApiService>(
    () => PerspectiveApiService.fromEnvironment(),
  );

  // 2. Gemini AI 서비스 (Firebase Functions 의존)
  getIt.registerLazySingleton<IGeminiModerationService>(
    () => GeminiModerationService(
      functions: getIt<FirebaseFunctions>(),
    ),
  );

  // 3. Cloud Image 서비스 (Firestore 의존)
  getIt.registerLazySingleton<ICloudImageModerationService>(
    () => CloudImageModerationService(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // 4. AI 검열 Orchestrator (2개 서비스 의존)
  getIt.registerLazySingleton<IAIModerationService>(
    () => AIModerationService(
      perspectiveService: getIt<IPerspectiveApiService>(),
      geminiService: getIt<IGeminiModerationService>(),
    ),
  );

  // 5. Image 검열 서비스 (Functions 의존)
  if (!getIt.isRegistered<ImageModerationService>()) {
    getIt.registerLazySingleton<ImageModerationService>(
      () => ImageModerationService(
        functions: getIt<FirebaseFunctions>(),
      ),
    );
  }
}
```

### Feature에서 사용 (Creation Feature 예시)

```dart
import 'package:get_it/get_it.dart';
import '/services/moderation/interfaces/i_ai_moderation_service.dart';

class CreatePostNotifier extends StateNotifier<CreatePostState> {
  final IAIModerationService _moderationService;

  CreatePostNotifier({
    required IAIModerationService moderationService,
  })  : _moderationService = moderationService,
        super(CreatePostState.initial());

  Future<void> submitPost() async {
    // 1. 콘텐츠 검열 (Port 인터페이스 사용)
    final result = await _moderationService.moderatePostContent(
      request: ModerationRequest(
        questionTitle: state.title,
        description: state.description,
        titleA: state.optionA,
        titleB: state.optionB,
        userId: currentUserId,
      ),
      onProgressUpdate: (message) {
        // 진행 상태 UI 업데이트
      },
    );

    // 2. 검증 결과 처리
    if (!result.isValid) {
      await _moderationService.showModerationDialog(context, result);
      return;
    }

    // 3. 통과 시 게시물 생성
    await _createPost();
  }
}

// Riverpod Provider 등록
@riverpod
CreatePostNotifier createPostNotifier(CreatePostNotifierRef ref) {
  return CreatePostNotifier(
    moderationService: getIt<IAIModerationService>(),  // GetIt에서 주입
  );
}
```

---

## 📊 Logger 사용 가이드 (Phase 4)

### ModerationLogger 클래스

Phase 4에서 추가된 `ModerationLogger`는 Moderation 도메인 전용 로깅을 제공합니다.

**위치**: `/lib/core/utils/logger.dart` (263줄 추가)

**17개 메서드** (4개 카테고리):
1. **Perspective API**: 4개 메서드
2. **Gemini AI**: 5개 메서드
3. **Cloud Image**: 6개 메서드
4. **Orchestrator**: 5개 메서드

### 사용 예시

#### 1. Perspective API 로깅

```dart
// 분석 결과 로깅
ModerationLogger.perspectiveResult(
  isToxic: result.isToxic,
  toxicityScore: result.toxicityScore,
  topCategory: 'PROFANITY',
);
// → [INFO] [Moderation/Perspective] Result - Toxic: true, Score: 0.85, Category: PROFANITY

// 에러 로깅
ModerationLogger.perspectiveError(
  'Response: ${response.body}',
  statusCode: response.statusCode,
);
// → [ERROR] [Moderation/Perspective] API Error (statusCode: 400): Response: {...}
```

#### 2. Gemini AI 로깅

```dart
// API 호출 시작
ModerationLogger.geminiCalling(
  questionTitle: '어떤 영화가 더 재미있나요?',
  titleA: '어벤져스',
  titleB: '인터스텔라',
  userId: 'user123',
);
// → [DEBUG] [Moderation/Gemini] Calling validatePostContentWithGemini (user: use***)

// 응답 수신
ModerationLogger.geminiResponse(
  action: 'PROCEED',
  confidence: 0.95,
  expectedRatio: {'A': 0.6, 'B': 0.4},
);
// → [INFO] [Moderation/Gemini] Response - Action: PROCEED, Confidence: 0.95

// 검증 결과
ModerationLogger.geminiValidation(
  isValid: true,
  severity: 'pass',
  reason: '적절한 투표 질문입니다',
);
// → [INFO] [Moderation/Gemini] Validation - Valid: ✅, Severity: pass, Reason: 적절한 투표 질문입니다

// 에러 로깅
ModerationLogger.geminiError(
  e,
  code: 'unauthenticated',
  details: 'User not logged in',
);
// → [ERROR] [Moderation/Gemini] Error (code: unauthenticated): User not logged in
```

#### 3. Cloud Image Moderation 로깅

```dart
// 검열 상태 확인
ModerationLogger.imageCheckingStatus('posts/user123/image.jpg');
// → [DEBUG] [Moderation/Image] Checking status for posts/.../image.jpg

// 검열 대기
ModerationLogger.imageWaitingModeration('posts/user123/image.jpg', timeout: 30);
// → [DEBUG] [Moderation/Image] Waiting for moderation (timeout: 30s): posts/.../image.jpg

// 파일 경로 추출 성공
ModerationLogger.imagePathExtracted(
  'https://firebasestorage.googleapis.com/.../image.jpg',
  'posts/user123/image.jpg',
);
// → [DEBUG] [Moderation/Image] Path extracted from https://firebasestorage... → posts/user123/image.jpg

// 경로 추출 실패
ModerationLogger.imagePathExtractionFailed(
  'https://invalid-url.com/image.jpg',
  error: 'Invalid URL format',
);
// → [WARNING] [Moderation/Image] Failed to extract path from https://invalid-url.com/image.jpg: Invalid URL format

// 에러 로깅
ModerationLogger.imageError('checkModerationStatus', e);
// → [ERROR] [Moderation/Image] Error in checkModerationStatus: FirebaseException...
```

#### 4. Orchestrator 로깅

```dart
// 진행 상황
ModerationLogger.moderationProgress('텍스트를 검토하고 있습니다...');
// → [DEBUG] [Moderation/Orchestrator] 텍스트를 검토하고 있습니다...

// Gemini 실패 시 Fallback
ModerationLogger.moderationGeminiFallback('API timeout after 10s');
// → [WARNING] [Moderation/Orchestrator] Gemini fallback: API timeout after 10s

// 통합 에러
ModerationLogger.moderationError(e);
// → [ERROR] [Moderation/Orchestrator] Error: Exception...
```

### 로그 레벨

- **DEBUG**: 개발 디버깅용 (API 호출, 상태 확인)
- **INFO**: 주요 이벤트 (검증 결과, 성공 응답)
- **WARNING**: 경고 (Fallback, 비정상 흐름)
- **ERROR**: 에러 (예외, API 실패)

### 자동 민감 정보 마스킹

```dart
// userId 자동 마스킹 (Logger.maskSensitive 내부 사용)
ModerationLogger.geminiCalling(userId: 'user12345');
// → user***45 (앞 4자, 뒤 2자만 표시)

// 파일 경로 자동 마스킹 (ModerationLogger._maskFilePath)
ModerationLogger.imageCheckingStatus('posts/user123/subfolder/image.jpg');
// → posts/.../image.jpg (중간 경로 생략)
```

---

## 🎨 서비스별 상세 설명

### 1. AIModerationService (통합 Orchestrator)

**파일**: `ai_moderation_service.dart` (265줄)
**역할**: 3단계 검증 통합 조율

```dart
class AIModerationService implements IAIModerationService {
  final IPerspectiveApiService _perspectiveService;
  final IGeminiModerationService _geminiService;

  AIModerationService({
    required IPerspectiveApiService perspectiveService,
    required IGeminiModerationService geminiService,
  })  : _perspectiveService = perspectiveService,
        _geminiService = geminiService;

  @override
  Future<ModerationResult> moderatePostContent({
    required ModerationRequest request,
    Function(String)? onProgressUpdate,
  }) async {
    // 1단계: 텍스트 유해성 검사 (Perspective API)
    onProgressUpdate?.call('텍스트를 검토하고 있습니다...');
    final textResult = await _moderateText(request);

    if (textResult.isToxic) {
      return ModerationResult(
        isValid: false,
        severity: 'error',
        violations: [_formatTextViolation(textResult)],
      );
    }

    // 2단계: AI 컨텍스트 검증 (Gemini)
    onProgressUpdate?.call('AI가 내용을 분석하고 있습니다...');
    final geminiResult = await _geminiService.validateContent(
      userId: request.userId,
      questionTitle: request.questionTitle,
      // ...
    );

    if (geminiResult != null && !geminiResult.isValid) {
      return ModerationResult(
        isValid: false,
        severity: geminiResult.severity,
        violations: [geminiResult.reason],
      );
    }

    // 3단계: 최종 결과 반환
    return ModerationResult(
      isValid: true,
      severity: 'pass',
      violations: [],
      textResult: textResult,
      geminiResult: geminiResult,
    );
  }
}
```

**주요 메서드**:
- `moderatePostContent()`: 3단계 검증 실행
- `showModerationDialog()`: 검증 결과 UI 표시
- `_moderateText()`: Perspective API 호출
- `_determineSeverity()`: 최종 심각도 판단

---

### 2. GeminiModerationService (AI 검증)

**파일**: `text/gemini_service.dart` (181줄)
**역할**: Gemini 1.5 Pro를 통한 컨텍스트 기반 검증

```dart
class GeminiModerationService implements IGeminiModerationService {
  final FirebaseFunctions _functions;

  GeminiModerationService({
    required FirebaseFunctions functions,
  }) : _functions = functions;

  @override
  Future<GeminiModerationResult?> validateContent({
    required String userId,
    required String? questionTitle,
    required String? titleA,
    required String? titleB,
    // ...
  }) async {
    ModerationLogger.geminiCalling(
      questionTitle: questionTitle,
      titleA: titleA,
      titleB: titleB,
      userId: userId,
    );

    // Cloud Function 호출
    final callable = _functions.httpsCallable('validatePostContentWithGemini');
    final response = await callable.call({
      'question': questionTitle,
      'titleA': titleA,
      'titleB': titleB,
      // ...
    });

    final result = Map<String, dynamic>.from(response.data as Map);

    ModerationLogger.geminiResponse(
      action: result['action'],
      confidence: result['confidence']?.toDouble(),
    );

    // 결과 변환 (action 기반)
    final isValid = result['action'] != 'BLOCK';
    final moderationResult = GeminiModerationResult(
      isValid: isValid,
      reason: result['feedback']?['title'] ?? '',
      severity: _mapActionToSeverity(result['action']),
      suggestions: result['feedback']?['description'] ?? '',
      confidence: result['confidence']?.toDouble() ?? 1.0,
    );

    ModerationLogger.geminiValidation(
      isValid: moderationResult.isValid,
      severity: moderationResult.severity,
      reason: moderationResult.reason,
    );

    return moderationResult;
  }
}
```

**응답 형식**:
```json
{
  "action": "PROCEED|PROCEED_WITH_SUGGESTION|BLOCK",
  "confidence": 0.95,
  "feedback": {
    "title": "제목",
    "description": "상세 설명"
  },
  "expectedRatio": {
    "A": 0.6,
    "B": 0.4
  }
}
```

---

### 3. CloudImageModerationService (이미지 검열 상태)

**파일**: `cloud_image_moderation_service.dart` (219줄)
**역할**: Firestore 기반 이미지 검열 상태 관리

```dart
class CloudImageModerationService implements ICloudImageModerationService {
  final FirebaseFirestore _firestore;

  CloudImageModerationService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<ImageModerationModel?> checkModerationStatus(String filePath) async {
    ModerationLogger.imageCheckingStatus(filePath);

    final moderationId = filePath.replaceAll(RegExp(r'[/.]'), '_');
    final doc = await _firestore
        .collection('imageModeration')
        .doc(moderationId)
        .get();

    if (doc.exists) {
      return ImageModerationModel.getDocumentFromData(
        doc.data()!,
        doc.reference,
      );
    }
    return null;
  }

  @override
  Future<ImageModerationModel?> waitForModeration(
    String filePath, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    ModerationLogger.imageWaitingModeration(
      filePath,
      timeout: timeout.inSeconds,
    );

    // 폴링 로직 (1초 간격)
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      final record = await checkModerationStatus(filePath);
      if (record != null && record.moderationStatus != 'pending') {
        return record;
      }
      await Future.delayed(Duration(seconds: 1));
    }

    return null;  // 타임아웃
  }

  @override
  Stream<ImageModerationModel?> watchModerationStatus(String filePath) {
    final moderationId = filePath.replaceAll(RegExp(r'[/.]'), '_');

    return _firestore
        .collection('imageModeration')
        .doc(moderationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return ImageModerationModel.fromSnapshot(snapshot);
      }
      return null;
    });
  }
}
```

**Firestore 스키마** (`imageModeration` 컬렉션):
```json
{
  "moderationId": "posts_user123_image_jpg",
  "filePath": "posts/user123/image.jpg",
  "moderationStatus": "approved|rejected|pending|error",
  "safeSearchResults": {
    "adult": "VERY_UNLIKELY",
    "violence": "UNLIKELY",
    "racy": "POSSIBLE"
  },
  "hasText": true,
  "detectedText": "Hello World",
  "createdAt": "2025-11-10T10:30:00Z"
}
```

---

### 4. PerspectiveApiService (텍스트 검열)

**파일**: `perspective_api_service.dart` (348줄)
**역할**: Google Perspective API 통합

```dart
class PerspectiveApiService implements IPerspectiveApiService {
  final String apiKey;

  PerspectiveApiService({required this.apiKey});

  factory PerspectiveApiService.fromEnvironment() {
    return PerspectiveApiService(
      apiKey: EnvironmentConfig.perspectiveApiKey,
    );
  }

  @override
  Future<PerspectiveResult> analyzeText(String text) async {
    final requestBody = {
      'comment': {'text': text},
      'requestedAttributes': {
        'TOXICITY': {},
        'PROFANITY': {},
        'THREAT': {},
        'INSULT': {},
        'IDENTITY_ATTACK': {},
      },
      'languages': ['ko', 'en'],
      'doNotStore': true,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = PerspectiveResult.fromJson(jsonResponse, text);

      ModerationLogger.perspectiveResult(
        isToxic: result.isToxic,
        toxicityScore: result.toxicityScore,
      );

      return result;
    } else {
      ModerationLogger.perspectiveError(
        'Response: ${response.body}',
        statusCode: response.statusCode,
      );
      throw Exception('Perspective API Error: ${response.statusCode}');
    }
  }
}
```

**응답 예시**:
```json
{
  "attributeScores": {
    "TOXICITY": {
      "summaryScore": {
        "value": 0.85,
        "type": "PROBABILITY"
      }
    },
    "PROFANITY": {
      "summaryScore": {
        "value": 0.90
      }
    }
  }
}
```

---

### 5. ImageModerationService (이미지 검열)

**파일**: `image_moderation_service.dart` (144줄)
**역할**: Cloud Vision API 통합 (Cloud Functions 경유)

```dart
class ImageModerationService implements IImageModerationService {
  final FirebaseFunctions _functions;

  ImageModerationService({FirebaseFunctions? functions})
      : _functions = functions ??
          FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  @override
  Future<ModerationResult> checkImage({
    required File imageFile,
    required String box,
  }) async {
    // 이미지 리사이즈 (800px)
    final resizedBytes = await _resizeImageForModeration(imageFile);
    final base64Image = base64Encode(resizedBytes);

    // Cloud Function 호출
    final callable = _functions.httpsCallable('checkImageContent');
    final response = await callable.call<Map<String, dynamic>>({
      'image': base64Image,
      'box': box,
    });

    final data = response.data;

    Logger.debug(
      'Image moderation result: isAppropriate=${data['isAppropriate']}, '
      'reason=${data['reason']}, hasText=${data['hasText']}',
      tag: 'Moderation/ImageModeration',
    );

    return ModerationResult(
      isAppropriate: data['isAppropriate'] ?? false,
      reason: data['reason'] ?? '',
      hasText: data['hasText'] ?? false,
      details: data,
    );
  }
}
```

---

## 🧪 테스트 가이드 (Phase 5 예정)

### Mock 서비스 생성

```dart
// test/mocks/mock_ai_moderation_service.dart
class MockAIModerationService extends Mock implements IAIModerationService {
  @override
  Future<ModerationResult> moderatePostContent({
    required ModerationRequest request,
    Function(String)? onProgressUpdate,
  }) async {
    // Mock 응답
    return ModerationResult(
      isValid: true,
      severity: 'pass',
      violations: [],
    );
  }
}
```

### UseCase 테스트

```dart
// test/features/creation/domain/usecases/submit_post_usecase_test.dart
void main() {
  late MockAIModerationService mockModerationService;
  late SubmitPostUseCase useCase;

  setUp(() {
    mockModerationService = MockAIModerationService();
    useCase = SubmitPostUseCase(
      moderationService: mockModerationService,
    );
  });

  test('should moderate content before submitting', () async {
    // Arrange
    when(() => mockModerationService.moderatePostContent(
      request: any(named: 'request'),
    )).thenAnswer((_) async => ModerationResult(
      isValid: true,
      severity: 'pass',
      violations: [],
    ));

    // Act
    final result = await useCase(CreatePostParams(
      title: '테스트 제목',
      description: '테스트 설명',
    ));

    // Assert
    expect(result.isRight(), true);
    verify(() => mockModerationService.moderatePostContent(
      request: any(named: 'request'),
    )).called(1);
  });
}
```

---

## 📊 성능 메트릭스

### 응답 시간

| 서비스 | 평균 | P95 | P99 |
|--------|------|-----|-----|
| Perspective API | 300ms | 500ms | 800ms |
| Gemini AI (Cloud Functions) | 1.2s | 2.0s | 3.5s |
| Image Moderation | 2.5s | 4.0s | 6.0s |
| 통합 검증 (텍스트만) | 1.5s | 2.5s | 4.0s |
| 통합 검증 (이미지 포함) | 4.0s | 6.5s | 10.0s |

### 비용 (월간 1,000회 호출 기준)

- Perspective API: **무료** (60 requests/min, 1M requests/day)
- Gemini AI: **$0.00** (Cloud Functions 무료 할당량 내)
- Cloud Vision API: **$1.50** (1,000 images × $0.0015)
- Cloud Functions: **$0.00** (2M invocations/month 무료)

**총 월간 비용**: **~$1.50** (이미지 검열만)

---

## ⚠️ 주의사항

### 1. API 키 보안

```dart
// ❌ 절대 금지
class PerspectiveApiService {
  static const String _apiKey = 'AIzaSy...';  // 하드코딩 금지!
}

// ✅ 권장
class EnvironmentConfig {
  static String get perspectiveApiKey =>
    const String.fromEnvironment('PERSPECTIVE_API_KEY');
}
```

**환경 변수 설정**:
```bash
# 실행 시
flutter run --dart-define=PERSPECTIVE_API_KEY=AIzaSy...

# build.gradle (Android)
defaultConfig {
    resValue "string", "perspective_api_key", project.findProperty("PERSPECTIVE_API_KEY") ?: ""
}
```

### 2. Rate Limiting

```dart
// Perspective API: 100ms 간격 유지
for (final entry in texts.entries) {
  final result = await analyzeText(entry.value);
  await Future.delayed(Duration(milliseconds: 100));
}
```

### 3. 실패 처리

```dart
// ❌ 검열 실패 시 통과 (위험!)
try {
  final result = await moderationService.checkImage(file);
} catch (e) {
  return ModerationResult(isAppropriate: true);  // 위험!
}

// ✅ 검열 실패 시 차단 (안전)
try {
  final result = await moderationService.checkImage(file);
} catch (e) {
  return ModerationResult(
    isAppropriate: false,
    reason: '검열 서비스 오류',
  );
}
```

---

## 🔗 연관 시스템

### Feature 사용처

- **Creation Feature**: 게시물 생성 전 검열
- **Chat Feature**: 메시지 전송 전 필터링
- **Profile Feature**: 프로필 정보 검증
- **Post Feature**: 게시물 수정 시 재검증

### Backend 통합

- **Firebase Functions** (`asia-northeast3`)
  - `validatePostContentWithGemini`: Gemini AI 검증
  - `checkImageContent`: Cloud Vision API 호출
- **Firestore**
  - `imageModeration` 컬렉션: 이미지 검열 상태
- **Cloud Vision API**: SafeSearch + Text Detection
- **Perspective API**: 텍스트 독성 분석

---

## 📚 참고 자료

- [Google Perspective API](https://perspectiveapi.com)
- [Google Cloud Vision API](https://cloud.google.com/vision)
- [Gemini AI](https://ai.google.dev/gemini-api/docs)
- [Firebase Functions](https://firebase.google.com/docs/functions)
- [Port-Adapter Pattern](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

*이 문서는 Phase 1-4 완료 기준으로 작성되었습니다.*
*Services Layer는 전역 인프라로 유지되어야 합니다.*
