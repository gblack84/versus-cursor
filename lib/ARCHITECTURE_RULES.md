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

// ✅ GOOD: 200줄이지만 하나의 비즈니스 트랜잭션
class RegisterUserUseCase {
  Future<User> execute(RegistrationData data) async {
    // 1. 이메일 중복 체크
    // 2. 비밀번호 강도 검증
    // 3. Auth 계정 생성
    // 4. Firestore 사용자 문서 생성
    // 5. 프로필 이미지 업로드
    // 6. 환영 이메일 발송
    // 7. 초기 설정 생성
    // 모두 "회원가입"의 필수 단계들
  }
}

// ✅ GOOD: 복잡하지만 하나의 완전한 프로세스
class PlaceOrderUseCase {
  Future<Order> execute(OrderRequest request) async {
    // 1. 재고 확인
    // 2. 가격 계산 및 할인 적용
    // 3. 결제 처리
    // 4. 주문 생성
    // 5. 재고 차감
    // 6. 알림 발송
    // 트랜잭션 보장 필요
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

// ❌ BAD: 50줄이지만 2개 책임 섞임
class SignInAndUpdateStatsUseCase {
  Future<User> execute(String email, String password) {
    // 로그인 (책임 1)
    final user = await authRepository.signIn(email, password);
    // 통계 업데이트 (책임 2 - 독립적, 다른 시점에도 호출)
    await statsRepository.updateLoginCount();
    return user;
  }
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

### 파일 분할 기준 (v4.1 - 레이어별 차별 적용)

#### Domain Layer (비즈니스 로직)
- **UseCase**: 비즈니스 트랜잭션 단위 (엄격)
  - 1 UseCase = 1 비즈니스 트랜잭션 = 1 파일
  - 하나의 유저 스토리/액션을 완성하는 단위
  - 줄 수 참고: Simple(50-100줄), Normal(100-300줄), Complex(300-500줄)

- **분할 기준** (하나라도 해당되면 분할 검토):
  - ✅ 다른 Actor가 독립적으로 사용하는 기능
  - ✅ 다른 시점에 호출되는 로직
  - ✅ 메서드명에 "And"가 필요함 (예: processOrderAndSendEmail)
  - ✅ 테스트 시나리오가 완전히 다름

- **통합 유지 기준** (이런 경우는 하나로):
  - ✅ 트랜잭션으로 묶여야 하는 작업들
  - ✅ 순서가 중요한 비즈니스 프로세스
  - ✅ 일부만 실행되면 의미가 없는 흐름
  - ✅ "회원가입", "주문하기" 같은 하나의 완전한 유저 액션

- **Repository Interface**: 100-150줄
- **Domain Model**: 150-200줄

#### Data Layer (데이터 처리)
- **Repository Implementation**: 200-300줄 (권장)
  - 300줄 초과 시 DataSource로 분리
- **DataSource**: 150-200줄
- **Mapper/Adapter**: 100-150줄
- **DTO**: Firebase 1:1 매핑 (줄 수 무관)
- **분할 트리거**: 300줄 초과 또는 복합 데이터소스

#### Presentation Layer (UI)
- **Screen Widget**: 500-800줄 (유연)
  - Flutter UI 특성상 허용
  - 비즈니스 로직은 UseCase로 추출
  - 800줄 초과 시 컴포넌트 분리 검토
- **Component Widget**: 200-300줄
- **Provider/Controller**: 150-200줄
- **분할 트리거**: 800줄 초과 또는 재사용 가능 컴포넌트

#### 예외 및 제외 사항
- ❌ 생성 코드 (*.g.dart, *.freezed.dart)
- ❌ 순수 스타일링 코드 (줄 수 계산에서 제외 가능)
- ❌ 테스트 파일 (별도 기준)
- ❌ Migration 파일 (임시)
- ❌ 라우팅 설정 파일

### 레이어 자동 감지 규칙
서브에이전트와 도구가 파일의 레이어를 자동으로 판단하는 기준:

#### 경로 기반 감지
- `/domain/` 포함 → Domain Layer (비즈니스 트랜잭션 단위)
- `/data/` 포함 → Data Layer (300줄 제한)
- `/presentation/` 포함 → Presentation Layer (800줄 제한)

#### 파일명 패턴 감지
- `*_use_case.dart` → Domain Layer (트랜잭션 단위, 50-500줄)
- `*_repository.dart` (interface) → Domain Layer (150줄)
- `*_repository_impl.dart` → Data Layer (300줄)
- `*_datasource.dart` → Data Layer (200줄)
- `*_mapper.dart` → Data Layer (150줄)
- `*_widget.dart` → Presentation Layer (800줄)
- `*_screen.dart` → Presentation Layer (800줄)
- `*_provider.dart` → Presentation Layer (200줄)

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
│   └── usecases/        # 비즈니스 트랜잭션별 분리
│       ├── cast_vote_use_case.dart           # 투표하기 (100줄)
│       ├── complete_voting_use_case.dart     # 투표 완료 처리 (250줄)
│       ├── check_user_vote_status_use_case.dart  # 상태 확인 (50줄)
│       └── ... (트랜잭션 단위로 50-500줄)
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