# Versus Space - 로깅 시스템 완전 가이드

> **개발(DevLogger) + 운영(Production Logger) 통합 문서**
> 최종 업데이트: 2025-11-21
> 완성도: DevLogger 86% (64/74 UseCases) | Production 100% (Phase 1-4)

---

## 📋 목차

- [빠른 시작 (3분)](#-빠른-시작-3분)
- [두 시스템 개요](#-두-시스템-개요)
- [DevLogger - 개발 디버깅](#-devlogger---개발-디버깅)
- [Production Logger - 운영 모니터링](#-production-logger---운영-모니터링)
- [Domain Logger 레퍼런스](#-domain-logger-레퍼런스)
- [새 Feature 통합 가이드](#-새-feature-통합-가이드)
- [의사결정 플로우차트](#-의사결정-플로우차트)
- [문제 해결](#-문제-해결)

---

## ⚡ 빠른 시작 (3분)

### DevLogger 예시 (UseCase - Domain Layer)

```dart
import '/services/logging/dev_logger.dart';

class SignInWithEmailUseCase {
  Future<Either<AuthFailure, User>> execute(String email, String password) async {
    // 1️⃣ 입력 파라미터 로깅
    DevLogger.params({'email': email}, tag: 'SignIn');

    // 2️⃣ 비즈니스 로직 체크포인트
    DevLogger.checkpoint('Validating email format', tag: 'SignIn');

    final result = await _repository.signIn(email, password);

    // 3️⃣ 결과 로깅 (Either 패턴)
    result.fold(
      (failure) => DevLogger.result(
        isSuccess: false,
        data: failure.toString(),
        tag: 'SignIn',
      ),
      (user) => DevLogger.result(
        isSuccess: true,
        data: user.uid,
        tag: 'SignIn',
      ),
    );

    return result;
  }
}
```

### Production Logger 예시 (Repository - Data Layer)

```dart
import '/services/logging/logger_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  Future<Either<AuthFailure, User>> signIn(String email, String password) async {
    try {
      // 1️⃣ 시작 로그 (INFO → Firebase Analytics)
      AuthLogger.signInAttempt(authMethod: 'email');

      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ 성공 로그 (INFO → Firebase Analytics)
      AuthLogger.signInSuccess(userId: user.uid, authMethod: 'email');
      return right(user);

    } on FirebaseAuthException catch (e, stackTrace) {
      // 3️⃣ 에러 로그 (ERROR → Firebase Crashlytics)
      AuthLogger.signInError(
        authMethod: 'email',
        error: e,
      );
      return left(AuthFailure.fromFirebaseException(e));
    }
  }
}
```

---

## 🏗 두 시스템 개요

### 비교 표

| 특징 | DevLogger | Production Logger |
|------|-----------|-------------------|
| **위치** | Domain Layer (UseCase) | Data Layer (Repository) |
| **목적** | 개발 디버깅, 비즈니스 로직 추적 | 운영 모니터링, 에러 추적 |
| **환경** | Development만 (`kDebugMode == true`) | Production (`kDebugMode == false`) |
| **출력** | Console (debugPrint) | Firebase Analytics + Crashlytics |
| **방법 개수** | 5개 (params, checkpoint, result, validation, error) | 4 Levels (DEBUG, INFO, WARNING, ERROR) |
| **코드 크기** | ~14KB (dev_logger.dart) | ~80KB (logger_service.dart) |
| **완성도** | 86% (64/74 UseCases) | 100% (Phase 1-4 완료) |
| **Firebase 전송** | ❌ 없음 | ✅ Analytics + Crashlytics |
| **Tree-shaking** | ✅ Production 빌드에서 완전 제거 | ❌ Production에 포함 |
| **PII 마스킹** | 권장 (개발 편의) | 필수 (GDPR 준수) |

### 아키텍처 다이어그램

```
┌────────────────────────────────────────────────────────────┐
│                   Presentation Layer                        │
│                  (Riverpod Providers)                       │
└──────────────────┬─────────────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────────────┐
│                    Domain Layer                             │
│                   (UseCases)                                │
│                                                             │
│   ✅ DevLogger 통합 (86% 완료, 64/74 UseCases)              │
│   • params()     - 입력 파라미터                            │
│   • checkpoint() - 비즈니스 로직 단계                        │
│   • result()     - Either<Failure, Success> 결과            │
│   • validation() - 유효성 검증 실패                          │
│   • error()      - 예외 처리                                │
│                                                             │
│   📊 Pattern 분포:                                          │
│   • Type A (Simple CRUD): 80%                               │
│   • Type B (Idempotent): 10%                                │
│   • Type C (Stream): 8%                                     │
│   • Type D (Complex): 2%                                    │
└──────────────────┬─────────────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────────────┐
│                     Data Layer                              │
│                  (Repositories)                             │
│                                                             │
│   ✅ Production Logger 통합 (100% 완료)                      │
│   • DEBUG   - 개발 디버깅 (Console만)                       │
│   • INFO    - 비즈니스 메트릭 (Analytics 100%)               │
│   • WARNING - 잠재적 문제 (Crashlytics 20-30%)              │
│   • ERROR   - 에러 추적 (Crashlytics 100%)                  │
│                                                             │
│   🔥 Firebase 통합:                                          │
│   • Analytics: 무제한 이벤트 (INFO)                          │
│   • Crashlytics: 10K non-fatal/월 (ERROR + WARNING)         │
└──────────────────┬─────────────────────────────────────────┘
                   │
                   ▼
         ┌─────────┴─────────┐
         ▼                   ▼
   ┌──────────┐       ┌──────────────┐
   │ Firebase │       │   Firebase   │
   │Analytics │       │ Crashlytics  │
   │ (INFO)   │       │(ERROR+WARNING)│
   └──────────┘       └──────────────┘
```

---

## 🔵 DevLogger - 개발 디버깅

### 개요

**위치**: `lib/services/logging/dev_logger.dart` (305줄)
**목적**: Domain Layer UseCase에서 비즈니스 로직 추적
**완성도**: 86% (64/74 UseCases 통합 완료)
**특징**: `kDebugMode` tree-shaking으로 Production 빌드에서 완전 제거 (0 바이트)

### 5가지 메서드

#### 1. `params()` - 입력 파라미터 로깅

```dart
DevLogger.params({
  'userId': userId,
  'postId': postId,
}, tag: 'LikePost');

// 출력:
// 🟦 [LikePost] params: userId=user123, postId=post456
```

#### 2. `checkpoint()` - 비즈니스 로직 단계

```dart
DevLogger.checkpoint('Validating email format', tag: 'SignIn');

// 출력:
// 🟦 [SignIn] checkpoint: Validating email format
```

#### 3. `result()` - 최종 결과 (Either 패턴)

```dart
result.fold(
  (failure) => DevLogger.result(
    isSuccess: false,
    data: failure.toString(),
    tag: 'SignIn',
  ),
  (user) => DevLogger.result(
    isSuccess: true,
    data: user.uid,
    tag: 'SignIn',
  ),
);

// 출력 (성공):
// 🟦 [SignIn] result: SUCCESS | user123
//
// 출력 (실패):
// 🟦 [SignIn] result: FAILURE | AuthFailure.invalidCredentials
```

#### 4. `validation()` - 유효성 검증 실패

```dart
if (email.isEmpty) {
  DevLogger.validation(
    field: 'email',
    reason: 'Email is required',
    tag: 'SignIn',
  );
  return left(AuthFailure.invalidEmail());
}

// 출력:
// 🟦 [SignIn] validation: email - Email is required
```

#### 5. `error()` - 예외 처리

```dart
try {
  await _repository.signIn(email, password);
} catch (e, stackTrace) {
  DevLogger.error(
    'Firebase Auth exception',
    error: e,
    stackTrace: stackTrace,
    tag: 'SignIn',
  );
  return left(AuthFailure.serverError(e.toString()));
}

// 출력:
// 🟦 [SignIn] error: Firebase Auth exception
// FirebaseAuthException(code: user-not-found)
// Stack trace: ...
```

### 4가지 패턴

#### Pattern A: Simple CRUD (80% 사용)

```dart
class GetUserProfileUseCase {
  Future<Either<ProfileFailure, UserProfile>> call(String userId) async {
    DevLogger.params({'userId': userId}, tag: 'GetUserProfile');

    final result = await _repository.getUserProfile(userId);

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'GetUserProfile'),
      (profile) => DevLogger.result(isSuccess: true, data: profile.uid, tag: 'GetUserProfile'),
    );

    return result;
  }
}
```

#### Pattern B: Idempotent (10% 사용)

```dart
class CreatePostUseCase {
  Future<Either<PostFailure, Unit>> execute(PostCreation post) async {
    DevLogger.params({'title': post.title}, tag: 'CreatePost');

    if (post.title.isEmpty) {
      DevLogger.validation(field: 'title', reason: 'Title is empty', tag: 'CreatePost');
      return left(PostFailure.invalidInput(field: 'title'));
    }

    final eventId = _uuid.v4();
    DevLogger.checkpoint('Calling repository with eventId: $eventId', tag: 'CreatePost');

    final result = await _repository.createPost(post, eventId);

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'CreatePost'),
      (_) => DevLogger.result(isSuccess: true, data: {'eventId': eventId}, tag: 'CreatePost'),
    );

    return result;
  }
}
```

#### Pattern C: Stream (8% 사용)

```dart
class WatchChatListUseCase {
  Stream<Either<ChatFailure, List<Chat>>> execute(String userId) async* {
    DevLogger.params({'userId': userId}, tag: 'WatchChatList');
    DevLogger.checkpoint('Starting chat list stream', tag: 'WatchChatList');

    await for (final either in _repository.watchChatList(userId)) {
      either.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'WatchChatList'),
        (chats) => DevLogger.result(isSuccess: true, data: {'count': chats.length}, tag: 'WatchChatList'),
      );

      yield either;
    }
  }
}
```

#### Pattern D: Complex (2% 사용)

```dart
class SubmitVoteUseCase {
  Future<Either<VotingFailure, Vote>> call(String voteId, VoteOption option) async {
    DevLogger.params({'voteId': voteId, 'option': option.name}, tag: 'SubmitVote');

    // Multi-step validation
    if (voteId.isEmpty) {
      DevLogger.validation(field: 'voteId', reason: 'VoteId is empty', tag: 'SubmitVote');
      return left(VotingFailure.invalidInput());
    }

    DevLogger.checkpoint('Checking if user already voted', tag: 'SubmitVote');
    final hasVoted = await _repository.hasUserVoted(voteId, _currentUserId);
    if (hasVoted) {
      DevLogger.result(isSuccess: false, data: 'Already voted', tag: 'SubmitVote');
      return left(VotingFailure.alreadyVoted());
    }

    DevLogger.checkpoint('Submitting vote with idempotency', tag: 'SubmitVote');
    final eventId = _uuid.v4();

    final result = await _repository.submitVote(voteId, option, eventId);

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SubmitVote'),
      (vote) => DevLogger.result(isSuccess: true, data: {'eventId': eventId, 'voteCount': vote.totalVotes}, tag: 'SubmitVote'),
    );

    return result;
  }
}
```

### Feature별 완성도

| Feature | UseCases | DevLogger 통합 | 완성도 | 주요 패턴 |
|---------|----------|---------------|--------|----------|
| **Auth** | 12 | 12/12 | 100% | A (80%), B (20%) |
| **Profile** | 11 | 11/11 | 100% | A (90%), C (10%) |
| **Chat** | 10 | 10/10 | 100% | A (70%), C (30%) |
| **Voting** | 8 | 8/8 | 100% | B (50%), D (50%) |
| **Creation** | 8 | 6/8 | 75% | B (60%), D (40%) |
| **Post** | 7 | 7/7 | 100% | A (100%) |
| **Notifications** | 7 | 7/7 | 100% | A (85%), C (15%) |
| **Search** | 4 | 3/4 | 75% | A (100%) |

**전체**: 64/74 UseCases (86%)

---

## 🔥 Production Logger - 운영 모니터링

### 개요

**위치**: `lib/services/logging/logger_service.dart` (4,295줄)
**목적**: Data Layer Repository에서 운영 모니터링 및 에러 추적
**완성도**: 100% (Phase 1-4 완료, 19 Domain Loggers)
**Firebase 통합**: Analytics (INFO) + Crashlytics (ERROR + WARNING)

### 4가지 로깅 레벨

| 레벨 | Development | Production | Firebase 전송 | 사용 시기 |
|------|-------------|-----------|--------------|----------|
| **DEBUG** | ✅ Console | ❌ 제거 | 없음 | 개발 중 상세 디버깅 |
| **INFO** | ✅ Console | ✅ Console | Analytics 100% | 사용자 행동, 비즈니스 메트릭 |
| **WARNING** | ✅ Console | ✅ Console | Crashlytics 20-30% | 잠재적 문제, 성능 저하 |
| **ERROR** | ✅ Console | ✅ Console | Crashlytics 100% | 에러, 실패 |

### 실전 예시

#### INFO: 비즈니스 메트릭 추적

```dart
// 1. 사용자 액션
AuthLogger.signInAttempt(authMethod: 'email');
// → Firebase Analytics: 'auth_sign_in_attempt' { method: 'email' }

// 2. 콘텐츠 생성
PostLogger.postCreated(postId: postId, authorId: authorId);
// → Firebase Analytics: 'post_created' { post_id: '***', author_id: '***' }

// 3. 투표 제출
VotingLogger.voteSubmitted(voteId: voteId, userId: userId, option: 'A');
// → Firebase Analytics: 'vote_submitted' { vote_id: '***', option: 'A' }
```

#### ERROR: 에러 추적

```dart
try {
  await _auth.signInWithEmailAndPassword(email: email, password: password);
} on FirebaseAuthException catch (e, stackTrace) {
  // Firebase Crashlytics 자동 전송
  AuthLogger.signInError(authMethod: 'email', error: e);
  // → Crashlytics: Non-fatal error with stack trace
  return left(AuthFailure.fromFirebaseException(e));
}
```

#### WARNING: 잠재적 문제

```dart
// 키워드 포함 → Crashlytics 전송 (20-30%)
CacheLogger.cacheWarning(
  operation: 'get',
  reason: 'L1 hit rate degraded: 15% (expected 30%+)',  // 'degraded' 키워드
);

// 키워드 없음 → Console만
PostLogger.postWarning(
  postId: postId,
  reason: 'Post has no images',
);
```

### PII 마스킹

```dart
// ❌ 위험: PII 노출
AuthLogger.signInAttempt(authMethod: 'email: user@example.com');

// ✅ 안전: PII 마스킹
AuthLogger.signInAttempt(
  authMethod: 'email: ${Logger.maskSensitive('user@example.com')}',
);
// → "email: u***@e***.com"

// ✅ 자동 마스킹 내장 메서드
AuthLogger.signInSuccess(
  userId: userId,  // 자동 마스킹됨
  email: email,    // 자동 마스킹됨
);
```

---

## 📚 Domain Logger 레퍼런스

### Critical 5 Loggers (가장 많이 사용)

| Logger | 위치 | 사용 시기 | 주요 메서드 |
|--------|------|-----------|------------|
| **AuthLogger** | logger_service.dart:2736 | 인증, 로그인, 회원가입 | `signInAttempt()`, `signInSuccess()`, `signInError()` |
| **PostLogger** | logger_service.dart:1328 | 게시물 CRUD, 조회수 | `postCreated()`, `postViewed()`, `postDeleted()` |
| **CacheLogger** | logger_service.dart:2246 | 캐시 작업 (L1/L2/L3) | `cacheHit()`, `cacheMiss()`, `cacheSet()` |
| **VotingLogger** | logger_service.dart:1524 | 투표 제출, 투표 확장 | `voteSubmitted()`, `voteExtensionRequested()` |
| **CreationLogger** | logger_service.dart:4200 | 콘텐츠 생성 | `draftSaved()`, `postCreationStarted()` |

### Important 6 Loggers

| Logger | 사용 시기 |
|--------|----------|
| **ChatLogger** | 채팅, 메시지 |
| **MediaLogger** | 이미지/비디오 업로드, 편집 |
| **ProfileLogger** | 프로필 업데이트 |
| **NotificationsLogger** | 알림 전송, Badge 업데이트 |
| **TargetAudienceLogger** | AI 타겟 추천 |
| **ModerationLogger** | AI 검열 (Perspective, Gemini) |

### Support 3 Loggers + Additional 8

**Support**: ServicesLogger, BatchLogger, SearchLogger
**Additional**: RouterLogger, StateLogger, UtilsLogger, PermissionLogger, NetworkLogger, AnalyticsLogger, PerformanceLogger, SecurityLogger

전체 19개 Logger 상세 문서: [PRODUCTION_LOGGING_PLAN.md](PRODUCTION_LOGGING_PLAN.md)

---

## 🛠 새 Feature 통합 가이드

### Step 1: DevLogger (Domain Layer - UseCase)

```dart
// lib/features/new_feature/domain/usecases/new_action_usecase.dart
import '/services/logging/dev_logger.dart';

class NewActionUseCase {
  Future<Either<NewFailure, NewEntity>> call(String param) async {
    // 1️⃣ 입력 파라미터
    DevLogger.params({'param': param}, tag: 'NewAction');

    // 2️⃣ 유효성 검증 (필요시)
    if (param.isEmpty) {
      DevLogger.validation(field: 'param', reason: 'Param is empty', tag: 'NewAction');
      return left(NewFailure.invalidInput());
    }

    // 3️⃣ 비즈니스 로직 체크포인트 (선택)
    DevLogger.checkpoint('Calling repository.newAction', tag: 'NewAction');

    final result = await _repository.newAction(param);

    // 4️⃣ 결과 로깅
    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'NewAction'),
      (entity) => DevLogger.result(isSuccess: true, data: entity.id, tag: 'NewAction'),
    );

    return result;
  }
}
```

### Step 2: Production Logger (Data Layer - Repository)

```dart
// lib/features/new_feature/data/repositories/new_repository_impl.dart
import '/services/logging/logger_service.dart';

class NewRepositoryImpl implements INewRepository {
  @override
  Future<Either<NewFailure, NewEntity>> newAction(String param) async {
    try {
      // 1️⃣ 시작 로그 (INFO → Firebase Analytics)
      NewLogger.newActionAttempt(param: Logger.maskSensitive(param));

      final doc = await _firestore.collection('entities').doc(param).get();
      if (!doc.exists) {
        // 2️⃣ 에러 로그 (ERROR → Firebase Crashlytics)
        NewLogger.newActionError(
          param: param,
          error: NewFailure.notFound(),
        );
        return left(NewFailure.notFound());
      }

      // 3️⃣ 성공 로그 (INFO → Firebase Analytics)
      NewLogger.newActionSuccess(entityId: doc.id);
      return right(NewEntity.fromFirestore(doc));

    } on FirebaseException catch (e, stackTrace) {
      // 4️⃣ Firebase 에러 (ERROR → Firebase Crashlytics)
      NewLogger.newActionError(
        param: param,
        error: e,
      );
      return left(NewFailure.serverError(e.message));
    }
  }
}
```

### Step 3: 통합 체크리스트

```
□ Domain Layer
  □ DevLogger import 추가
  □ params() - 입력 파라미터 로깅
  □ validation() - 유효성 검증 실패 로깅 (필요시)
  □ checkpoint() - 비즈니스 로직 단계 로깅 (선택)
  □ result() - Either 패턴 결과 로깅
  □ error() - 예외 처리 로깅 (try-catch 시)

□ Data Layer
  □ Production Logger import 추가
  □ INFO - 시작/성공 로그 (Firebase Analytics)
  □ ERROR - 에러 로그 (Firebase Crashlytics)
  □ WARNING - 잠재적 문제 로그 (선택)
  □ PII 마스킹 - Logger.maskSensitive() 사용

□ 검증
  □ flutter analyze (0 errors, 0 warnings)
  □ 로그 출력 확인 (Development 환경)
  □ Firebase Console 확인 (Production 환경, 24-48시간 후)
```

---

## 🎯 의사결정 플로우차트

### 1. 어느 Layer에 로깅?

```
새 로그를 추가하려는데...
│
├─ UseCase (비즈니스 로직 추적)?
│   → DevLogger 사용 (Domain Layer)
│   • params(), checkpoint(), result(), validation(), error()
│   • kDebugMode tree-shaking (Production에서 제거)
│
└─ Repository (Firebase 호출, 에러 추적)?
    → Production Logger 사용 (Data Layer)
    • DEBUG, INFO, WARNING, ERROR
    • Firebase Analytics + Crashlytics 전송
```

### 2. DevLogger 메서드 선택

```
DevLogger에서 어떤 메서드?
│
├─ 함수 시작 (입력 파라미터)?
│   → params({'userId': userId}, tag: 'Action')
│
├─ 비즈니스 로직 단계?
│   → checkpoint('Validating input', tag: 'Action')
│
├─ Either 결과?
│   → result(isSuccess: true/false, data: ..., tag: 'Action')
│
├─ 유효성 검증 실패?
│   → validation(field: 'email', reason: 'Empty', tag: 'Action')
│
└─ 예외 발생?
    → error('Exception', error: e, stackTrace: st, tag: 'Action')
```

### 3. Production Logger 레벨 선택

```
Production Logger에서 어떤 레벨?
│
├─ 개발 중 디버깅 정보? (함수 진입/종료, 변수 값)
│   → DEBUG (Console만, Production 제거)
│
├─ 사용자 행동? 비즈니스 메트릭? (로그인, 회원가입, 게시물 생성)
│   → INFO (Firebase Analytics 100% 전송)
│
├─ 잠재적 문제? 성능 저하? (캐시 히트율 저하, 재시도)
│   → WARNING (Crashlytics 20-30% 선택적 전송)
│
└─ 에러? 실패? (API 호출 실패, Database 에러)
    → ERROR (Crashlytics 100% 전송)
```

---

## 🐛 문제 해결

### 1. DevLogger 로그가 안 보임 (Development)

**증상**: DevLogger 호출했는데 Console에 아무것도 안 나옴

**원인**: `kDebugMode == false` (Release 빌드)

**해결법**:
```bash
# Debug 모드로 실행 확인
flutter run  # 기본값은 Debug

# 또는 명시적으로
flutter run --debug

# Release 모드 확인
flutter run --release  # DevLogger 완전 제거됨 (정상)
```

---

### 2. Production Logger가 Firebase로 전송 안 됨

**증상**: Production Logger 호출했는데 Firebase Console에 안 보임

**원인**:
1. Development 환경 (`kDebugMode == true`)
2. Firebase Analytics 지연 (24-48시간)
3. Firebase 초기화 누락

**해결법**:
```dart
// 1. Production 빌드 확인
flutter build apk --release
flutter build ios --release

// 2. main.dart Firebase 초기화 확인
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Analytics 활성화 (Development 제외)
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  runApp(MyApp());
}

// 3. Firebase Console 확인 (24-48시간 후)
// https://console.firebase.google.com/u/0/project/YOUR_PROJECT/analytics
```

---

### 3. Crashlytics 에러가 중복 전송됨

**증상**: 같은 에러가 여러 번 Crashlytics로 전송됨

**해결법**: Base Logger 1시간 중복 방지 자동 적용 (Phase 1 완료)
- 같은 에러는 1시간에 1번만 Crashlytics 전송
- 중복은 Console만 출력

---

### 4. PII가 Firebase로 전송됨

**증상**: 개인정보가 마스킹 없이 Firebase Analytics/Crashlytics로 전송됨

**해결법**:
```dart
// ❌ 위험: PII 노출
AuthLogger.signInAttempt(authMethod: 'email: user@example.com');

// ✅ 안전: PII 마스킹
AuthLogger.signInAttempt(
  authMethod: 'email: ${Logger.maskSensitive('user@example.com')}',
);

// ✅ 자동 마스킹 내장 메서드 사용
AuthLogger.signInSuccess(
  userId: userId,  // 자동 마스킹됨
  email: email,    // 자동 마스킹됨
);
```

---

### 5. 어떤 Logger를 사용해야 할지 모르겠음

**해결법**: [Domain Logger 레퍼런스](#-domain-logger-레퍼런스) 테이블 참조
- 인증 → AuthLogger
- 게시물 → PostLogger
- 캐시 → CacheLogger
- 투표 → VotingLogger
- 채팅 → ChatLogger

---

## 🔗 관련 문서

- **[dev_logger.dart](dev_logger.dart)** (305줄) - DevLogger 구현
- **[logger_service.dart](logger_service.dart)** (4,295줄) - Production Logger + 19 Domain Loggers
- **[DEV_LOGGER_PLAN.md](DEV_LOGGER_PLAN.md)** (1,553줄) - DevLogger Phase 0-9 전체 계획
- **[PRODUCTION_LOGGING_PLAN.md](PRODUCTION_LOGGING_PLAN.md)** (1,064줄) - Production Logger Phase 1-4 전체 계획
- **Phase 완료 문서**: PHASE_*_COMPLETION*.md (8개 파일)

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **로깅 질문**: 이 README의 [문제 해결](#-문제-해결) 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용

---

**최종 업데이트**: 2025-11-21
**버전**: v3.0.0 (DevLogger + Production Logger 통합)
**작성자**: Claude Code (AI Assistant)
**문서 크기**: ~550줄 (기존 1,678줄 대비 67% 감소)
**완성도**:
- DevLogger: 86% (64/74 UseCases, Phase 1-8 완료)
- Production Logger: 100% (Phase 1-4 완료, 19 Domain Loggers)
