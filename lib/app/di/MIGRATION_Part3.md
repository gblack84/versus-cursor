# 🚀 Migration Part 3: DI System Implementation

> Feature-First Architecture 의존성 주입 시스템 구축  
> 작성일: 2025-08-27 | 대상: /lib/app/di

## 📋 개요

이 문서는 Versus Space 프로젝트의 의존성 주입(DI) 시스템 구현을 위한 마이그레이션 가이드입니다.
현재 직접 import와 개별 싱글톤으로 관리되는 의존성을 GetIt 기반의 중앙화된 DI 시스템으로 전환합니다.

## 🎯 마이그레이션 목표

### 주요 목표
1. **중앙화된 의존성 관리**: 모든 서비스와 리포지토리를 DI 컨테이너에서 관리
2. **테스트 가능한 구조**: Mock 객체 쉽게 주입 가능
3. **Feature 독립성**: Feature 간 의존성 최소화
4. **성능 최적화**: Lazy Loading과 적절한 Scope 관리

### 성공 지표
- [ ] 모든 싱글톤 서비스가 DI로 관리됨
- [ ] 테스트에서 Mock 주입이 가능함
- [ ] Feature 간 직접 의존성이 제거됨
- [ ] 메모리 사용량 개선 (Lazy Loading)

## 🏗️ 현재 상태 분석

### 문제점 식별
```dart
// 현재 문제 1: 직접 싱글톤 패턴
class UnifiedCacheService {
  static final UnifiedCacheService _instance = UnifiedCacheService._();
  factory UnifiedCacheService() => _instance;
  UnifiedCacheService._();
}

// 현재 문제 2: 직접 Firebase 접근
class SomeWidget {
  void saveData() {
    FirebaseFirestore.instance.collection('posts').add(...);
  }
}

// 현재 문제 3: 테스트 불가능한 구조
class AuthService {
  final auth = FirebaseAuth.instance; // Mock 주입 불가
}
```

### 영향받는 컴포넌트
| 컴포넌트 | 현재 위치 | 문제점 | 우선순위 |
|---------|----------|--------|----------|
| UnifiedCacheService | /services/cache | 싱글톤 패턴 | Critical |
| AuthUtil | /features/auth/data | 정적 메서드 | Critical |
| AppState | /app/state | 거대한 싱글톤 | High |
| NotificationService | /features/notifications | 싱글톤 패턴 | High |
| VoteStateCoordinator | /services | 싱글톤 패턴 | Medium |

## 📝 마이그레이션 계획

### Phase 1: DI 인프라 구축 (Day 1-3)

#### Step 1: 패키지 설치
```bash
flutter pub add get_it injectable
flutter pub add --dev injectable_generator build_runner
```

#### Step 2: 기본 구조 생성
```dart
// lib/app/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}
```

#### Step 3: main.dart 통합
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DI 초기화
  await configureDependencies();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  runApp(VersusApp());
}
```

### Phase 2: 전역 서비스 마이그레이션 (Day 4-7)

#### Step 1: Firebase 서비스 모듈
```dart
// lib/app/di/modules/firebase_module.dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;
  
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;
}
```

#### Step 2: 캐시 서비스 마이그레이션
```dart
// Before: lib/services/cache/unified_cache_service.dart
class UnifiedCacheService {
  static final _instance = UnifiedCacheService._();
  factory UnifiedCacheService() => _instance;
}

// After: lib/services/cache/unified_cache_service.dart
@lazySingleton
class UnifiedCacheService {
  // 싱글톤 패턴 제거
  // @lazySingleton 어노테이션이 처리
}
```

#### Step 3: AppState 분리 및 DI 통합
```dart
// lib/app/state/app_state.dart
@lazySingleton
class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  AppState(@factoryParam this._prefs);
  
  // 언어 설정 등 앱 레벨 상태만 유지
  String get selectedLang => _prefs.getString('lang') ?? 'en';
}

// lib/features/posts/presentation/providers/upload_state.dart
@injectable
class UploadState extends ChangeNotifier {
  // Posts Feature로 이동한 업로드 관련 상태
  List<String> uploadImageA = [];
  List<String> uploadVideoA = [];
}
```

### Phase 3: Feature 통합 (Day 8-14)

#### Step 1: Repository 패턴 도입
```dart
// lib/features/posts/domain/repositories/posts_repository.dart
abstract class PostsRepository {
  Future<PostModel> getPost(String id);
  Future<void> createPost(PostModel post);
}

// lib/features/posts/data/repositories/posts_repository_impl.dart
@Injectable(as: PostsRepository)
class PostsRepositoryImpl implements PostsRepository {
  final FirebaseFirestore _firestore;
  
  PostsRepositoryImpl(this._firestore);
  
  @override
  Future<PostModel> getPost(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    return PostModel.fromJson(doc.data()!);
  }
}
```

#### Step 2: Feature 서비스 DI 통합
```dart
// lib/features/auth/domain/services/auth_service.dart
@lazySingleton
class AuthService {
  final AuthRepository _repository;
  final FirebaseAuth _auth;
  
  AuthService(this._repository, this._auth);
  
  // 의존성 주입으로 테스트 가능
}
```

#### Step 3: Provider 통합
```dart
// lib/features/posts/presentation/providers/posts_provider.dart
class PostsProvider extends ChangeNotifier {
  final PostsRepository _repository;
  final UploadState _uploadState;
  
  // DI에서 주입
  PostsProvider() 
    : _repository = getIt<PostsRepository>(),
      _uploadState = getIt<UploadState>();
}
```

### Phase 4: 테스트 환경 구축 (Day 15-17)

#### Step 1: Mock 모듈 생성
```dart
// test/helpers/test_module.dart
@module
abstract class TestModule {
  @test
  @lazySingleton
  MockFirebaseAuth get mockAuth => MockFirebaseAuth();
  
  @test
  @lazySingleton
  MockFirebaseFirestore get mockFirestore => MockFirebaseFirestore();
}
```

#### Step 2: 테스트 설정
```dart
// test/helpers/test_setup.dart
Future<void> setupTestDependencies() async {
  await configureDependencies(environment: Environment.test);
}

void tearDownTestDependencies() {
  getIt.reset();
}
```

#### Step 3: 테스트 작성
```dart
// test/features/posts/posts_service_test.dart
void main() {
  setUpAll(() async {
    await setupTestDependencies();
  });
  
  tearDownAll(() {
    tearDownTestDependencies();
  });
  
  test('should create post', () async {
    final service = getIt<PostsService>();
    // Mock이 자동으로 주입됨
    
    await service.createPost(...);
    // 테스트 검증
  });
}
```

## 🔄 마이그레이션 체크리스트

### Week 1
- [ ] GetIt, Injectable 패키지 설치
- [ ] DI 기본 구조 생성
- [ ] main.dart DI 초기화 통합
- [ ] Firebase 서비스 모듈 생성
- [ ] UnifiedCacheService DI 전환
- [ ] AuthUtil → AuthService DI 전환

### Week 2
- [ ] AppState 분리 (업로드 상태 → Posts Feature)
- [ ] NotificationService DI 전환
- [ ] VoteStateCoordinator DI 전환
- [ ] Repository 패턴 도입 (Posts, Auth)
- [ ] Feature 서비스 DI 통합

### Week 3
- [ ] Provider 생성자 주입 전환
- [ ] Mock 모듈 생성
- [ ] 테스트 환경 구축
- [ ] 통합 테스트 작성
- [ ] 문서화 업데이트

## ⚠️ 위험 요소 및 대응

### 위험 1: 순환 의존성
**문제**: ServiceA → ServiceB → ServiceA
**해결**: 
- 인터페이스 추상화
- Factory 패턴 사용
- 의존성 그래프 검증

### 위험 2: 초기화 순서
**문제**: 의존성 초기화 순서 오류
**해결**:
- @Order 어노테이션 사용
- preResolve로 사전 초기화
- 명시적 순서 정의

### 위험 3: 메모리 누수
**문제**: Singleton이 계속 메모리 점유
**해결**:
- LazySingleton 적극 활용
- Scope 관리 철저
- dispose 패턴 구현

## 📊 성공 측정

### 정량적 지표
- 테스트 커버리지: 60% → 80%
- 앱 시작 시간: 현재 대비 ±5% 이내
- 메모리 사용량: 10% 감소 (Lazy Loading)

### 정성적 지표
- 새 Feature 추가 시간 단축
- Mock 테스트 작성 용이성
- 코드 리뷰 피드백 개선

## 🔄 롤백 계획

마이그레이션 실패 시:
1. Git branch 'di-migration' 삭제
2. 기존 싱글톤 패턴 유지
3. 부분적 DI 도입 재검토

## 📚 참고 자료

- [GetIt Best Practices](https://pub.dev/packages/get_it)
- [Injectable Code Generation](https://pub.dev/packages/injectable)
- [Flutter DI Patterns](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)

---

*이 마이그레이션은 Feature-First Architecture의 핵심 구성 요소입니다.*
*Phase별 진행으로 리스크를 최소화하며 점진적으로 적용합니다.*