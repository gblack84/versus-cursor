# 🏗️ Clean Architecture 규칙 문서 v4.0 (Direct Migration)

> **최종 업데이트**: 2025-01-19
> **상태**: 🔴 엄격 적용 중
> **위치**: `/lib/ARCHITECTURE_RULES.md`
> **목적**: 아키텍처 일관성 유지 및 의존성 규칙 강제
> **전략**: 직접 마이그레이션 (Facade 패턴 없음)

---

## 📌 통합 철학: "기존 코드를 작은 단위로 분해하여 재구성"

> **Decompose & Reorganize**: 레거시 코드를 작은 UseCase로 분해하고, Clean Architecture로 재구성

### 핵심 원칙
1. **분해 (Decompose)**: 300줄 이상 파일 → 여러 작은 UseCase로 분할
2. **재사용 (Reuse)**: 새로 만들지 않고 기존 코드 이동/변환
3. **재구성 (Reorganize)**: 3-Layer Clean Architecture로 재배치
4. **보존 (Preserve)**: 모든 기능과 UI는 100% 유지
5. **직접 전환 (Direct)**: Facade 없이 즉시 Clean Architecture 적용

### 절대 규칙
1. **Core에 구현체 금지** - 인터페이스와 유틸리티만
2. **Feature 간 의존 금지** - 각 Feature는 완전 독립
3. **역방향 의존 금지** - 내부에서 외부로만 의존
4. **기존 코드 우선** - 있는 것은 이동, 없는 것만 생성

---

## 🏛️ 3계층 아키텍처 구조

```
lib/
├── app/           # 🚀 앱 조립 및 구현체
├── core/          # 📜 인터페이스 및 유틸리티
└── features/      # 📦 독립 기능 모듈
```

### 의존성 방향
```
Presentation → Domain → Data → Core (interfaces)
     ↓           ↓        ↓
    App/DI로 모든 구현체 조립
```

---

## 1️⃣ App Layer

### 구조
```dart
lib/app/
├── main.dart                        # 앱 진입점
├── app.dart                         # MaterialApp 설정
├── router/                          # 라우팅
├── implementations/                 # 🔴 Core 인터페이스 구현체
│   ├── cache_service_impl.dart
│   ├── logger_service_impl.dart
│   └── network_service_impl.dart
├── di/                              # 의존성 주입
│   ├── injection.dart              # GetIt 초기화
│   └── modules/                    # Feature 모듈 바인딩
└── navigation/                      # 네비게이션
```

### ✅ DO
```dart
// app/implementations/cache_service_impl.dart
class CacheServiceImpl implements ICacheService {
  @override
  Future<T?> get<T>(String key) async { /* 구현 */ }
}

// app/di/injection.dart
GetIt.I.registerLazySingleton<ICacheService>(
  () => CacheServiceImpl(),
);
```

### ❌ DON'T
```dart
// ❌ Feature의 구현체 직접 import
import 'package:versus_space/features/auth/data/repositories/auth_repository_impl.dart';
```

---

## 2️⃣ Core Layer

### 구조
```dart
lib/core/
├── interfaces/                      # 🔴 인터페이스만!
│   ├── i_cache_service.dart
│   ├── i_logger_service.dart
│   └── i_network_service.dart
├── models/                          # 공통 모델
│   ├── result.dart                 # Result<T> 타입
│   └── use_case.dart               # UseCase<I,O> 제네릭
├── utils/                           # 순수 유틸리티
└── widgets/                         # 비즈니스 무관 위젯
```

### ✅ DO
```dart
// core/interfaces/i_cache_service.dart
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
}

// core/models/result.dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
```

### ❌ DON'T
```dart
// ❌ Core에 구현체
class CacheService implements ICacheService { /* 구현 NO! */ }

// ❌ Core가 Feature 의존
import 'package:versus_space/features/auth/domain/models/user.dart';
```

---

## 3️⃣ Features Layer

### 구조
```dart
lib/features/[feature]/
├── domain/                          # 비즈니스 로직
│   ├── models/                     # 도메인 모델
│   ├── repositories/               # Repository 인터페이스
│   └── usecases/                   # 1 UseCase = 1 파일
├── data/                            # 데이터 레이어
│   ├── repositories/               # Repository 구현
│   ├── datasources/                # 외부 데이터 소스
│   ├── models/                     # DTO (Firebase 1:1)
│   ├── mappers/                    # DTO ↔ Domain 변환
│   └── adapters/                   # 외부 서비스 연동
├── presentation/                    # UI 레이어
│   ├── screens/
│   ├── widgets/
│   └── providers/                  # 상태관리
└── di/                              # Feature DI 모듈
    └── [feature]_di_module.dart
```

### ✅ DO
```dart
// domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<Result<User>> signIn(String email, String password);
}

// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
}

// domain/usecases/sign_in_use_case.dart (1파일 1UseCase)
class SignInUseCase {
  final IAuthRepository repository;

  Future<Result<User>> execute(String email, String password) {
    return repository.signIn(email, password);
  }
}
```

### ❌ DON'T
```dart
// ❌ Feature 간 의존
import 'package:versus_space/features/posts/domain/models/post.dart';

// ❌ 여러 UseCase 한 파일에
class AuthUseCases {  // NO! 분리하세요
  void signIn() {}
  void signOut() {}
  void getUser() {}
}
```

---

## 🔄 마이그레이션 가이드 (Direct Migration)

### 레거시 코드 처리 3단계

#### 1단계: 기존 코드 완전 분석
```bash
# 모든 사용처 파악 (필수!)
grep -r "getUserEmail\|currentUser\|userEmail" lib/
# 의존성 트리 작성 및 영향 범위 확인
```

#### 2단계: UseCase 생성 및 테스트
```dart
// 원본: auth_util.dart
String get currentUserEmail => currentUser?.email ?? '';

// ↓ 직접 이동 (Facade 없이)

// domain/usecases/get_current_user_email_use_case.dart
class GetCurrentUserEmailUseCase {
  final IAuthRepository repository;

  GetCurrentUserEmailUseCase(this.repository);

  String execute() => repository.getCurrentUser()?.email ?? '';
}

// 단위 테스트 필수
// test/features/auth/domain/usecases/get_current_user_email_use_case_test.dart
```

#### 3단계: 전체 교체 (Atomic Commit)
```bash
# 모든 참조를 한번에 교체
# 1. 모든 import 변경
# 2. 모든 사용처 UseCase로 교체
# 3. 테스트 통과 확인
# 4. 레거시 코드 삭제
# 5. 원자적 커밋
git add -A && git commit -m "feat(auth): Migrate to Clean Architecture without Facade"
```

### 직접 마이그레이션 원칙
- ⚡ **즉시 전환**: Facade 없이 바로 Clean Architecture 적용
- 🎯 **원자적 커밋**: 피처 단위로 완전 전환 후 커밋
- ✅ **완전성**: 레거시 코드 100% 제거
- 🧪 **테스트 필수**: 모든 UseCase에 단위 테스트

### 파일 분할 기준
- ✅ 300줄 초과 시 분할
- ✅ 여러 책임이 혼재
- ✅ 여러 UseCase가 한 파일에

### DTO/Mapper 전략

#### Firebase 1:1 원칙
```dart
// ✅ GOOD: Firebase 필드명 그대로
class UserDto {
  final String? uid;           // Firebase 'uid'
  final String? displayName;   // Firebase 'displayName'
}

// ❌ BAD: 새로운 필드명
class UserDto {
  final String? userId;       // NO! 'uid' 사용
}
```

#### 필드 생성 승인
1. Firebase 기존 필드 확인
2. 재사용 가능? → YES면 재사용
3. 정말 필요? → 승인 요청
4. 승인 후에만 새 필드 생성

---

## 📊 의존성 매트릭스

| From ↓ \ To → | App | Core | Feature/Domain | Feature/Data | Feature/Presentation |
|----------------|-----|------|----------------|--------------|---------------------|
| **App**        | ✅  | ✅   | ✅            | ❌*          | ❌**                |
| **Core**       | ❌  | ✅   | ❌            | ❌           | ❌                  |
| **Feature/Domain** | ❌ | ✅ | ✅            | ❌           | ❌                  |
| **Feature/Data** | ❌ | ✅  | ✅            | ✅           | ❌                  |
| **Feature/Presentation** | ❌ | ✅ | ✅     | ❌           | ✅                  |

> *App/di만 예외 (DI 조립용)
> **App/router만 예외 (라우팅용)

---

## 🏆 실전 예시: Voting Feature

```
/lib/features/voting/
├── domain/
│   └── usecases/        # 14개 UseCase = 14개 파일
│       ├── cast_vote_use_case.dart
│       ├── check_user_vote_status_use_case.dart
│       └── ... (각각 30-50줄)
├── data/
│   ├── repositories/
│   └── adapters/
└── di/
    └── voting_di_module.dart
```

**결과**: 100% Clean Architecture, AI 개발 효율 3-5배 향상

---

## ✅ 직접 마이그레이션 체크리스트

### 마이그레이션 전
- [ ] 모든 사용처 완전 파악
- [ ] 의존성 트리 작성
- [ ] Firebase 스키마 확인
- [ ] 영향 범위 분석

### 구현 중
- [ ] 1 UseCase = 1 파일
- [ ] Repository 인터페이스 domain에
- [ ] DTO는 Firebase 1:1
- [ ] Mapper는 data/mappers에
- [ ] DI 모듈 생성
- [ ] 단위 테스트 작성

### 전환 실행
- [ ] 모든 import 일괄 변경
- [ ] 모든 사용처 UseCase로 교체
- [ ] 통합 테스트 실행
- [ ] 레거시 코드 완전 제거
- [ ] 원자적 커밋 (Atomic Commit)

### 완료 후
- [ ] Migration Manifest 작성
- [ ] 문서 업데이트
- [ ] 팀 공유

---

## 📋 부록

### Migration Manifest 템플릿 (Direct Migration)
```yaml
feature: [feature_name]
date: YYYY-MM-DD
status: in_progress
migration_type: direct  # direct migration without Facade

# 마이그레이션 범위
migration_scope:
  files_affected: [number]
  references_updated: [number]
  tests_added: [number]

# 코드 이동 추적
moved_code:
  - from: lib/[old_path]/[old_file].dart
    to: lib/features/[feature]/domain/usecases/
    lines: "1000 → 14 files × 50 lines"

# 직접 전환 검증
atomic_commit:
  commit_hash: [hash]
  all_tests_passing: true
  rollback_possible: true

# DTO 매핑
dto_mapping:
  existing_reused: 13  # 86.7%
  newly_created: 2     # 13.3%

# 통합 지점
integration_points:
  di: lib/app/di.dart imports [feature]_di_module.dart
  router: lib/app/router.dart imports [feature] screens

# 검증 체크리스트
verification:
  - [x] 모든 레거시 참조 제거
  - [x] 새 UseCase로 완전 교체
  - [x] 기능 동작 확인
  - [x] 성능 저하 없음
```

### Lint 설정 (analysis_options.yaml)
```yaml
analyzer:
  errors:
    depend_on_referenced_packages: error

custom_lint:
  rules:
    # Core → Features 금지
    - avoid_imports:
        from: "lib/core/**"
        to: "lib/features/**"
        severity: error

    # Features 간 의존 금지
    - avoid_imports:
        from: "lib/features/*/[!domain]/**"
        to: "lib/features/[!$1]/**"
        severity: error
```

### 완료된 Features
- [x] **Voting** - 100% Clean Architecture ✅
- [x] **Notifications** - 100% Clean Architecture ✅
- [ ] **Auth** - 진행 중
- [ ] **Posts**
- [ ] **Profile**
- [ ] **Chat**
- [ ] **Search**

---

## 📚 참고 자료
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)

---

**이 문서는 프로젝트의 아키텍처 일관성을 위한 절대 규칙입니다.**
**모든 개발자는 이 규칙을 엄격히 준수해야 합니다.**