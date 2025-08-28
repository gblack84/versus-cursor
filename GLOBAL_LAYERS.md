# 🌍 Global Layers Documentation

> Feature-First Architecture의 전역 레이어 상세 문서  
> 작성일: 2025-08-27 | 버전: 1.0.0

## 📋 개요

Versus Space의 전역 레이어는 모든 Feature가 공유하는 공통 요소들을 담당합니다.
Core, Backend, Services, App 네 개의 주요 레이어로 구성되어 있으며,
각 레이어는 명확한 책임과 역할을 가지고 있습니다.

## 🏗️ 레이어 구조

```
lib/
├── features/       # Feature 모듈들
├── core/          # 🔧 전역 공통 요소
├── backend/       # 🗄️ 전역 백엔드 레이어
├── services/      # 🛠️ 전역 서비스 레이어
└── app/           # 🚀 앱 설정 및 진입점
```

## 🔧 Core Layer

### 목적
앱 전체에서 사용되는 기본적인 UI 요소, 테마, 유틸리티를 제공

### 구조
```
core/
├── design_system/           # 디자인 시스템
│   ├── components/         # 재사용 가능한 UI 컴포넌트
│   │   ├── buttons/       # 버튼 컴포넌트
│   │   ├── cards/         # 카드 컴포넌트
│   │   └── forms/         # 폼 컴포넌트
│   └── tokens/            # 디자인 토큰
│       ├── colors.dart    # 색상 팔레트
│       ├── typography.dart # 타이포그래피
│       └── spacing.dart   # 간격 시스템
│
├── theme/                  # 앱 테마
│   ├── app_theme.dart     # 메인 테마 설정
│   ├── dark_theme.dart    # 다크 모드
│   └── light_theme.dart   # 라이트 모드
│
├── localization/          # 다국어 지원
│   ├── app_localizations.dart
│   └── translations/
│       ├── en.json       # 영어
│       ├── ko.json       # 한국어
│       └── de.json       # 독일어
│
├── utils/                 # 유틸리티
│   ├── extensions/       # Dart 확장
│   ├── formatters/       # 포맷터
│   ├── validators/       # 검증자
│   └── constants.dart    # 상수
│
├── widgets/              # 공통 위젯
│   ├── loading_indicator.dart
│   ├── error_widget.dart
│   └── empty_state.dart
│
└── nav/                  # 네비게이션
    ├── router.dart      # GoRouter 설정
    └── routes.dart      # 라우트 정의
```

### 주요 컴포넌트

#### Design System
```dart
// 색상 시스템
class VersusColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF2196F3);
  static const Color error = Color(0xFFE91E63);
}

// 타이포그래피
class VersusTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
}

// 간격 시스템
class VersusSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

## 🗄️ Backend Layer

### 목적
Firebase 및 외부 API와의 통신, 데이터 모델 관리

### 구조
```
backend/
├── firebase/              # Firebase 설정
│   ├── config/           # Firebase 구성
│   │   ├── firebase_config.dart
│   │   └── firebase_options.dart
│   └── firestore/        # Firestore 유틸리티
│       ├── firestore_helpers.dart
│       └── batch_operations.dart
│
├── models/               # 데이터 모델
│   ├── user/            # 사용자 관련
│   │   ├── user_model.dart
│   │   └── user_settings.dart
│   ├── post/            # 게시물 관련
│   │   ├── post_model.dart
│   │   └── post_option.dart
│   └── chat/            # 채팅 관련
│       ├── message_model.dart
│       └── chat_room.dart
│
├── api/                 # 외부 API
│   ├── algolia/        # Algolia 검색
│   │   ├── algolia_config.dart
│   │   └── algolia_service.dart
│   └── gemini/         # Gemini AI
│       ├── gemini_config.dart
│       └── gemini_service.dart
│
└── repositories/        # 공통 Repository
    ├── user_repository.dart
    ├── post_repository.dart
    └── base_repository.dart
```

### 주요 기능

#### Firebase 통합
```dart
// Firestore 헬퍼
class FirestoreHelpers {
  static CollectionReference getCollection(String name) {
    return FirebaseFirestore.instance.collection(name);
  }
  
  static Future<void> batchWrite(List<WriteOperation> operations) async {
    final batch = FirebaseFirestore.instance.batch();
    // 배치 작업 처리
  }
}
```

#### 데이터 모델
```dart
// 기본 모델 구조
abstract class BaseModel {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  
  Map<String, dynamic> toJson();
  factory BaseModel.fromJson(Map<String, dynamic> json);
}
```

## 🛠️ Services Layer

### 목적
비즈니스 로직, 캐싱, 유틸리티 서비스 제공

### 구조
```
services/
├── cache/                    # 캐싱 시스템
│   ├── unified_cache_service.dart  # 3-Layer 캐시
│   ├── simple_memory_cache.dart    # L1 메모리
│   ├── hive_cache.dart            # L2 로컬 DB
│   └── cache_statistics.dart      # 통계
│
├── moderation/              # 콘텐츠 검열
│   ├── ai_moderation_service.dart
│   ├── text_moderation.dart
│   └── image_moderation.dart
│
├── logger/                  # 로깅
│   ├── app_logger.dart
│   └── crash_reporter.dart
│
├── validators/              # 유효성 검증
│   ├── form_validators.dart
│   ├── content_validator.dart
│   └── media_validator.dart
│
├── notification_service.dart     # 알림
├── target_audience_service.dart  # AI 타겟팅
├── vote_timer_service.dart      # 투표 타이머
├── vote_status_service.dart     # 투표 상태
└── user_cache_service.dart      # 사용자 캐시
```

### 주요 서비스

#### 3-Layer 캐싱 시스템
```dart
class UnifiedCacheService {
  // L1: Memory Cache (100개, 5분 TTL)
  final SimpleMemoryCache _memoryCache;
  
  // L2: Hive Local DB (영구 저장)
  final Box _hiveBox;
  
  // L3: Firestore Offline Cache
  final FirebaseFirestore _firestore;
  
  Future<T?> get<T>(String key, Future<T> Function() fetcher) async {
    // L1 체크
    if (_memoryCache.contains(key)) return _memoryCache.get(key);
    
    // L2 체크
    if (_hiveBox.containsKey(key)) return _hiveBox.get(key);
    
    // L3 체크 또는 네트워크
    final data = await fetcher();
    
    // 캐시 저장
    _saveToCache(key, data);
    
    return data;
  }
}
```

#### AI 콘텐츠 검열
```dart
class AIModerationService {
  Future<ModerationResult> moderateContent({
    String? text,
    List<String>? images,
  }) async {
    // Perspective API로 텍스트 검증
    if (text != null) {
      await _moderateText(text);
    }
    
    // Cloud Vision API로 이미지 검증
    if (images != null) {
      await _moderateImages(images);
    }
    
    // Gemini AI로 종합 검증
    return await _validateWithGemini(text, images);
  }
}
```

## 🚀 App Layer

### 목적
앱 초기화, 전역 설정, 의존성 주입 관리

### 구조
```
app/
├── router/                # 라우팅
│   ├── app_router.dart   # GoRouter 인스턴스
│   ├── route_guards.dart # 라우트 가드
│   └── route_names.dart  # 라우트 이름 상수
│
├── state/                 # 전역 상태
│   ├── app_state.dart    # 앱 상태 관리
│   └── app_provider.dart # Provider 설정
│
├── di/                    # 의존성 주입
│   ├── injection.dart    # DI 컨테이너
│   └── modules/          # DI 모듈
│       ├── firebase_module.dart
│       ├── repository_module.dart
│       └── service_module.dart
│
└── app.dart              # 앱 진입점
```

### 주요 기능

#### 앱 초기화
```dart
class VersusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        // 다른 Provider들...
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
```

#### 의존성 주입
```dart
class Injection {
  static final GetIt _getIt = GetIt.instance;
  
  static Future<void> init() async {
    // Firebase
    _getIt.registerSingleton<FirebaseFirestore>(
      FirebaseFirestore.instance
    );
    
    // Repositories
    _getIt.registerFactory<UserRepository>(
      () => UserRepositoryImpl(_getIt())
    );
    
    // Services
    _getIt.registerSingleton<UnifiedCacheService>(
      UnifiedCacheService()
    );
  }
  
  static T get<T>() => _getIt<T>();
}
```

## 🔄 의존성 규칙

### 허용되는 의존성
- ✅ Features → Core, Backend, Services, App
- ✅ App → Core, Backend, Services
- ✅ Services → Backend, Core
- ✅ Backend → Core

### 금지되는 의존성
- ❌ Core → Features, Backend, Services, App
- ❌ Backend → Features, Services, App
- ❌ Services → Features, App
- ❌ App → Features (라우팅 제외)

## 📊 사용 통계

### 가장 많이 사용되는 전역 컴포넌트

| 컴포넌트 | 사용처 | 빈도 |
|---------|-------|------|
| VersusColors | 모든 Feature UI | 95% |
| UnifiedCacheService | 채팅, 포스트 | 80% |
| AppState | 전역 상태 관리 | 75% |
| FirestoreHelpers | 데이터 작업 | 70% |
| VoteTimerService | 투표 시스템 | 60% |

## ✅ 베스트 프랙티스

### Core Layer
- 디자인 토큰은 한 곳에서만 정의
- 공통 위젯은 3개 이상 Feature에서 사용 시 Core로 이동
- 유틸리티는 순수 함수로 작성

### Backend Layer
- 모든 모델은 JSON 직렬화 지원
- Repository 인터페이스는 domain에, 구현은 backend에
- API 키는 환경 변수로 관리

### Services Layer
- 서비스는 싱글톤 패턴 사용
- 비동기 작업은 에러 처리 필수
- 캐싱 전략 명확히 정의

### App Layer
- 라우트 가드로 인증 체크
- Provider는 필요한 범위에만 적용
- DI는 앱 시작 시 한 번만 초기화

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- 전역 레이어 문서 최초 작성
- Core, Backend, Services, App 상세 설명
- 의존성 규칙 명확화
- 베스트 프랙티스 정리

---

*이 문서는 Versus Space의 전역 레이어 구조를 설명합니다.*
*각 레이어의 상세 구현은 해당 디렉토리의 README를 참조하세요.*