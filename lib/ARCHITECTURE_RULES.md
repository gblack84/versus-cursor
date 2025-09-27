# 🏗️ Clean Architecture 규칙 문서 v5.1 (책임 기반 아키텍처)

> **최종 업데이트**: 2025-01-27
> **상태**: 🟡 유연한 적용 (책임 기반)
> **위치**: `/lib/ARCHITECTURE_RULES.md`
> **목적**: 아키텍처 일관성 유지 및 의존성 규칙 강제
> **전략**: 책임 기반 분해 + 계약 패턴 (Contract Pattern)

---

## 📌 통합 철학: "기존 코드를 작은 단위로 분해하여 재구성"

> **Decompose & Reorganize**: 레거시 코드를 작은 UseCase로 분해하고, Clean Architecture로 재구성

### 핵심 원칙 (v5.1 - 책임 기반)
1. **책임 분해 (Responsibility-Based)**: 하나의 파일 = 하나의 명확한 책임
2. **응집도 우선 (Cohesion First)**: 높은 응집도의 코드는 함께 유지 (400-500줄도 OK)
3. **플로우 중심 (Flow-Oriented)**: 완전한 비즈니스 플로우 단위로 모듈화
4. **재사용 (Reuse)**: 새로 만들지 않고 기존 코드 이동/변환
5. **재구성 (Reorganize)**: 3-Layer Clean Architecture로 재배치
6. **보존 (Preserve)**: 모든 기능과 UI는 100% 유지
7. **직접 전환 (Direct)**: Facade 없이 즉시 Clean Architecture 적용

### 절대 규칙
1. **Core에 구현체 금지** - 기술 인터페이스와 유틸리티만
2. **Feature 간 직접 의존 금지** - Contract을 통한 간접 통신만 허용
3. **역방향 의존 금지** - Presentation → Domain → Data → Contract
4. **계약 중립성** - Contract은 app/contracts에만 정의
5. **기존 코드 우선** - 있는 것은 이동, 없는 것만 생성

---

## 🏛️ 아키텍처 구조

```
lib/
├── app/           # 🚀 앱 조립 및 설정
│   └── contracts/ # 🤝 Feature 간 통신 계약
├── core/          # 🛠️ 기술 유틸리티 (비즈니스 무관)
└── features/      # 📦 독립 기능 모듈
```

### 의존성 방향
```
Presentation → Domain → Data → Contract
                              ↘
app/contracts (중립 지대)    ←  다른 Feature도 사용
```

---

## 1️⃣ App Layer

### 구조
```dart
lib/app/
├── main.dart                        # 앱 진입점
├── app.dart                         # MaterialApp 설정
├── contracts/                       # 🤝 Feature 간 통신 계약 (중립 지대)
│   ├── auth_contract.dart          # Auth Feature가 제공하는 계약
│   ├── post_contract.dart          # Posts Feature가 제공하는 계약
│   ├── user_contract.dart          # User Feature가 제공하는 계약
│   ├── vote_contract.dart          # Voting Feature가 제공하는 계약
│   └── notification_contract.dart  # Notifications Feature가 제공하는 계약
├── router/                          # 라우팅
├── implementations/                 # Core 기술 인터페이스 구현체
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
// app/contracts/post_contract.dart
abstract class PostContract {
  // 다른 Feature가 필요한 메서드만 공개
  Future<Map<String, dynamic>?> getPost(String postId);
  Future<bool> postExists(String postId);
  // createPost, deletePost 등은 공개하지 않음
}

// app/di/injection.dart
final postRepo = PostRepositoryImpl();
GetIt.I.registerSingleton<IPostRepository>(postRepo);  // 내부용
GetIt.I.registerSingleton<PostContract>(postRepo);     // 외부용 (같은 인스턴스)
```

### ❌ DON'T
```dart
// ❌ Feature 간 직접 import
import 'package:versus_space/features/posts/domain/models/post.dart';

// ❌ Contract을 Feature 안에 정의
// features/notifications/data/datasources/i_post_datasource.dart
abstract class IPostDatasource { }  // NO! app/contracts에 정의해야 함
```

---

## 2️⃣ Core Layer

### 구조
```dart
lib/core/
├── interfaces/                      # 🛠️ 기술 인터페이스만 (비즈니스 무관)
│   ├── i_cache_service.dart        # 캐싱 서비스 인터페이스
│   ├── i_logger_service.dart       # 로깅 서비스 인터페이스
│   └── i_network_service.dart      # 네트워크 서비스 인터페이스
├── models/                          # 공통 모델
│   ├── result.dart                 # Result<T> 타입
│   └── use_case.dart               # UseCase<I,O> 제네릭
├── utils/                           # 순수 유틸리티
│   ├── date_formatter.dart         # 날짜 포맷 유틸
│   └── validators.dart             # 입력 검증 유틸
└── widgets/                         # 비즈니스 무관 공통 위젯
    ├── loading_indicator.dart       # 로딩 표시 위젯
    └── error_widget.dart           # 에러 표시 위젯
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

// ❌ Core에 비즈니스 인터페이스
abstract class IVoteService { }  // NO! 비즈니스 로직은 Core에 없어야 함

// ❌ Core가 Feature 의존
import 'package:versus_space/features/auth/domain/models/user.dart';
```

---

## 3️⃣ Features Layer

### 구조 및 파일명 규칙
```dart
lib/features/[feature_name]/
├── domain/                          # 비즈니스 로직
│   ├── models/                     # 도메인 모델
│   │   ├── user.dart               # User 엔티티
│   │   └── auth_token.dart         # AuthToken 엔티티
│   ├── repositories/               # Repository 인터페이스 (내부용)
│   │   └── i_[feature]_repository.dart
│   │       └── i_auth_repository.dart  # 예: Auth 리포지토리 인터페이스
│   └── usecases/                   # 1 UseCase = 1 파일
│       ├── sign_in_usecase.dart    # 로그인 유스케이스
│       ├── sign_out_usecase.dart   # 로그아웃 유스케이스
│       └── get_current_user_usecase.dart
├── data/                            # 데이터 레이어
│   ├── repositories/               # Repository 구현 (Contract도 구현)
│   │   └── [feature]_repository_impl.dart
│   │       └── auth_repository_impl.dart  # 예: AuthRepositoryImpl
│   ├── datasources/                # 외부 데이터 소스
│   │   ├── i_[feature]_remote_datasource.dart
│   │   ├── [feature]_remote_datasource_impl.dart
│   │   └── [feature]_local_datasource_impl.dart
│   ├── dto/                        # Data Transfer Objects
│   │   ├── user_dto.dart           # Firebase와 1:1 매핑
│   │   └── auth_response_dto.dart
│   └── mappers/                    # DTO ↔ Domain 변환
│       ├── user_mapper.dart
│       └── auth_token_mapper.dart
├── presentation/                    # UI 레이어
│   ├── screens/
│   │   ├── login_screen.dart       # 로그인 화면
│   │   └── profile_screen.dart     # 프로필 화면
│   ├── widgets/
│   │   ├── login_form_widget.dart
│   │   └── user_avatar_widget.dart
│   └── providers/                  # 상태관리
│       └── auth_provider.dart
└── di/                              # Feature DI 모듈
    └── auth_di_module.dart
```

### ✅ DO
```dart
// app/contracts/auth_contract.dart (중립 지대)
abstract class AuthContract {
  Future<String?> getCurrentUserId();
  Future<bool> isAuthenticated();
  Stream<bool> authStateChanges();
}

// features/auth/domain/repositories/i_auth_repository.dart (내부용)
abstract class IAuthRepository {
  Future<Result<User>> signIn(String email, String password);
  Future<void> signOut();
  // ... 모든 Auth 기능
}

// features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements IAuthRepository, AuthContract {
  // IAuthRepository 메서드들 (내부용)
  @override
  Future<Result<User>> signIn(String email, String password) { ... }

  // AuthContract 메서드들 (외부 Feature용)
  @override
  Future<String?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?.uid;
  }
}

// features/voting/domain/usecases/submit_vote_usecase.dart
class SubmitVoteUseCase {
  final AuthContract authContract;  // Contract 사용

  Future<void> execute(String postId) async {
    final userId = await authContract.getCurrentUserId();
    // ...
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
// ❌ Feature 간 직접 의존
import 'package:versus_space/features/posts/domain/models/post.dart';

// ❌ Contract을 Feature 안에 정의
// features/notifications/data/datasources/i_post_datasource.dart
abstract class IPostDatasource { }  // NO! app/contracts/post_contract.dart에!

// ❌ Port/Adapter 패턴 (제거됨)
// features/voting/domain/ports/i_vote_service.dart  // NO! 사용하지 않음
// features/voting/data/adapters/vote_adapter.dart   // NO! Repository가 직접 구현

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

## 🤝 계약 패턴 (Contract Pattern)

### 개념
Feature 간 통신을 위한 최소한의 인터페이스를 중립 지대(app/contracts)에 정의

### 원칙
1. **최소 공개**: 필요한 메서드만 Contract에 포함
2. **중립성**: app/contracts에만 정의 (Feature 안 X)
3. **단방향**: Contract 제공자는 사용자를 모름
4. **타입 안전**: 컴파일 타임에 오류 체크

### 구현 예제

#### Step 1: Contract 정의
```dart
// app/contracts/post_contract.dart
abstract class PostContract {
  // Voting, Notifications가 필요한 것만
  Future<Map<String, dynamic>?> getPost(String postId);
  Future<bool> postExists(String postId);
  // createPost, deletePost 등은 공개 안 함
}

// app/contracts/vote_contract.dart
abstract class VoteContract {
  Future<void> submitVote(String postId, String userId, String choice);
  Future<bool> hasUserVoted(String postId, String userId);
}
```

#### Step 2: Repository에서 Contract 구현
```dart
// features/posts/data/repositories/post_repository_impl.dart
class PostRepositoryImpl implements IPostRepository, PostContract {
  // IPostRepository 메서드들 (내부용 - 모든 기능)
  @override
  Future<void> createPost(...) { }

  @override
  Future<void> deletePost(...) { }

  // PostContract 메서드들 (외부용 - 선택적 공개)
  @override
  Future<Map<String, dynamic>?> getPost(String postId) { }

  @override
  Future<bool> postExists(String postId) { }
}
```

#### Step 3: DI 설정
```dart
// app/di/injection.dart
void configureDependencies() {
  // Repository 인스턴스 생성
  final postRepo = PostRepositoryImpl();
  final voteRepo = VoteRepositoryImpl();

  // 내부용 등록
  getIt.registerSingleton<IPostRepository>(postRepo);
  getIt.registerSingleton<IVoteRepository>(voteRepo);

  // 외부용 Contract 등록 (같은 인스턴스)
  getIt.registerSingleton<PostContract>(postRepo);
  getIt.registerSingleton<VoteContract>(voteRepo);
}
```

#### Step 4: 다른 Feature에서 사용
```dart
// features/voting/domain/usecases/submit_vote_usecase.dart
class SubmitVoteUseCase {
  final PostContract postContract;  // Contract만 의존

  Future<void> execute(String postId) async {
    // Contract에 정의된 메서드만 사용 가능
    if (await postContract.postExists(postId)) {
      final post = await postContract.getPost(postId);
      // 투표 로직...
    }
  }
}
```

---

## 🔄 마이그레이션 가이드 (Contract Pattern Migration)

### Port/Adapter → Contract 마이그레이션

#### Before (Port/Adapter)
```dart
features/voting/
├── domain/ports/          # 제거 대상
│   └── i_vote_service.dart
├── data/adapters/         # 제거 대상
│   └── vote_service_impl.dart
```

#### After (Contract Pattern)
```dart
app/contracts/
└── vote_contract.dart     # 새로 생성

features/voting/
├── data/repositories/
│   └── vote_repository_impl.dart  # Contract 구현 추가
```

### 마이그레이션 단계

#### 1단계: Contract 생성
```dart
// app/contracts/vote_contract.dart
abstract class VoteContract {
  // 외부에서 필요한 메서드만
  Future<void> submitVote(...);
  Future<bool> hasUserVoted(...);
}
```

#### 2단계: Repository 수정
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

### 📋 책임 기반 분해 원칙 (v5.1 - Responsibility-Based Decomposition)

`★ Insight ─────────────────────────────────────`
줄 수는 단순한 참고 지표입니다. 진정한 기준은 책임(Responsibility),
응집도(Cohesion), 그리고 완전한 플로우(Complete Flow)입니다.
`─────────────────────────────────────────────────`

#### 🎯 우선순위 원칙

1. **Single Responsibility (단일 책임)**
   - 각 파일/클래스는 변경의 이유가 하나만 있어야 함
   - 다른 Actor의 요구사항이 섞이지 않음

2. **High Cohesion (높은 응집도)**
   - 관련된 기능은 함께 유지
   - 400-500줄이어도 응집도가 높으면 분리하지 않음

3. **Complete Flow (완전한 플로우)**
   - 하나의 비즈니스 플로우는 분산시키지 않음
   - 트랜잭션 경계 내의 작업은 함께 유지

4. **Testability (테스트 가능성)**
   - 독립적으로 테스트 가능한 단위로 분리
   - 복잡한 의존성이 없어야 함

#### ⚡ 분해 트리거 (언제 분리할 것인가?)

**즉시 분리해야 할 경우:**
- ❗ 2개 이상의 독립적인 책임이 명확히 존재
- ❗ 서로 다른 Actor가 서로 다른 이유로 변경 요구
- ❗ 재사용 가능한 컴포넌트가 포함되어 있음
- ❗ 테스트 시나리오가 완전히 독립적임
- ❗ 서로 다른 데이터 소스를 다루고 있음

**분리를 고려해야 할 경우:**
- ⚠️ 600줄을 초과하면서 여러 기능이 섞여 있음
- ⚠️ 의존성 주입이 5개 이상 필요함
- ⚠️ private 메서드가 10개 이상임
- ⚠️ 코드 읽기가 어려워짐 (cognitive load 증가)

#### ✅ 유지 조건 (언제 함께 둘 것인가?)

**반드시 함께 유지:**
- ✅ 하나의 완전한 비즈니스 트랜잭션
- ✅ 원자적으로 실행되어야 하는 작업들
- ✅ 순서가 중요한 단계적 프로세스
- ✅ 높은 응집도의 관련 기능들
- ✅ 500줄이어도 단일 책임이면 OK

**예시:**
```dart
// ✅ GOOD: 450줄이지만 하나의 완전한 플로우
class CreatePostFlow {
  // 이미지 선택 → 편집 → 검증 → 업로드 → 게시
  // 모든 단계가 "게시물 생성"이라는 단일 책임
}

// ❌ BAD: 200줄이지만 2개의 독립적 책임
class PostAndStatsService {
  // 게시물 CRUD (책임 1)
  // 통계 업데이트 (책임 2) → 분리 필요!
}
```

#### 🏗️ 플로우 기반 모듈화 패턴

##### 사용자 플로우별 분해
```yaml
게시물 작성 플로우:
  image_selection_flow.dart    # 선택 단계 (200-400줄 OK)
  image_editing_flow.dart       # 편집 단계 (200-400줄 OK)
  image_validation_flow.dart    # 검증 단계 (150-300줄 OK)
  image_upload_flow.dart        # 업로드 단계 (200-400줄 OK)
  → 각각 명확한 단계별 책임을 가짐
```

##### Domain Aggregate 경계별 분해
```yaml
Post Aggregate:
  post_command_handler.dart     # 생성/수정/삭제 명령
  post_query_service.dart        # 조회 전용
  post_event_processor.dart     # 이벤트 처리
  → Bounded Context 경계에 따라 분리
```

#### 📏 레이어별 가이드라인 (권장사항, 절대 규칙 아님)

##### Domain Layer (비즈니스 로직)
- **UseCase**:
  - 비즈니스 트랜잭션 단위 (줄 수 무관)
  - 참고: 50-500줄 (하지만 완전한 플로우면 700줄도 OK)
  - 핵심: 단일 비즈니스 목적

- **Repository Interface**:
  - 100-200줄 권장
  - 하지만 복잡한 도메인은 더 클 수 있음

##### Data Layer (데이터 처리)
- **Repository Implementation**:
  - 200-500줄 권장
  - 데이터 소스가 복잡하면 DataSource로 분리
  - 단순 CRUD면 600줄도 허용

- **DataSource**:
  - 150-300줄 권장
  - 외부 서비스별로 분리

##### Presentation Layer (UI)
- **Screen Widget**:
  - 500-1000줄 허용 (Flutter 특성)
  - UI 복잡도에 따라 유연하게
  - 비즈니스 로직만 UseCase로 추출

- **Component Widget**:
  - 재사용 가능하면 분리
  - 줄 수는 부차적

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