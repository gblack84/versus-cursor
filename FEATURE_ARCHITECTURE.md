# 🏛️ Feature-First Architecture 가이드

> Versus Space의 진정한 Feature-First Architecture 구현 가이드
> 작성일: 2025-01-06 | 버전: 3.0.0 | 준수율 목표: 90%+
> 상태관리: Provider | DI: GetIt | Lint: Custom Rules

## 🚨 핵심 원칙 (절대 위반 금지)

### 1. Feature 완전 독립성
- **각 Feature는 자체 완결적**: 다른 Feature에 의존하지 않음
- **모든 레이어 포함**: data, domain, presentation을 Feature 내부에 포함
- **Cross-feature import 금지**: Feature 간 직접 참조 절대 금지
- **재사용 가능**: Feature를 통째로 다른 프로젝트에 이식 가능

### 2. 전역 레이어 최소화
- **Backend 레이어 없음**: `/lib/backend/` 디렉토리 자체가 존재하면 안 됨
- **Services 레이어 없음**: `/lib/services/` 디렉토리 자체가 존재하면 안 됨  
- **Core는 순수 유틸리티만**: Feature에 의존하지 않는 순수 함수와 상수만

### 3. Clean Architecture 준수
- **의존성 역전**: 구현이 아닌 인터페이스에 의존
- **계층 분리**: presentation → domain → data 단방향 의존
- **테스트 가능성**: 모든 레이어 독립적으로 테스트 가능

## 🏗️ 올바른 디렉토리 구조

```
lib/
├── features/              # 🎯 비즈니스 기능별 완전 독립 모듈
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   └── adapters/                  # Feature 전용 어댑터
│   │   │       └── firebase_auth_adapter.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── posts/             # 각 Feature가 동일한 구조
│   ├── chat/
│   ├── profile/
│   ├── search/
│   ├── voting/
│   └── notifications/
│
├── core/                  # 🔧 순수 유틸리티와 인터페이스 (Feature 의존 절대 금지)
│   ├── constants/         # 앱 전역 상수
│   ├── utils/            # 순수 유틸리티 함수
│   ├── widgets/          # 기본 UI 컴포넌트 (비즈니스 로직 없음)
│   ├── theme/            # 테마 정의
│   ├── localization/    # 다국어 지원
│   ├── errors/           # 공통 에러 정의
│   ├── services/         # 서비스 인터페이스
│   │   └── interfaces/   # 전역 서비스 인터페이스만
│   │       ├── i_event_bus.dart          # Event Bus 인터페이스
│   │       ├── i_logger_service.dart
│   │       └── i_cache_service.dart
│   └── events/           # Event 타입 정의
│
├── app/                   # 🚀 앱 진입점과 구현체
│   ├── di/               # GetIt 의존성 주입 설정
│   ├── router/           # 라우팅 설정
│   ├── services/         # 전역 서비스 구현체
│   └── app.dart          # MaterialApp 진입점
│
└── main.dart             # 앱 시작점
```

## ❌ 금지된 구조 (절대 생성 금지)

```
lib/
├── backend/     ❌ 전역 Backend 레이어 금지
├── services/    ❌ 전역 Services 레이어 금지  
├── repositories/ ❌ 전역 Repository 금지
├── models/      ❌ 전역 Model 금지
└── data/        ❌ 전역 Data 레이어 금지
```

## 📦 Feature 표준 구조

### 완전한 Feature 구조 예시 (posts)
```
features/posts/
├── data/                          # 데이터 레이어
│   ├── datasources/
│   │   ├── posts_remote_datasource.dart    # Firebase/API 접근
│   │   └── posts_local_datasource.dart     # 로컬 캐시
│   ├── repositories/
│   │   └── posts_repository_impl.dart      # Repository 구현
│   ├── adapters/                          # Feature 전용 어댑터
│   │   ├── image_upload_adapter.dart      # 외부 시스템 연동
│   │   └── moderation_adapter.dart
│   ├── mappers/
│   │   └── post_mapper.dart               # DTO ↔ Model 변환
│   └── dtos/
│       ├── post_dto.dart                  # Firestore/API DTO
│       └── post_dto.g.dart                # Generated code
│
├── domain/                        # 도메인 레이어 (비즈니스 로직)
│   ├── models/
│   │   ├── post.dart                      # 도메인 모델
│   │   └── vote_result.dart
│   ├── repositories/
│   │   └── posts_repository.dart          # Repository 인터페이스
│   └── usecases/
│       ├── create_post_usecase.dart       # 비즈니스 규칙
│       ├── vote_on_post_usecase.dart
│       └── get_posts_usecase.dart
│
└── presentation/                  # 프레젠테이션 레이어
    ├── screens/
    │   ├── create_post_screen.dart
    │   └── feed_screen.dart
    ├── widgets/
    │   ├── post_card.dart
    │   └── vote_button.dart
    ├── providers/                        # Provider 상태 관리
    │   └── posts_provider.dart
    └── public.dart                        # Feature Public API (barrel export)
```

## 🔄 의존성 규칙

### ✅ 허용되는 의존성
```
Features → Core (유틸리티 + 서비스 인터페이스)
App → Features (DI 설정)
App → Core (테마, 상수, 인터페이스)

Feature 내부:
presentation → domain
domain → 없음 (순수 비즈니스 로직)
data → domain (인터페이스 구현)
data → Core/services/interfaces (서비스 인터페이스 사용)
```

### ❌ 절대 금지되는 의존성
```
Core → Features          ❌ Core가 Feature 참조 금지
Features → Features      ❌ Feature 간 직접 참조 금지
Features → App/services  ❌ 구현체 직접 참조 금지
domain → data           ❌ 도메인이 구현 참조 금지
domain → presentation   ❌ 도메인이 UI 참조 금지
```

## 🛡️ DTO 경계 및 Domain 레이어 보호

### DTO는 Data 레이어에만!
```dart
// ✅ 올바른 구조
// features/posts/data/dtos/post_dto.dart
@JsonSerializable()
class PostDto {
  final String id;
  final String title;
  final Map<String, dynamic> optionA;
  
  PostDto({required this.id, required this.title, required this.optionA});
  
  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostDtoToJson(this);
}

// features/posts/data/mappers/post_mapper.dart
class PostMapper {
  static Post toDomain(PostDto dto) {
    return Post(
      id: dto.id,
      title: dto.title,
      optionA: OptionMapper.toDomain(dto.optionA),
    );
  }
  
  static PostDto toDto(Post domain) {
    return PostDto(
      id: domain.id,
      title: domain.title,
      optionA: OptionMapper.toDto(domain.optionA),
    );
  }
}
```

### Domain 모델은 순수해야 함
```dart
// ✅ 올바른 Domain 모델
// features/posts/domain/models/post.dart
class Post {
  final String id;
  final String title;
  final Option optionA;
  final Option optionB;
  final DateTime createdAt;
  
  const Post({
    required this.id,
    required this.title,
    required this.optionA,
    required this.optionB,
    required this.createdAt,
  });
  
  // ❌ 금지사항
  // - @JsonSerializable() 사용 금지
  // - fromJson/toJson 메서드 금지
  // - Firebase 타입 사용 금지 (DocumentReference, Timestamp 등)
  // - json_annotation import 금지
}
```

### Repository에서 변환
```dart
// features/posts/data/repositories/posts_repository_impl.dart
class PostsRepositoryImpl implements PostsRepository {
  final FirebaseFirestore _firestore;
  final PostMapper _mapper;
  
  @override
  Future<Post> getPost(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    final dto = PostDto.fromJson(doc.data()!);
    return PostMapper.toDomain(dto); // DTO → Domain 변환
  }
  
  @override
  Future<void> createPost(Post post) async {
    final dto = PostMapper.toDto(post); // Domain → DTO 변환
    await _firestore.collection('posts').add(dto.toJson());
  }
}
```

### ❌ Domain 레이어 금지사항
1. **json_annotation 사용 금지** - Domain은 직렬화 몰라야 함
2. **Firebase 타입 금지** - DocumentReference, Timestamp 등
3. **HTTP/REST 관련 코드 금지** - Headers, StatusCode 등
4. **UI 관련 import 금지** - Material, Widgets 등
5. **Data 레이어 import 금지** - DTO, Mapper, DataSource 등

## 🌐 전역 서비스 (올바른 구현 방법)

### 전역 서비스가 필요한 이유
모든 Feature가 공유해야 하는 횡단 관심사(cross-cutting concerns)가 존재합니다:
- **로깅**: 에러 추적, 디버깅
- **캐싱**: 성능 최적화, 오프라인 지원
- **분석**: 사용자 행동 추적
- **인증**: 사용자 상태 관리
- **네트워크**: 연결 상태 모니터링

### 올바른 전역 서비스 구조
```
lib/
├── core/
│   └── services/              # 🔍 인터페이스만!
│       └── interfaces/
│           ├── i_logger_service.dart
│           ├── i_cache_service.dart
│           ├── i_analytics_service.dart
│           └── i_auth_service.dart
│
├── app/
│   ├── services/              # 🔧 구현체
│   │   ├── logger_service_impl.dart
│   │   ├── cache_service_impl.dart
│   │   ├── analytics_service_impl.dart
│   │   └── auth_service_impl.dart
│   └── di/
│       └── service_module.dart  # DI 설정
```

### 전역 서비스 구현 예시

#### 1. Core에 인터페이스 정의
```dart
// core/services/interfaces/i_cache_service.dart
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> clear();
}

// core/services/interfaces/i_logger_service.dart
abstract class ILoggerService {
  void log(String message, {LogLevel level = LogLevel.info});
  void error(String message, [Object? error, StackTrace? stackTrace]);
}
```

#### 2. App에 구현체 작성
```dart
// app/services/cache_service_impl.dart
class CacheServiceImpl implements ICacheService {
  // UnifiedCacheService, Hive 등 실제 구현
  @override
  Future<T?> get<T>(String key) async {
    // 구현 로직
  }
}

// app/services/logger_service_impl.dart
class LoggerServiceImpl implements ILoggerService {
  // Firebase Crashlytics, Sentry 등 실제 구현
  @override
  void log(String message, {LogLevel level = LogLevel.info}) {
    // 구현 로직
  }
}
```

#### 3. DI 모듈 설정
```dart
// app/di/service_module.dart
@module
abstract class ServiceModule {
  @lazySingleton
  ICacheService provideCacheService() => CacheServiceImpl();
  
  @lazySingleton
  ILoggerService provideLoggerService() => LoggerServiceImpl();
  
  @lazySingleton
  IAnalyticsService provideAnalyticsService() => AnalyticsServiceImpl();
}
```

#### 4. Feature에서 사용
```dart
// features/posts/data/repositories/posts_repository_impl.dart
@injectable
class PostsRepositoryImpl implements PostsRepository {
  final ICacheService _cache;      // 인터페이스 의존
  final ILoggerService _logger;    // 인터페이스 의존
  
  PostsRepositoryImpl(
    this._cache,
    this._logger,
  );
  
  @override
  Future<Post?> getPost(String id) async {
    try {
      // 캐시 확인
      final cached = await _cache.get<Post>('post_$id');
      if (cached != null) {
        _logger.log('Cache hit for post $id');
        return cached;
      }
      
      // Firestore에서 로드
      final post = await _loadFromFirestore(id);
      await _cache.set('post_$id', post);
      return post;
      
    } catch (e, stack) {
      _logger.error('Failed to get post', e, stack);
      rethrow;
    }
  }
}
```

### ✅ 전역 서비스 체크리스트
- [ ] 인터페이스는 `/core/services/interfaces/`에만
- [ ] 구현체는 `/app/services/`에만
- [ ] DI 모듈에 등록
- [ ] Feature는 인터페이스만 import
- [ ] 구현체 직접 import 금지
- [ ] 테스트 시 Mock 주입 가능

### ❌ 금지사항
```dart
// ❌ 잘못된 예: 전역 구현체
lib/services/cache/unified_cache_service.dart

// ❌ 잘못된 예: Feature가 구현체 직접 사용
import 'package:app/app/services/cache_service_impl.dart';

// ✅ 올바른 예: 인터페이스만 사용
import 'package:app/core/services/interfaces/i_cache_service.dart';
```

## 🔀 Feature 간 통신 (직접 의존 없이)

### 1. Event Bus 패턴 (DI 기반)
```dart
// core/services/interfaces/i_event_bus.dart
abstract class IEventBus {
  void fire(dynamic event);
  Stream<T> on<T>();
  void dispose(); // 생명주기 관리
}

// app/services/event_bus_impl.dart
@LazySingleton(as: IEventBus)
class EventBusImpl implements IEventBus {
  final _controller = StreamController.broadcast();
  
  @override
  void fire(dynamic event) => _controller.add(event);
  
  @override
  Stream<T> on<T>() => _controller.stream.where((e) => e is T).cast<T>();
  
  @override
  void dispose() => _controller.close();
}

// features/posts/domain/events/post_created_event.dart
class PostCreatedEvent {
  final String postId;
  PostCreatedEvent(this.postId);
}

// Feature A: 이벤트 발행 (DI 주입)
class CreatePostUseCase {
  final IEventBus _eventBus;
  
  CreatePostUseCase(this._eventBus);
  
  void execute() {
    // 포스트 생성 후
    _eventBus.fire(PostCreatedEvent(postId));
  }
}

// Feature B: 이벤트 구독 (dispose 필수)
class NotificationProvider extends ChangeNotifier {
  final IEventBus _eventBus;
  StreamSubscription? _subscription;
  
  NotificationProvider(this._eventBus) {
    _subscription = _eventBus.on<PostCreatedEvent>().listen((event) {
      // 알림 표시
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // 메모리 누수 방지
    super.dispose();
  }
}
```

### 2. Navigation 데이터 전달
```dart
// Feature A에서
context.push('/feature-b', extra: {'postId': postId});

// Feature B에서
final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
final postId = extra['postId'];
```

### ❌ 금지된 통신 방법
```dart
// 절대 금지!
import 'package:app/features/auth/data/services/auth_util.dart'; ❌
import 'package:app/backend/repositories/user_repository.dart'; ❌
import 'package:app/services/cache/cache_service.dart'; ❌
```

## 🔨 현재 상태 → Feature-First 마이그레이션

### 현재 문제점 (Inventory Scout 분석 결과)
- **Feature-First 준수율**: 48.3%
- **아키텍처 위반**: 196개
  - Backend 의존: 77개
  - Services 의존: 119개  
  - Cross-feature: 15개
- **Monolithic 파일**: backend.dart (1,769줄)

### Phase 1: Backend 분해 (2주)
```bash
# 1. backend.dart 분석
/spawn inventory-scout "backend.dart 의존성 분석"

# 2. Feature별로 이동
/spawn repo-mover "--feature posts --include repositories,firebase"
/spawn repo-mover "--feature auth --include repositories,firebase"

# 3. DI 재설정
/spawn di-binder "--feature posts --port IPostRepository --adapter PostRepositoryImpl"
```

### Phase 2: Services 리팩토링 (2주)
```bash
# 1. 현재 /lib/services/ 분석
/spawn inventory-scout "services 디렉토리 분석"

# 2. 인터페이스 추출
# /lib/services/cache/unified_cache_service.dart 
# → /lib/core/services/interfaces/i_cache_service.dart (인터페이스)
# → /lib/app/services/cache_service_impl.dart (구현체)

# 3. DI 모듈 생성
/spawn di-binder "--interface ICacheService --impl CacheServiceImpl"

# 4. Feature별 전용 서비스는 Feature로 이동
# /lib/services/vote_timer_service.dart 
# → /lib/features/voting/data/services/vote_timer_service.dart
```

### Phase 3: Cross-Feature 제거 (1주)
```bash
# 1. Cross-feature imports 탐지
/spawn import-guardian "--scope all --mode fix"

# 2. Event Bus로 교체
# 3. 검증
/spawn build-sentinel "quick"
```

### Phase 4: 최종 검증
```bash
# 1. 전체 스캔
/spawn inventory-scout "depth 5 전체 검증"

# 2. 위반 확인 (목표: 0개)
/spawn import-guardian "--scope all --mode detect"

# 3. 빌드 검증
/spawn build-sentinel "full"
```

## 🎯 상태관리 표준: Provider

### 선택 이유
- Flutter 팀 공식 권장
- 간단하고 직관적인 API
- ChangeNotifier 기반의 반응형 프로그래밍
- GetIt과 완벽한 통합

### Provider 표준 구조
```dart
// features/posts/presentation/providers/posts_provider.dart
@injectable
class PostsProvider extends ChangeNotifier {
  final GetPostsUseCase _getPostsUseCase;
  final IEventBus _eventBus;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  
  PostsProvider(
    this._getPostsUseCase,
    this._eventBus,
  );
  
  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _posts = await _getPostsUseCase.execute();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// 사용
Consumer<PostsProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    return ListView.builder(...);
  },
)
```

## 🛡️ Lint 규칙 및 아키텍처 가드레일

### analysis_options.yaml 설정
```yaml
analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
  
  errors:
    # 아키텍처 위반을 에러로 처리
    invalid_dependency: error
    
  plugins:
    - custom_lint

linter:
  rules:
    - always_use_package_imports
    - avoid_relative_imports_for_packages

custom_lint:
  rules:
    # Core가 Features를 import하면 에러
    - no_core_to_features:
        severity: error
        message: "Core cannot depend on Features"
        
    # Features 간 직접 import 금지
    - no_cross_feature_imports:
        severity: error
        message: "Features cannot directly import each other"
        
    # Feature가 app/services 구현체 직접 import 금지
    - no_implementation_imports:
        severity: error
        message: "Import interfaces from core/services/interfaces, not implementations"
        
    # Domain 레이어 보호
    - protect_domain_layer:
        severity: error
        rules:
          - no_json_annotation  # Domain에 json_annotation 금지
          - no_data_imports     # Domain이 Data 레이어 import 금지
          - no_ui_imports       # Domain이 Flutter UI import 금지
```

### Custom Lint 패키지 설정
```dart
// tools/custom_lint/lib/rules/architecture_rules.dart
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoCoreTofeaturesRule extends DartLintRule {
  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter) {
    resolver.fileContent.forEach((file) {
      if (file.path.contains('/core/')) {
        final imports = extractImports(file.content);
        for (final import in imports) {
          if (import.contains('/features/')) {
            reporter.reportErrorForOffset(
              code: 'no_core_to_features',
              offset: import.offset,
              length: import.length,
            );
          }
        }
      }
    });
  }
}
```

### CI/CD 가드레일 (GitHub Actions)
```yaml
name: Architecture Guard

on: [push, pull_request]

jobs:
  architecture-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run custom lint
        run: dart run custom_lint
        
      - name: Check architecture violations
        run: |
          # Core → Features import 체크
          if grep -r "import.*'/features/" lib/core/; then
            echo "❌ Core depends on Features!"
            exit 1
          fi
          
          # Cross-feature import 체크
          for feature in lib/features/*/; do
            feature_name=$(basename $feature)
            if grep -r "import.*'/features/" $feature | grep -v $feature_name; then
              echo "❌ Cross-feature import detected!"
              exit 1
            fi
          done
```

## 📦 Feature Public API (Barrel Exports)

### 각 Feature의 public.dart
```dart
// features/posts/public.dart
// 외부에서 접근 가능한 API만 export

// Models
export 'domain/models/post.dart';
export 'domain/models/vote_result.dart';

// Use Cases (App DI용)
export 'domain/usecases/create_post_usecase.dart';
export 'domain/usecases/vote_on_post_usecase.dart';

// Repositories (DI 설정용)
export 'domain/repositories/posts_repository.dart';
export 'data/repositories/posts_repository_impl.dart';

// Providers
export 'presentation/providers/posts_provider.dart';

// Screens (Router용)
export 'presentation/screens/create_post_screen.dart';
export 'presentation/screens/feed_screen.dart';

// ❌ 내부 구현은 export하지 않음
// - datasources
// - adapters
// - mappers
// - internal widgets
```

### App에서 사용
```dart
// app/di/feature_module.dart
import 'package:app/features/posts/public.dart'; // ✅ public API만 import

// ❌ 금지
import 'package:app/features/posts/data/datasources/posts_remote_datasource.dart';
```

## ✅ Feature 추가 체크리스트

새 Feature 추가 시 반드시 확인:

- [ ] `/features/[name]/` 아래에만 코드 작성
- [ ] data, domain, presentation 3개 레이어 모두 구현
- [ ] `public.dart` 파일로 외부 API 정의
- [ ] Repository 인터페이스를 domain에 정의
- [ ] Repository 구현을 data에 작성
- [ ] Provider 기반 상태관리 구현
- [ ] 다른 Feature import 없음 (Lint가 자동 체크)
- [ ] Backend/Services import 없음 (Lint가 자동 체크)
- [ ] Core는 인터페이스만 import
- [ ] DI 설정을 app/di에 추가
- [ ] 라우트를 app/router에 추가
- [ ] Event Bus로 통신 구현 (dispose 필수)

## 📊 성공 지표

### 목표 (마이그레이션 완료 후)
- Feature-First 준수율: **90%+**
- 아키텍처 위반: **0개**
- Cross-feature imports: **0개**
- 최대 파일 크기: **300줄** (권장) / **400줄** (경고)
- 빌드 시간 개선: **20%+**

### 측정 방법
```bash
# 준수율 측정
/spawn inventory-scout "Feature-First 준수율 측정"

# 위반 검사
/spawn import-guardian "--scope all --mode detect"

# 성능 측정
/spawn build-sentinel "full --benchmark"
```

## 🚫 안티패턴 (절대 하지 마세요)

### 1. Monolithic Backend
```dart
// ❌ 잘못된 예
lib/backend/backend.dart  // 1,769줄의 모든 것

// ✅ 올바른 예
features/posts/data/repositories/posts_repository_impl.dart
features/auth/data/repositories/auth_repository_impl.dart
```

### 2. 공유 Repository
```dart
// ❌ 잘못된 예
lib/backend/repositories/user_repository.dart  // 모든 Feature가 공유

// ✅ 올바른 예
features/auth/domain/repositories/auth_repository.dart
features/profile/domain/repositories/profile_repository.dart
```

### 3. Cross-Feature Import
```dart
// ❌ 잘못된 예
// features/posts/presentation/screens/create_post.dart
import 'package:app/features/auth/data/services/auth_util.dart';

// ✅ 올바른 예
// Event Bus 사용
EventBus.on<UserLoggedInEvent>().listen((_) => updateUI());
```

## 🔍 실용적인 아키텍처 체크 스크립트

### check_architecture.sh
```bash
#!/bin/bash
# 아키텍처 규칙 자동 체크 스크립트

echo "🔍 Feature-First Architecture 검증 시작..."

VIOLATIONS=0

# 1. Core → Features import 체크
echo "Checking Core → Features dependencies..."
if grep -r "import.*'/features/" lib/core/ 2>/dev/null | grep -v "^Binary"; then
  echo "❌ Core가 Features를 import하고 있습니다!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 2. Cross-feature import 체크
echo "Checking cross-feature imports..."
for feature_dir in lib/features/*/; do
  feature_name=$(basename "$feature_dir")
  if grep -r "import.*'/features/" "$feature_dir" 2>/dev/null | grep -v "$feature_name" | grep -v "^Binary"; then
    echo "❌ $feature_name이 다른 Feature를 import하고 있습니다!"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

# 3. Feature → Backend import 체크
echo "Checking Feature → Backend dependencies..."
if grep -r "import.*'/backend/" lib/features/ 2>/dev/null | grep -v "^Binary"; then
  echo "❌ Feature가 Backend를 직접 import하고 있습니다!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 4. Feature → Services 구현체 import 체크
echo "Checking Feature → Service implementation imports..."
if grep -r "import.*'/app/services/" lib/features/ 2>/dev/null | grep -v "^Binary"; then
  echo "❌ Feature가 Service 구현체를 직접 import하고 있습니다!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 5. Domain 레이어 순수성 체크
echo "Checking Domain layer purity..."
if grep -r "@JsonSerializable\|fromJson\|toJson" lib/features/*/domain/ 2>/dev/null | grep -v "^Binary"; then
  echo "❌ Domain 레이어에 직렬화 코드가 있습니다!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 6. Public API 체크
echo "Checking Feature public APIs..."
for feature_dir in lib/features/*/; do
  if [ ! -f "$feature_dir/public.dart" ]; then
    feature_name=$(basename "$feature_dir")
    echo "⚠️  $feature_name에 public.dart가 없습니다"
  fi
done

# 7. 파일 크기 체크
echo "Checking file sizes..."
find lib -name "*.dart" -type f | while read -r file; do
  lines=$(wc -l < "$file")
  if [ "$lines" -gt 400 ]; then
    echo "⚠️  $file이 400줄을 초과합니다 ($lines줄)"
  fi
done

# 결과 출력
echo ""
echo "======================================"
if [ $VIOLATIONS -eq 0 ]; then
  echo "✅ 모든 아키텍처 규칙이 준수되고 있습니다!"
  exit 0
else
  echo "❌ $VIOLATIONS개의 아키텍처 위반이 발견되었습니다!"
  echo "위반 사항을 수정한 후 다시 실행해주세요."
  exit 1
fi
```

### 사용 방법
```bash
# 실행 권한 부여
chmod +x check_architecture.sh

# 실행
./check_architecture.sh

# CI/CD에 통합 (GitHub Actions)
- name: Check Architecture
  run: ./check_architecture.sh
```

## 📚 참고 자료

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Feature-Sliced Design](https://feature-sliced.design/)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Provider Package](https://pub.dev/packages/provider)
- [GetIt for Dependency Injection](https://pub.dev/packages/get_it)
- [Custom Lint Builder](https://pub.dev/packages/custom_lint_builder)
- Sub-Agent Manual: `/docs/SUBAGENTS_MANUAL.md`

---

*이 문서는 Versus Space의 진정한 Feature-First Architecture 가이드입니다.*
*현재 준수율 48.3% → 목표 90%+ 달성을 위한 로드맵입니다.*