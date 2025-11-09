# Versus Space - Flutter Project (Clean Architecture v4.0)

> **최종 업데이트**: 2025-11-01 (Auto-generated with `/init`)
> **프로젝트**: versus_space - Flutter Social Voting App
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **상태 관리**: Riverpod 2.x with StreamProvider pattern
> **캐싱**: 3-Layer Caching (Memory → Hive → Firestore)

---

## 📋 목차

- [빠른 시작 (Quick Start)](#-빠른-시작-quick-start)
- [프로젝트 개요](#-프로젝트-개요)
- [아키텍처 개요](#-아키텍처-개요)
- [디렉토리 구조](#-디렉토리-구조)
- [Feature 상태](#-feature-상태)
- [빌드 및 테스트](#-빌드-및-테스트)
- [Migration History](#-migration-history)
- [주요 문서](#-주요-문서)

---

## 🚀 빠른 시작 (Quick Start)

### 개발 환경 설정

```bash
# 1. 의존성 설치
flutter pub get

# 2. Freezed/Riverpod 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 3. 앱 실행
flutter run

# 4. 테스트 실행
flutter test

# 5. 코드 분석
flutter analyze
```

### 코드 생성 (Freezed, Riverpod, JSON)

```bash
# Watch 모드로 실행 (파일 변경 시 자동 생성)
dart run build_runner watch --delete-conflicting-outputs

# 한 번만 실행
dart run build_runner build --delete-conflicting-outputs

# 생성된 파일 삭제 후 재생성
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Firebase 관련 명령어

```bash
# Firebase Emulator 시작
cd firebase
firebase emulators:start

# Cloud Functions 배포
cd firebase/functions
npm run deploy

# Firestore Rules 배포
firebase deploy --only firestore:rules

# Firebase 로그 확인
firebase functions:log
```

---

## 🎯 프로젝트 개요

**Versus Space**는 Flutter로 개발된 소셜 투표 앱입니다. 사용자가 A vs B 형식의 투표 질문을 만들고, AI 기반 타겟팅으로 적합한 사용자에게 알림을 보내며, 실시간 채팅으로 소통하는 플랫폼입니다.

### 핵심 기능

- **A vs B 투표 시스템**: 멀티미디어(이미지/비디오) 지원
- **AI 타겟팅**: Gemini AI를 활용한 스마트 사용자 매칭
- **실시간 채팅**: 1:1 채팅, AI 채팅 (flutter_chat_ui v2)
- **3-Layer 캐싱**: Memory → Hive → Firestore (응답 시간 <10ms)
- **컨텐츠 검열**: Perspective API + Gemini AI + Cloud Vision
- **멀티미디어 편집**: ProImageEditor, 비디오 트리밍
- **실시간 알림**: Firebase Functions 기반 투표 요청 알림

### 기술 스택

- **Frontend**: Flutter 3.8.0+, Dart 3.8.0
- **상태 관리**: Riverpod 2.x (StreamProvider, FutureProvider, NotifierProvider)
- **코드 생성**: Freezed 3.2.3, Riverpod Generator 3.0.0, JSON Serializable 6.11.0
- **Backend**: Firebase (Firestore, Auth, Storage, Functions, Performance)
- **AI**: Google Genkit Framework, Gemini 1.5 Pro
- **캐싱**: Hive 2.2.3 (Local DB), SimpleMemoryCache (LRU)
- **DI**: GetIt 7.6.0
- **에러 처리**: fpdart 1.1.0 (Either pattern)
- **UI 라이브러리**: flutter_chat_ui 2.9.0, flutter_chat_core 2.8.0

---

## 🏗 아키텍처 개요

### Clean Architecture v4.0 + Firebase-Centric v2.0

프로젝트는 **Clean Architecture**의 3-Layer 구조를 따르며, **Firebase-Centric v2.0** 패턴으로 마이그레이션되었습니다.

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│  • Riverpod 2.x 상태 관리                                     │
│  • StreamProvider.autoDispose.family 패턴                    │
│  • ConsumerWidget/ConsumerStatefulWidget                     │
│  • AsyncValue.when() 자동 상태 처리                          │
│  • ref.watch() / ref.listen() / ref.invalidate()            │
└──────────────────┬──────────────────────────────────────────┘
                   │ Provider 의존성 (Riverpod)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • Pure Dart (프레임워크 독립)                                 │
│  • Freezed 불변 엔티티 (UserProfile, Chat, Message, etc.)    │
│  • Either<Failure, Success> 패턴 (fpdart)                   │
│  • Repository 인터페이스 (추상화)                             │
│  • UseCase 패턴 (단일 책임 원칙)                               │
│  • Failure 클래스 (Sealed class로 에러 타입 정의)              │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository 인터페이스 의존성
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • Firebase-Centric Architecture v2.0                        │
│  • Direct Firebase SDK 사용 (Firestore, Storage, Auth)       │
│  • Extension Pattern (DTO/Mapper/DataSource 제거)           │
│  • UnifiedCacheService (3-Layer 캐싱)                        │
│    - L1 Memory: <10ms (SimpleMemoryCache, LRU 100개)        │
│    - L2 Hive: 10-30ms (영구 로컬 저장)                       │
│    - L3 Firestore: 50-500ms (오프라인 지원)                  │
│  • Repository 구현체 (직접 Firestore 쿼리)                    │
│  • Port-Adapter Pattern (IAIService → GeminiAIService)      │
└─────────────────────────────────────────────────────────────┘
```

### Firebase-Centric v2.0 핵심 변화

**Before (Legacy)**:
```
Firestore → DataSource → DTO → Mapper → Entity → UseCase → Provider
(7단계, ~1,790줄)
```

**After (v2.0)**:
```
Firestore → Extension → Entity → UseCase → Provider
(5단계, ~250줄, 85% 코드 감소)
```

**주요 제거 요소**:
- ❌ DataSource 계층 (interface + implementation)
- ❌ DTO 클래스 (Data Transfer Objects)
- ❌ Mapper 클래스 (toEntity/fromEntity)

**새로운 패턴**:
- ✅ **Extension Pattern**: `UserProfileFirestore.fromFirestore(doc)`, `toFirestore()`
- ✅ **Direct Firestore**: Repository에서 FirebaseFirestore 직접 사용
- ✅ **3-Layer Caching**: UnifiedCacheService로 통합 캐싱
- ✅ **Idempotency**: 중복 작업 방지 (UUID 기반 eventId)

---

## 📁 디렉토리 구조

### 전체 구조

```
versus-cursor/
├── lib/                              # Flutter 앱 코드
│   ├── features/                     # 🎯 Feature-First 아키텍처
│   │   ├── auth/                    # 인증 Feature (Clean v4.0 ✅)
│   │   ├── profile/                 # 프로필 Feature (Clean v4.0 ✅)
│   │   ├── chat/                    # 채팅 Feature (Clean v4.0 ✅)
│   │   ├── notifications/           # 알림 Feature (Clean v4.0 ✅)
│   │   ├── post/                    # 게시물 Feature (Clean v4.0 ✅)
│   │   ├── creation/                # 콘텐츠 생성 Feature
│   │   ├── search/                  # 검색 Feature
│   │   └── voting/                  # 투표 Feature
│   ├── core/                        # 🔧 전역 공통 요소
│   │   ├── design_system/           # 디자인 시스템
│   │   ├── theme/                   # 앱 테마
│   │   ├── localization/            # 다국어 지원
│   │   ├── utils/                   # 유틸리티
│   │   └── nav/                     # 네비게이션
│   ├── services/                    # 🛠️ 전역 서비스
│   │   ├── cache/                   # 3-Layer 캐싱
│   │   │   ├── unified_cache_service.dart
│   │   │   ├── simple_memory_cache.dart
│   │   │   └── cache_statistics.dart
│   │   ├── vote_timer_service.dart
│   │   ├── vote_status_service.dart
│   │   └── vote_state_coordinator.dart
│   ├── app/                         # 🚀 앱 진입점
│   │   ├── router/                  # GoRouter 설정
│   │   ├── state/                   # 전역 AppState
│   │   ├── di/                      # GetIt DI 설정
│   │   └── app.dart
│   └── main.dart                    # 엔트리 포인트
├── firebase/                        # Firebase 백엔드
│   ├── functions/                   # Cloud Functions (Node.js)
│   │   ├── ai/                      # Genkit AI 시스템
│   │   ├── notifications/           # 알림 시스템
│   │   └── index.js
│   ├── firestore.rules             # Firestore 보안 규칙
│   └── firebase.json
├── test/                            # 테스트 파일
└── pubspec.yaml                     # Flutter 의존성
```

### Feature 내부 구조 (Clean Architecture)

각 Feature는 3-Layer Clean Architecture를 따릅니다:

```
features/[feature_name]/
├── data/                          # Data Layer
│   ├── repositories/              # Repository 구현체 (*_impl.dart)
│   ├── extensions/                # Firestore Extension (fromFirestore, toFirestore)
│   └── README.md
│
├── domain/                        # Domain Layer
│   ├── entities/                  # Freezed 불변 엔티티 (*.freezed.dart, *.g.dart)
│   ├── repositories/              # Repository 인터페이스 (i_*.dart)
│   ├── usecases/                  # UseCase 비즈니스 로직
│   ├── failures/                  # Failure 정의 (Sealed class)
│   └── README.md
│
├── presentation/                  # Presentation Layer
│   ├── providers/                 # Riverpod 상태 관리
│   │   ├── *_providers.dart       # Provider 정의
│   │   └── *_providers.g.dart     # Riverpod Generator
│   ├── screens/                   # 화면 위젯
│   ├── widgets/                   # 재사용 위젯
│   └── README.md
│
├── di/                            # Dependency Injection
│   └── *_di_module.dart
│
└── README.md                      # Feature 통합 문서
```

---

## ✅ Feature 상태

### Clean Architecture v4.0 Migration Status

| Feature | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Status |
|---------|---------|---------|---------|---------|---------|--------|
| **Auth** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Extension | - | 🟢 100% |
| **Profile** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Extension | - | 🟢 100% |
| **Chat** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| **Notifications** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| **Post** | ✅ Either | ✅ Riverpod | ✅ Cache | ✅ Idempotency | ✅ Extension | 🟢 100% |
| Creation | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |
| Search | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |
| Voting | 🔄 | 🔄 | 🔄 | 🔄 | 🔄 | 🟡 In Progress |

### Phase 문서 위치

각 Feature의 Phase 문서는 해당 Feature 디렉토리에 있습니다:

**Auth Feature** (4개 Phase):
- `lib/features/auth/PHASE_1_FREEZED_FAILURE.md`
- `lib/features/auth/PHASE_2_EITHER_PATTERN.md`
- `lib/features/auth/PHASE_3_RIVERPOD.md`
- `lib/features/auth/PHASE_4_EXTENSION_PATTERN.md`

**Profile Feature** (4개 Phase):
- `lib/features/profile/PHASE_1_FREEZED_FAILURE.md`
- `lib/features/profile/PHASE_2_EITHER_PATTERN.md`
- `lib/features/profile/PHASE_3_RIVERPOD.md`
- `lib/features/profile/PHASE_4_EXTENSION_PATTERN.md`

**Chat Feature** (5개 Phase):
- `lib/features/chat/PHASE_1_FREEZED_FAILURE.md`
- `lib/features/chat/PHASE_2_EITHER_PATTERN.md`
- `lib/features/chat/PHASE_3_RIVERPOD.md`
- `lib/features/chat/PHASE_4_IDEMPOTENCY.md`
- `lib/features/chat/PHASE_5_EXTENSION_PATTERN.md`
- `lib/features/chat/PHASE_1_COMPLETION_PLAN.md` (추가)

**Notifications Feature** (5개 Phase):
- `lib/features/notifications/PHASE_1_FREEZED_FAILURE.md`
- `lib/features/notifications/PHASE_2_EITHER_PATTERN.md`
- `lib/features/notifications/PHASE_3_RIVERPOD.md`
- `lib/features/notifications/PHASE_4_IDEMPOTENCY.md`
- `lib/features/notifications/PHASE_5_EXTENSION_PATTERN.md`

**Post Feature** (5개 Phase):
- `lib/features/post/PHASE_1_FREEZED_FAILURE.md`
- `lib/features/post/PHASE_2_RIVERPOD.md`
- `lib/features/post/PHASE_3_CACHE_INTEGRATION.md`
- `lib/features/post/PHASE_4_IDEMPOTENCY.md`
- `lib/features/post/PHASE_5_EXTENSION_PATTERN.md`

**총 Phase 문서**: 24개

---

## 🔧 빌드 및 테스트

### 빌드 명령어

```bash
# Development 빌드
flutter run

# Release 빌드 (플랫폼별)
flutter build apk          # Android
flutter build ios          # iOS (macOS에서만)
flutter build web          # Web
flutter build macos        # macOS

# 특정 타겟 지정
flutter build apk --release --target-platform android-arm64
```

### 테스트 명령어

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/features/auth/domain/usecases/sign_in_with_email_test.dart

# 커버리지 포함 테스트
flutter test --coverage

# HTML 커버리지 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 단위 테스트만 실행
flutter test lib/features/auth/test/unit

# 통합 테스트 실행
flutter test integration_test/
```

### 코드 분석 및 Lint

```bash
# 코드 분석
flutter analyze

# 특정 디렉토리만 분석
flutter analyze lib/features/auth

# 자동 포맷팅
dart format lib/

# 특정 파일 포맷팅
dart format lib/features/auth/domain/entities/user_profile.dart
```

### 의존성 관리

```bash
# 의존성 업데이트
flutter pub get
flutter pub upgrade

# 특정 패키지 추가
flutter pub add riverpod
flutter pub add --dev freezed

# 의존성 확인
flutter pub deps
flutter pub outdated
```

---

## 📚 Migration History

### 최근 마이그레이션 (2025-10-28 ~ 2025-11-01)

**Firebase-Centric v2.0 마이그레이션 완료**:

1. **2025-10-31** (`76324fa0`):
   - Posts Feature Phase 5 (Extension Pattern) 완성
   - Phase 문서 작성 완료 (PHASE_1 to PHASE_5)

2. **2025-10-31** (`b0e8899f`):
   - Firebase-Centric v2.0 with UnifiedCache
   - 3-Layer 캐싱 시스템 통합

3. **2025-10-29** (`424588e1`):
   - 대규모 문서 정리
   - Profile Feature Phase 문서 완성

4. **2025-10-28** (`5a59c254`):
   - Auth Feature: @JsonKey → @JsonConverter 마이그레이션
   - UserRole enum 직렬화 수정

### 주요 변경 사항

**Phase 1-5 완료**:
- ✅ Auth, Profile, Chat, Notifications, Post Feature 모두 Clean Architecture v4.0 완성
- ✅ Extension Pattern으로 DTO/Mapper 제거 (평균 85% 코드 감소)
- ✅ 3-Layer 캐싱 시스템 통합 (응답 시간 <10ms)
- ✅ Either Pattern 전환 (Result<T> 제거)
- ✅ Riverpod 2.x 마이그레이션 (StreamProvider, FutureProvider)

**Architecture Changes**:
- DataSource/DTO/Mapper → Extension Pattern
- Result<T> → Either<Failure, T>
- Provider 0.x → Riverpod 2.x
- Manual cache → UnifiedCacheService

**Performance Improvements**:
- 캐시 히트율: 60%+ (L1: 30%, L2: 20%, L3: 10%)
- 응답 시간: 캐시 히트 <10ms vs 네트워크 300-500ms
- Firestore 읽기 비용: 40-60% 절감

---

## 📖 주요 문서

### Feature 문서

각 Feature의 최신 상태와 사용법은 해당 README.md를 참조하세요:

- [Auth Feature README](/lib/features/auth/README.md) - 인증 시스템
- [Profile Feature README](/lib/features/profile/README.md) - 프로필 관리
- [Chat Feature README](/lib/features/chat/README.md) - 채팅 시스템
- [Notifications Feature README](/lib/features/notifications/README.md) - 알림 시스템
- [Post Feature README](/lib/features/post/README.md) - 게시물 관리

### Backend 문서

- [Firebase Functions README](/firebase/functions/README.md) - Cloud Functions 및 AI 시스템
- [Firestore Security Rules](/firebase/firestore.rules) - 보안 규칙

### 레이어별 README

각 Feature는 레이어별로 상세 README를 제공합니다:

**Data Layer**:
- `lib/features/*/data/README.md` - Repository 구현, Extension 패턴

**Domain Layer**:
- `lib/features/*/domain/README.md` - UseCase, Entity, Failure 정의

**Presentation Layer**:
- `lib/features/*/presentation/README.md` - Provider, Widget, Screen

---

## 🔑 핵심 개념

### Either Pattern (fpdart)

```dart
// 에러 처리 예시
Future<Either<AuthFailure, UserProfile>> signIn(
  String email,
  String password,
) async {
  try {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return right(UserProfile.fromFirestore(userCredential));
  } on FirebaseAuthException catch (e) {
    return left(AuthFailure.invalidCredentials(e.message));
  } catch (e) {
    return left(AuthFailure.serverError(e.toString()));
  }
}

// 사용 예시 (Provider에서)
final result = await ref.read(signInUseCaseProvider)(email, password);
result.fold(
  (failure) => // 에러 처리
  (user) => // 성공 처리
);
```

### Riverpod 2.x StreamProvider

```dart
// Provider 정의
@riverpod
Stream<List<Chat>> chatList(ChatListRef ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  return repository.watchChatList(userId).map(
    (either) => either.getOrElse((l) => []),
  );
}

// Widget에서 사용
class ChatListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);

    return chatListAsync.when(
      data: (chats) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Extension Pattern (Firestore 변환)

```dart
extension UserProfileFirestore on UserProfile {
  // Firestore → Entity
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // ... other fields
    );
  }

  // Entity → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      // ... other fields
    };
  }
}
```

### 3-Layer Caching

```dart
// UnifiedCacheService 사용 예시
final cacheService = UnifiedCacheService.instance;

// 캐시에서 읽기 (L1 → L2 → L3 순서)
final messages = await cacheService.getMessages(chatId);

// 캐시에 저장 (L1, L2, L3 모두 저장)
await cacheService.putMessages(chatId, messages);

// 캐시 무효화
await cacheService.invalidate('chat_messages_$chatId');

// 통계 확인
final stats = cacheService.getStatistics();
print('L1 Hit Rate: ${stats.l1HitRate}%');
print('Total Firestore Reads Saved: ${stats.firestoreReadsSaved}');
```

---

## 🎓 학습 리소스

### 시작하기 좋은 Feature

초보자가 코드를 이해하기 좋은 순서:

1. **Auth Feature** - 가장 기본적인 CRUD 및 인증 플로우
2. **Profile Feature** - 복잡한 데이터 모델 및 캐싱
3. **Chat Feature** - 실시간 스트림 및 복잡한 상태 관리
4. **Notifications Feature** - AI 통합 및 백엔드 연동
5. **Post Feature** - 전체 시스템 통합

### 추천 읽기 순서

1. `lib/features/auth/README.md` - Clean Architecture v4.0 개요
2. `lib/features/auth/PHASE_2_EITHER_PATTERN.md` - Either 패턴 이해
3. `lib/features/auth/PHASE_3_RIVERPOD.md` - Riverpod 2.x 패턴
4. `lib/features/profile/PHASE_4_EXTENSION_PATTERN.md` - Extension 패턴
5. `lib/features/chat/PHASE_5_EXTENSION_PATTERN.md` - 전체 마이그레이션 가이드

---

## 🆘 문제 해결

### 일반적인 이슈

**1. 빌드 에러: "Missing generated files"**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**2. Firebase 연결 에러**

```bash
# Firebase 설정 파일 확인
ls -la lib/firebase_options.dart

# Firebase CLI 재로그인
firebase login
```

**3. 캐시 관련 문제**

```bash
# Flutter 캐시 정리
flutter clean
flutter pub get

# Hive 박스 삭제 (앱 데이터 삭제)
# iOS: 설정 → Versus Space → 데이터 지우기
# Android: 설정 → 앱 → Versus Space → 저장공간 → 데이터 삭제
```

**4. Riverpod 상태 동기화 문제**

```dart
// Provider 강제 새로고침
ref.invalidate(chatListProvider);

// 모든 Provider 재시작
ref.refresh(chatListProvider);
```

---

## 📝 기여 가이드

### 코드 스타일

- Dart 공식 스타일 가이드 준수 (`dart format`)
- Clean Architecture 레이어 분리 유지
- Freezed로 불변 클래스 생성
- Either 패턴으로 에러 처리
- Riverpod Provider로 상태 관리

### Commit 메시지 규칙

```
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 업데이트
test: 테스트 추가/수정
chore: 빌드/설정 변경
```

### Feature 추가 순서

1. Domain Layer 먼저 작성 (Entity, UseCase, Repository Interface)
2. Data Layer 구현 (Repository Implementation, Extension)
3. Presentation Layer 마지막 (Provider, Widget)
4. README.md 작성
5. Phase 문서 작성 (필요시)

---

**생성 일시**: 2025-11-01 (Auto-generated)
**명령어**: `/init`
**업데이트**: 이 문서는 주기적으로 `/init` 명령으로 재생성됩니다.
