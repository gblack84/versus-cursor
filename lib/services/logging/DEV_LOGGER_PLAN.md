# DevLogger 통합 구현 계획

> **목적**: 개발 디버깅용 DevLogger 도입 (운영 Logger와 병행)
> **전략**: 98.7% 패턴 통일성 활용한 단일 템플릿 접근
> **범위**: 8개 Feature, 75개 UseCase 파일
> **예상 소요**: 17-18시간 (Phase별 순차 실행, Phase 6 리팩토링 포함)

---

## 📋 목차

1. [배경 및 목표](#배경-및-목표)
2. [현재 상태 분석](#현재-상태-분석)
3. [DevLogger 설계](#devlogger-설계)
4. [구현 계획](#구현-계획)
5. [패턴별 템플릿](#패턴별-템플릿)
6. [Feature별 적용 가이드](#feature별-적용-가이드)
7. [검증 및 테스트](#검증-및-테스트)
8. [FAQ](#faq)

---

## 배경 및 목표

### 배경

현재 프로젝트는 **운영 로깅**(`Logger.info/error`)과 **개발 디버깅**(`debugPrint/kDebugMode`)이 혼재되어 있습니다:

- **운영 Logger**: Firebase Crashlytics 연동, 프로덕션 모니터링
- **개발 디버깅**: 산발적인 `debugPrint`, 일관성 부족

### 목표

1. **개발 디버깅 표준화**: `DevLogger` 단일 인터페이스로 통일
2. **운영 로깅 유지**: 기존 `Logger` 시스템과 병행 운영
3. **패턴 활용**: 98.7% UseCase 패턴 통일성을 활용한 효율적 적용
4. **빌드 최적화**: `kDebugMode` + tree-shaking으로 프로덕션 제외

---

## 현재 상태 분석

### UseCase 패턴 분석 결과

**총 75개 UseCase 파일** (8개 Feature):

```
✅ 74개 (98.7%) - 표준 패턴 준수
   ├─ Type A (Simple CRUD): 62개
   ├─ Type B (Idempotent): 5개
   ├─ Type C (Stream): 6개
   └─ Type D (Complex Multi-step): 1개

⚠️ 1개 (1.3%) - 안티패턴
   └─ AccountManagementUseCase (12 메서드 in 1 파일 - SRP 위반)

📝 1개 (stub) - 구현 필요
   └─ SearchPostsUseCase (TODO only)
```

### Feature별 파일 수

| Feature | 파일 수 | 주요 패턴 | 예상 시간 |
|---------|---------|-----------|----------|
| Auth | 10 | Type A (100%) | 2시간 |
| Profile | 16 | Type A (94%), Type C (6%) | 3시간 |
| Chat | 10 | Type A (50%), Type B (30%), Type C (20%) | 2시간 |
| Notifications | 5 | Type A (80%), Type C (20%) | 1시간 |
| Post | 9 | Type A (100%) | 2시간 |
| Creation | 5 | Type A (80%), Type D (20%) | **4-5시간** (리팩토링 포함) |
| Voting | 2 | Type B (50%), Type C (50%) | 30분 |
| Search | 4 | Type A (75%), stub (25%) | 1시간 |

### Clean Architecture 구조 활용

**모든 UseCase가 동일한 구조**를 따르기 때문에 DevLogger 적용이 용이합니다:

```dart
// 공통 구조 (Domain Layer - Pure Dart)
class XxxUseCase {
  final IXxxRepository _repository;

  Future<Either<XxxFailure, XxxEntity>> call(params) async {
    // 1. 입력 검증
    // 2. 비즈니스 로직
    // 3. Repository 호출
    // 4. Either 패턴 처리
  }
}
```

---

## DevLogger 설계

### 파일 위치

```
lib/services/logging/dev_logger.dart
```

### 핵심 설계 원칙

1. **개발 전용**: `kDebugMode`로 프로덕션 빌드에서 자동 제거
2. **간결한 API**: 5개 메서드로 모든 상황 커버
3. **태그 시스템**: UseCase별 로그 필터링 가능
4. **성능**: `debugPrint` 사용으로 오버헤드 최소화

### API 설계

```dart
import 'package:flutter/foundation.dart';

class DevLogger {
  /// 파라미터 로깅
  static void params(Map<String, dynamic> parameters, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 📋 PARAMS: $parameters');
    }
  }

  /// 체크포인트 로깅 (실행 흐름 추적)
  static void checkpoint(String checkpoint, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🎯 CHECKPOINT: $checkpoint');
    }
  }

  /// 결과 로깅 (성공/실패)
  static void result({required bool isSuccess, dynamic data, String? tag}) {
    if (kDebugMode) {
      final status = isSuccess ? '✅ SUCCESS' : '❌ FAILURE';
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} $status${data != null ? ' - $data' : ''}');
    }
  }

  /// 검증 실패 로깅
  static void validation({required String field, required String reason, String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} ⚠️ VALIDATION: field=$field, reason=$reason');
    }
  }

  /// 에러 로깅 (try-catch)
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 ERROR: $message');
      if (error != null) debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 Error: $error');
      if (stackTrace != null) debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 Stack: $stackTrace');
    }
  }
}
```

### 운영 Logger와의 관계

```
┌─────────────────────────────────────────────────────────┐
│                     UseCase Layer                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  DevLogger.params(...)      ← 개발 디버깅 (kDebugMode)   │
│  DevLogger.checkpoint(...)                               │
│  DevLogger.result(...)                                   │
│                                                          │
│  Logger.error(...)          ← 운영 모니터링 (항상 동작)   │
│  (Firebase Crashlytics)                                  │
│                                                          │
└─────────────────────────────────────────────────────────┘

병행 운영:
- DevLogger: 개발 중 디버깅 (debugPrint → Console)
- Logger: 프로덕션 모니터링 (Firebase → Crashlytics)
- 충돌 없음: 각자 다른 목적, 다른 출력
```

---

## 구현 계획

### Phase 0: 사전 준비 (30분)

#### 0.1 DevLogger 파일 생성

**파일**: `lib/services/logging/dev_logger.dart`

```dart
import 'package:flutter/foundation.dart';

/// Development-only logger for debugging UseCases
///
/// **Usage**:
/// ```dart
/// DevLogger.params({'userId': userId}, tag: 'SignIn');
/// DevLogger.checkpoint('Repository call started');
/// DevLogger.result(isSuccess: true, data: user.uid);
/// ```
///
/// **Features**:
/// - kDebugMode: Automatically removed in production builds
/// - Tag system: Filter logs by UseCase name
/// - debugPrint: Flutter-optimized console output
class DevLogger {
  static void params(Map<String, dynamic> parameters, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 📋 PARAMS: $parameters');
    }
  }

  static void checkpoint(String checkpoint, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🎯 CHECKPOINT: $checkpoint');
    }
  }

  static void result({required bool isSuccess, dynamic data, String? tag}) {
    if (kDebugMode) {
      final status = isSuccess ? '✅ SUCCESS' : '❌ FAILURE';
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} $status${data != null ? ' - $data' : ''}');
    }
  }

  static void validation({required String field, required String reason, String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} ⚠️ VALIDATION: field=$field, reason=$reason');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 ERROR: $message');
      if (error != null) debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 Error: $error');
      if (stackTrace != null) debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🔴 Stack: $stackTrace');
    }
  }
}
```

#### 0.2 패턴별 템플릿 문서 작성

다음 섹션 참조 → [패턴별 템플릿](#패턴별-템플릿)

---

### Phase 1: Auth Feature (10 files, 2시간)

**우선순위**: ⭐⭐⭐ (가장 먼저 적용 - 템플릿 검증용)

**파일 목록**:
1. `sign_in/sign_in_with_email_usecase.dart` (Type A)
2. `sign_in/sign_in_with_phone_usecase.dart` (Type A)
3. `sign_up/sign_up_with_email_usecase.dart` (Type A)
4. `social/sign_in_with_apple_usecase.dart` (Type A)
5. `social/sign_in_with_google_usecase.dart` (Type A)
6. `account/sign_out_usecase.dart` (Type A)
7. `account/delete_account_usecase.dart` (Type A)
8. `password/send_password_reset_email_usecase.dart` (Type A)
9. `phone/verify_phone_number_usecase.dart` (Type A)
10. `account/get_current_user_usecase.dart` (Type A)

**작업 체크리스트**:
- [ ] DevLogger import 추가
- [ ] params 로깅 추가 (메서드 시작)
- [ ] checkpoint 로깅 추가 (주요 단계)
- [ ] result 로깅 추가 (성공/실패)
- [ ] validation 로깅 추가 (입력 검증 실패 시)
- [ ] error 로깅 추가 (try-catch)
- [ ] `flutter test test/features/auth/` 실행
- [ ] 디버그 로그 출력 확인

**검증**:
```bash
flutter test test/features/auth/domain/usecases/
# 모든 테스트 통과 확인

flutter run
# 로그인 시도 → Console에서 DevLogger 출력 확인
```

---

### Phase 2: Profile Feature (16 files, 3시간)

**우선순위**: ⭐⭐ (Auth 검증 후 진행)

**파일 목록**:
1. `profile/get_user_profile_usecase.dart` (Type A)
2. `profile/update_user_profile_usecase.dart` (Type A)
3. `profile/watch_user_profile_usecase.dart` (Type C) ⚠️ Stream 패턴
4. `settings/get_user_settings_usecase.dart` (Type A)
5. `settings/update_user_settings_usecase.dart` (Type A)
6. `activity/update_last_active_usecase.dart` (Type A)
7. `storage/select_media_usecase.dart` (Type A)
8. `storage/validate_media_usecase.dart` (Type A)
9. `storage/upload_profile_image_usecase.dart` (Type A)
10. `storage/delete_profile_image_usecase.dart` (Type A)
11. `bio/update_bio_usecase.dart` (Type A)
12. `display_name/update_display_name_usecase.dart` (Type A)
13. `privacy/update_privacy_settings_usecase.dart` (Type A)
14. `blocked_users/block_user_usecase.dart` (Type A)
15. `blocked_users/unblock_user_usecase.dart` (Type A)
16. `blocked_users/get_blocked_users_usecase.dart` (Type A)

**작업 체크리스트**:
- [ ] Type A 템플릿 적용 (15개 파일)
- [ ] Type C 템플릿 적용 (1개: watch_user_profile)
- [ ] `flutter test test/features/profile/` 실행
- [ ] 프로필 수정 시 DevLogger 출력 확인

**특이사항**:
- `watch_user_profile_usecase.dart`는 Stream 패턴 → Type C 템플릿 사용

---

### Phase 3: Chat Feature (10 files, 2시간)

**우선순위**: ⭐⭐ (Type B/C 패턴 혼합 - 중간 난이도)

**파일 목록**:
1. `get_chat_list_usecase.dart` (Type C) ⚠️ Stream
2. `get_chat_messages_usecase.dart` (Type C) ⚠️ Stream
3. `send_message_usecase.dart` (Type B) ⚠️ Idempotent (UUID)
4. `send_ai_query_usecase.dart` (Type B) ⚠️ Idempotent (UUID)
5. `load_more_messages_usecase.dart` (Type A)
6. `search_messages_usecase.dart` (Type A)
7. `create_chat_usecase.dart` (Type B) ⚠️ Idempotent (UUID)
8. `delete_chat_usecase.dart` (Type A)
9. `mark_as_read_usecase.dart` (Type A)
10. `get_unread_count_usecase.dart` (Type A)

**작업 체크리스트**:
- [ ] Type A 템플릿 적용 (5개)
- [ ] Type B 템플릿 적용 (3개: UUID 생성 로깅)
- [ ] Type C 템플릿 적용 (2개: Stream)
- [ ] `flutter test test/features/chat/` 실행
- [ ] 채팅 메시지 전송 시 eventId 로깅 확인

---

### Phase 4: Notifications Feature (5 files, 1시간)

**우선순위**: ⭐ (간단함 - 빠른 적용 가능)

**파일 목록**:
1. `watch_user_notifications_usecase.dart` (Type C) ⚠️ Stream
2. `mark_notification_as_read_usecase.dart` (Type A)
3. `delete_notification_usecase.dart` (Type A)
4. `get_unread_count_usecase.dart` (Type A)
5. `clear_all_notifications_usecase.dart` (Type A)

**작업 체크리스트**:
- [ ] Type C 템플릿 적용 (1개)
- [ ] Type A 템플릿 적용 (4개)
- [ ] `flutter test test/features/notifications/` 실행

---

### Phase 5: Post Feature (9 files, 2시간)

**우선순위**: ⭐ (모두 Type A - 단순 적용)

**파일 목록**:
1. `get_post_detail_usecase.dart` (Type A)
2. `get_user_posts_usecase.dart` (Type A)
3. `get_trending_posts_usecase.dart` (Type A)
4. `delete_post_usecase.dart` (Type A)
5. `report_post_usecase.dart` (Type A)
6. `increment_view_count_usecase.dart` (Type A)
7. `share_post_usecase.dart` (Type A)
8. `bookmark_post_usecase.dart` (Type A)
9. `get_bookmarked_posts_usecase.dart` (Type A)

**작업 체크리스트**:
- [ ] Type A 템플릿 적용 (9개 모두)
- [ ] `flutter test test/features/post/` 실행

---

### Phase 6: Creation Feature (5 files, 4-5시간)

**우선순위**: ⭐⭐⭐ (Type D 포함 - 복잡도 높음 + 리팩토링 포함)

**파일 목록**:
1. `create_post_usecase.dart` (Type D) ⚠️ 복잡한 다단계 로직 (289줄) + 리팩토링 필요
2. `moderate_content_usecase.dart` (Type A)
3. `upload_images_usecase.dart` (Type A)
4. `manage_target_audience_usecase.dart` (Type A)
5. `validate_post_data_usecase.dart` (Type A)

**작업 순서** (2단계):

#### 6.1 DevLogger 통합 (2시간)

**작업 체크리스트**:
- [ ] Type A 템플릿 적용 (4개: moderate_content, upload_images, manage_target_audience, validate_post_data)
- [ ] `flutter test test/features/creation/` 실행

#### 6.2 CreatePostUseCase 리팩토링 + DevLogger (2-3시간)

**📖 리팩토링 가이드**: `CREATE_POST_REFACTORING_GUIDE.md` 참조

**리팩토링 목표**:
- 4단계 Nested Fold → Early Return Pattern 변환
- 최대 들여쓰기: 14칸 (7-level) → 6칸 (3-level) (57% 감소)
- 가독성, 유지보수성, 테스트 용이성 개선

**작업 체크리스트**:
- [ ] **Step 1-7**: 리팩토링 가이드 Step-by-Step 변환 수행
  - [ ] resultA.fold() → Early Return
  - [ ] resultB.fold() → Early Return
  - [ ] uploadResultA.fold() → Early Return
  - [ ] uploadResultB.fold() → Early Return
  - [ ] createResult.map() → Early Return
  - [ ] 닫기 괄호 제거 (4개)
  - [ ] 들여쓰기 정리
- [ ] **테스트 검증**:
  - [ ] `flutter test test/features/creation/domain/usecases/create_post_usecase_test.dart` 실행
  - [ ] 모든 테스트 통과 확인 (100%)
  - [ ] 실행 순서 보존 확인 (시나리오 1-4)
- [ ] **DevLogger 통합** (Type D 템플릿):
  - [ ] logStart() 추가 (execute 시작)
  - [ ] 8개 checkpoint 로깅 (각 단계별)
  - [ ] 6개 Progress 로깅 (0.1, 0.4, 0.7, 0.8, 0.9, 1.0)
  - [ ] logError() 추가 (각 Early Return)
  - [ ] logSuccess() 추가 (최종 저장 성공)
- [ ] **최종 검증**:
  - [ ] UI에서 게시물 생성 테스트
  - [ ] onProgress UI 정상 표시 확인
  - [ ] DevLogger 콘솔 출력 확인

**특이사항**:
- `create_post_usecase.dart`는 289줄의 복잡한 로직 (4단계 Nested Fold)
- 8단계 프로세스 각각에 checkpoint 필요
- **필수**: Early Return 패턴으로 리팩토링 후 DevLogger 통합 (CREATE_POST_REFACTORING_GUIDE.md 참조)
- 리팩토링 실패 시 롤백 계획 준비 (가이드 Section 9 참조)

---

### Phase 7: Voting Feature (2 files, 30분)

**우선순위**: ⭐ (파일 적음 - 빠른 적용)

**파일 목록**:
1. `chat/submit_vote_use_case.dart` (Type B) ⚠️ Idempotent
2. `chat/watch_vote_state_use_case.dart` (Type C) ⚠️ Stream

**작업 체크리스트**:
- [ ] Type B 템플릿 적용 (1개)
- [ ] Type C 템플릿 적용 (1개)
- [ ] `flutter test test/features/voting/` 실행

---

### Phase 8: Search Feature (4 files, 1시간)

**우선순위**: ⭐ (stub 파일 1개 제외)

**파일 목록**:
1. `search_users_usecase.dart` (Type A)
2. `search_hashtags_usecase.dart` (Type A)
3. `get_trending_searches_usecase.dart` (Type A)
4. `search_posts_usecase.dart` (stub) ⚠️ TODO only

**작업 체크리스트**:
- [ ] Type A 템플릿 적용 (3개)
- [ ] SearchPostsUseCase 구현 후 DevLogger 적용 (또는 skip)
- [ ] `flutter test test/features/search/` 실행

**특이사항**:
- `search_posts_usecase.dart`는 현재 stub (TODO만 존재)
- 구현 전까지는 skip 가능

---

### Phase 9: 최종 검증 및 문서화 (1시간)

#### 9.1 전체 테스트

```bash
# 모든 테스트 실행
flutter test

# 정적 분석
flutter analyze

# 기대 결과: 0 errors, 0 warnings
```

#### 9.2 로그 출력 검증

**각 Feature별로 확인**:
1. Auth: 로그인 시도
2. Profile: 프로필 수정
3. Chat: 메시지 전송
4. Notifications: 알림 읽음 처리
5. Post: 게시물 조회
6. Creation: 게시물 생성
7. Voting: 투표 제출
8. Search: 검색 실행

**Console 출력 예시**:
```
[DEV][SignInWithEmail] 📋 PARAMS: {email: test@example.com}
[DEV][SignInWithEmail] 🎯 CHECKPOINT: Calling repository.signIn
[DEV][SignInWithEmail] ✅ SUCCESS - userId: abc123
```

#### 9.3 kDebugMode 동작 확인

```bash
# Debug 빌드 (DevLogger 활성화)
flutter run

# Release 빌드 (DevLogger 제거 - tree-shaking)
flutter build apk --release
flutter build ios --release

# APK 크기 확인 (DevLogger 코드 포함 안 됨)
```

#### 9.4 문서 업데이트

- [ ] `lib/services/logging/README.md`
  - DevLogger 섹션 추가
  - 사용 예제 추가
  - Logger vs DevLogger 비교표

- [ ] `CLAUDE.md`
  - DevLogger 통합 완료 상태 업데이트
  - 로깅 시스템 섹션 개선

---

## 패턴별 템플릿

### Type A: Simple CRUD (62개 파일)

**특징**: 단순한 Repository 호출 → Either 반환

**Before**:
```dart
class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<ProfileFailure, UserProfile>> call({
    required String userId,
  }) {
    return _repository.getUserProfile(userId);
  }
}
```

**After (DevLogger 적용)**:
```dart
import '/services/logging/dev_logger.dart';

class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Either<ProfileFailure, UserProfile>> call({
    required String userId,
  }) async {
    DevLogger.params({'userId': userId}, tag: 'GetUserProfile');

    DevLogger.checkpoint('Calling repository.getUserProfile', tag: 'GetUserProfile');
    final result = await _repository.getUserProfile(userId);

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'GetUserProfile'),
      (profile) => DevLogger.result(isSuccess: true, data: profile.uid, tag: 'GetUserProfile'),
    );

    return result;
  }
}
```

**로그 출력 예시**:
```
[DEV][GetUserProfile] 📋 PARAMS: {userId: user123}
[DEV][GetUserProfile] 🎯 CHECKPOINT: Calling repository.getUserProfile
[DEV][GetUserProfile] ✅ SUCCESS - user123
```

---

### Type B: Idempotent (5개 파일)

**특징**: UUID 생성 → Repository 호출 (중복 방지)

**Before**:
```dart
class SendMessageUseCase {
  final IChatRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<Either<ChatFailure, Message>> call({
    required String chatId,
    required String content,
  }) async {
    final eventId = _uuid.v4();

    return _repository.sendMessage(
      chatId: chatId,
      content: content,
      eventId: eventId,
    );
  }
}
```

**After (DevLogger 적용)**:
```dart
import '/services/logging/dev_logger.dart';

class SendMessageUseCase {
  final IChatRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<Either<ChatFailure, Message>> call({
    required String chatId,
    required String content,
  }) async {
    DevLogger.params({'chatId': chatId, 'content': content}, tag: 'SendMessage');

    final eventId = _uuid.v4();
    DevLogger.checkpoint('Generated eventId: $eventId', tag: 'SendMessage');

    DevLogger.checkpoint('Calling repository.sendMessage', tag: 'SendMessage');
    final result = await _repository.sendMessage(
      chatId: chatId,
      content: content,
      eventId: eventId,
    );

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SendMessage'),
      (message) => DevLogger.result(isSuccess: true, data: message.id, tag: 'SendMessage'),
    );

    return result;
  }
}
```

**로그 출력 예시**:
```
[DEV][SendMessage] 📋 PARAMS: {chatId: chat123, content: Hello}
[DEV][SendMessage] 🎯 CHECKPOINT: Generated eventId: 550e8400-e29b-41d4-a716-446655440000
[DEV][SendMessage] 🎯 CHECKPOINT: Calling repository.sendMessage
[DEV][SendMessage] ✅ SUCCESS - msg456
```

---

### Type C: Stream (6개 파일)

**특징**: Stream 반환 → fold는 map 내부에서

**Before**:
```dart
class WatchUserProfileUseCase {
  final IProfileRepository _repository;

  Stream<UserProfile?> call({required String userId}) {
    return _repository.watchUserProfile(userId).map(
      (either) => either.fold(
        (failure) => null,
        (profile) => profile,
      ),
    );
  }
}
```

**After (DevLogger 적용)**:
```dart
import '/services/logging/dev_logger.dart';

class WatchUserProfileUseCase {
  final IProfileRepository _repository;

  Stream<UserProfile?> call({required String userId}) {
    DevLogger.params({'userId': userId}, tag: 'WatchUserProfile');
    DevLogger.checkpoint('Starting stream watch', tag: 'WatchUserProfile');

    return _repository.watchUserProfile(userId).map(
      (either) {
        return either.fold(
          (failure) {
            DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'WatchUserProfile');
            return null;
          },
          (profile) {
            DevLogger.result(isSuccess: true, data: profile.uid, tag: 'WatchUserProfile');
            return profile;
          },
        );
      },
    );
  }
}
```

**로그 출력 예시**:
```
[DEV][WatchUserProfile] 📋 PARAMS: {userId: user123}
[DEV][WatchUserProfile] 🎯 CHECKPOINT: Starting stream watch
[DEV][WatchUserProfile] ✅ SUCCESS - user123
[DEV][WatchUserProfile] ✅ SUCCESS - user123  ← Stream 업데이트마다 출력
```

---

### Type D: Complex Multi-step (1개 파일)

**특징**: 여러 단계의 복잡한 로직 → 각 단계별 checkpoint

**Before** (create_post_usecase.dart, 195줄):
```dart
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> execute({...}) async {
    try {
      // 1. Validate inputs
      final validationResult = _validateInputs(...);
      if (validationResult != null) return left(...);

      onProgress?.call(0.1);

      // 2. Process images for option A
      final resultA = await _processImages(...);

      return resultA.fold((failure) => left(failure), (processedA) async {
        onProgress?.call(0.4);

        // 3. Process images for option B
        final resultB = await _processImages(...);
        // ... 4-8단계 nested fold
      });
    } catch (error, stackTrace) {
      Logger.error('CreatePostUseCase: Post creation failed', ...);
      return left(...);
    }
  }
}
```

**After (DevLogger 적용)**:
```dart
import '/services/logging/dev_logger.dart';

class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> execute({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
    Function(double)? onProgress,
  }) async {
    DevLogger.params({
      'userId': userId,
      'title': title,
      'description': description,
      'imagesA_count': imagesA.length,
      'imagesB_count': imagesB.length,
      'isAnonymous': isAnonymous,
    }, tag: 'CreatePost');

    try {
      // 1. Validate inputs
      DevLogger.checkpoint('Step 1/8: Validating inputs', tag: 'CreatePost');
      final validationResult = _validateInputs(...);
      if (validationResult != null) {
        DevLogger.validation(
          field: 'inputs',
          reason: validationResult.toString(),
          tag: 'CreatePost',
        );
        return left(...);
      }

      onProgress?.call(0.1);

      // 2. Process images for option A
      DevLogger.checkpoint('Step 2/8: Processing images A', tag: 'CreatePost');
      final resultA = await _processImages(...);

      return resultA.fold((failure) {
        DevLogger.result(isSuccess: false, data: 'Step 2 failed: $failure', tag: 'CreatePost');
        return left(failure);
      }, (processedA) async {
        DevLogger.checkpoint('Step 2/8 completed: ${processedA.approvedFiles.length} images approved', tag: 'CreatePost');
        onProgress?.call(0.4);

        // 3. Process images for option B
        DevLogger.checkpoint('Step 3/8: Processing images B', tag: 'CreatePost');
        final resultB = await _processImages(...);

        return resultB.fold((failure) {
          DevLogger.result(isSuccess: false, data: 'Step 3 failed: $failure', tag: 'CreatePost');
          return left(failure);
        }, (processedB) async {
          DevLogger.checkpoint('Step 3/8 completed: ${processedB.approvedFiles.length} images approved', tag: 'CreatePost');
          onProgress?.call(0.7);

          // 4-8단계도 동일한 패턴으로 checkpoint 추가
          // ...

          DevLogger.checkpoint('Step 8/8: Creating post entity', tag: 'CreatePost');
          final eventId = _uuid.v4();
          DevLogger.checkpoint('Generated eventId: $eventId', tag: 'CreatePost');

          final createResult = await _postRepository.createPost(
            post: post,
            eventId: eventId,
          );

          return createResult.map((postId) {
            DevLogger.result(isSuccess: true, data: 'postId: $postId', tag: 'CreatePost');
            onProgress?.call(1.0);
            return savedPost;
          });
        });
      });
    } catch (error, stackTrace) {
      DevLogger.error('Post creation failed', error: error, stackTrace: stackTrace, tag: 'CreatePost');
      Logger.error('CreatePostUseCase: Post creation failed', ...);
      return left(...);
    }
  }
}
```

**로그 출력 예시**:
```
[DEV][CreatePost] 📋 PARAMS: {userId: user123, title: My Post, ...}
[DEV][CreatePost] 🎯 CHECKPOINT: Step 1/8: Validating inputs
[DEV][CreatePost] 🎯 CHECKPOINT: Step 2/8: Processing images A
[DEV][CreatePost] 🎯 CHECKPOINT: Step 2/8 completed: 3 images approved
[DEV][CreatePost] 🎯 CHECKPOINT: Step 3/8: Processing images B
[DEV][CreatePost] 🎯 CHECKPOINT: Step 3/8 completed: 2 images approved
...
[DEV][CreatePost] 🎯 CHECKPOINT: Step 8/8: Creating post entity
[DEV][CreatePost] 🎯 CHECKPOINT: Generated eventId: 550e8400-...
[DEV][CreatePost] ✅ SUCCESS - postId: post789
```

---

## Feature별 적용 가이드

### Auth Feature 상세 가이드

**목표**: 첫 번째 Feature이므로 템플릿 검증 + 팀 학습

#### 파일별 작업 순서

**1. sign_in_with_email_usecase.dart** (가장 먼저 - 참조 구현)

**Before**:
```dart
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<Either<AuthFailure, UserProfile>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
```

**After**:
```dart
import '/services/logging/dev_logger.dart';

class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<Either<AuthFailure, UserProfile>> call({
    required String email,
    required String password,
  }) async {
    DevLogger.params({'email': email}, tag: 'SignInWithEmail');

    DevLogger.checkpoint('Calling repository.signInWithEmail', tag: 'SignInWithEmail');
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SignInWithEmail'),
      (user) => DevLogger.result(isSuccess: true, data: user.uid, tag: 'SignInWithEmail'),
    );

    return result;
  }
}
```

**검증**:
```bash
flutter test test/features/auth/domain/usecases/sign_in/sign_in_with_email_usecase_test.dart

flutter run
# 로그인 화면에서 이메일 로그인 시도
# Console 출력 확인:
# [DEV][SignInWithEmail] 📋 PARAMS: {email: test@example.com}
# [DEV][SignInWithEmail] 🎯 CHECKPOINT: Calling repository.signInWithEmail
# [DEV][SignInWithEmail] ✅ SUCCESS - user123
```

**2. sign_up_with_email_usecase.dart** (sign_in 템플릿 복사)

동일한 패턴으로 적용:
- DevLogger import
- params 로깅
- checkpoint 로깅
- result 로깅

**3-10. 나머지 8개 파일** (동일 패턴 반복)

모두 Type A이므로 sign_in_with_email_usecase.dart 템플릿을 복사하여 적용

#### 전체 테스트

```bash
flutter test test/features/auth/
# 기대 결과: All tests passed!

flutter analyze
# 기대 결과: No issues found!
```

---

### Profile Feature 상세 가이드

**특이사항**: Type C (Stream) 패턴 1개 포함

#### Type C 적용 예시: watch_user_profile_usecase.dart

**Before**:
```dart
class WatchUserProfileUseCase {
  final IProfileRepository _repository;

  WatchUserProfileUseCase(this._repository);

  Stream<UserProfile?> call({required String userId}) {
    return _repository.watchUserProfile(userId).map(
      (either) => either.fold(
        (failure) => null,
        (profile) => profile,
      ),
    );
  }
}
```

**After**:
```dart
import '/services/logging/dev_logger.dart';

class WatchUserProfileUseCase {
  final IProfileRepository _repository;

  WatchUserProfileUseCase(this._repository);

  Stream<UserProfile?> call({required String userId}) {
    DevLogger.params({'userId': userId}, tag: 'WatchUserProfile');
    DevLogger.checkpoint('Starting stream watch', tag: 'WatchUserProfile');

    return _repository.watchUserProfile(userId).map(
      (either) {
        return either.fold(
          (failure) {
            DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'WatchUserProfile');
            return null;
          },
          (profile) {
            DevLogger.result(isSuccess: true, data: profile.uid, tag: 'WatchUserProfile');
            return profile;
          },
        );
      },
    );
  }
}
```

**주의사항**:
- Stream은 여러 번 emit → DevLogger.result도 여러 번 호출됨
- Console에 반복 로그가 나타나는 것은 정상 동작

---

### Chat Feature 상세 가이드

**특이사항**: Type B (Idempotent) + Type C (Stream) 혼합

#### Type B 적용 예시: send_message_usecase.dart

**Before**:
```dart
class SendMessageUseCase {
  final IChatRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<Either<ChatFailure, Message>> call({
    required String chatId,
    required String content,
  }) async {
    final eventId = _uuid.v4();

    return _repository.sendMessage(
      chatId: chatId,
      content: content,
      eventId: eventId,
    );
  }
}
```

**After**:
```dart
import '/services/logging/dev_logger.dart';

class SendMessageUseCase {
  final IChatRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<Either<ChatFailure, Message>> call({
    required String chatId,
    required String content,
  }) async {
    DevLogger.params({'chatId': chatId, 'content': content}, tag: 'SendMessage');

    final eventId = _uuid.v4();
    DevLogger.checkpoint('Generated eventId: $eventId', tag: 'SendMessage');

    DevLogger.checkpoint('Calling repository.sendMessage', tag: 'SendMessage');
    final result = await _repository.sendMessage(
      chatId: chatId,
      content: content,
      eventId: eventId,
    );

    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SendMessage'),
      (message) => DevLogger.result(isSuccess: true, data: message.id, tag: 'SendMessage'),
    );

    return result;
  }
}
```

**포인트**:
- UUID 생성 후 반드시 로깅 → Idempotency 디버깅에 중요
- eventId를 Console에서 확인하여 중복 방지 동작 검증 가능

---

### Creation Feature 상세 가이드

**특이사항**: Type D (Complex Multi-step) - 가장 복잡

#### Type D 적용 전략: create_post_usecase.dart

**195줄의 복잡한 로직**을 단계별로 추적하기 위해:

1. **8단계 프로세스 각각에 checkpoint**:
   - Step 1: 입력 검증
   - Step 2: 이미지 A 처리
   - Step 3: 이미지 B 처리
   - Step 4: 이미지 A 업로드
   - Step 5: 이미지 B 업로드
   - Step 6: Target Audience 검증
   - Step 7: Post Entity 생성
   - Step 8: Firestore 저장

2. **onProgress 콜백과 연동**:
   ```dart
   onProgress?.call(0.1);
   DevLogger.checkpoint('Step 1/8 completed', tag: 'CreatePost');
   ```

3. **fold 내부에서 실패 시점 정확히 로깅**:
   ```dart
   return resultA.fold((failure) {
     DevLogger.result(isSuccess: false, data: 'Step 2 failed: $failure', tag: 'CreatePost');
     return left(failure);
   }, (processedA) async {
     DevLogger.checkpoint('Step 2/8 completed: ${processedA.approvedFiles.length} images', tag: 'CreatePost');
     // ...
   });
   ```

**선택사항 - Early Return 리팩토링**:

현재 4-level nested fold 구조를 Early Return으로 평탄화하면 DevLogger 적용이 더 쉬워집니다:

```dart
// Early Return 패턴 (리팩토링 후)
Future<Either<CreationFailure, PostCreation>> execute({...}) async {
  DevLogger.params({...}, tag: 'CreatePost');

  try {
    // 1. Validate
    DevLogger.checkpoint('Step 1/8: Validating', tag: 'CreatePost');
    final validationResult = _validateInputs(...);
    if (validationResult != null) {
      DevLogger.validation(...);
      return left(validationResult);
    }

    // 2. Process A
    DevLogger.checkpoint('Step 2/8: Processing A', tag: 'CreatePost');
    final resultA = await _processImages(...);
    if (resultA.isLeft()) {
      DevLogger.result(isSuccess: false, data: 'Step 2 failed', tag: 'CreatePost');
      return resultA;
    }
    final processedA = resultA.getRight();
    DevLogger.checkpoint('Step 2 completed', tag: 'CreatePost');

    // 3-8. 동일한 패턴 반복 (flat 구조)

    DevLogger.result(isSuccess: true, data: 'postId: $postId', tag: 'CreatePost');
    return right(savedPost);
  } catch (error, stackTrace) {
    DevLogger.error('Post creation failed', error: error, stackTrace: stackTrace, tag: 'CreatePost');
    return left(...);
  }
}
```

**리팩토링 여부 결정**:
- **DevLogger만 추가**: 2시간
- **리팩토링 + DevLogger**: 4시간 (코드 품질 향상)

---

## 검증 및 테스트

### 단계별 검증 체크리스트

#### Phase별 검증

각 Phase 완료 후:

```bash
# 1. 해당 Feature 테스트 실행
flutter test test/features/{feature_name}/

# 2. 정적 분석
flutter analyze

# 3. 앱 실행 및 수동 테스트
flutter run
# 해당 Feature 기능 실행 → Console에서 DevLogger 출력 확인

# 4. 다음 Phase 진행 전 확인
# - 모든 테스트 통과
# - 정적 분석 0 errors
# - DevLogger 출력 확인 완료
```

#### 전체 검증 (Phase 9)

```bash
# 1. 전체 테스트
flutter test

# 2. 정적 분석
flutter analyze

# 3. Release 빌드 (kDebugMode 제거 확인)
flutter build apk --release
flutter build ios --release

# 4. APK 크기 비교
# Before DevLogger: X MB
# After DevLogger: X MB (동일 - tree-shaking 성공)
```

### 로그 출력 검증 가이드

#### 개발 환경 (kDebugMode = true)

```bash
flutter run
```

**기대 출력**:
```
[DEV][SignInWithEmail] 📋 PARAMS: {email: test@example.com}
[DEV][SignInWithEmail] 🎯 CHECKPOINT: Calling repository.signInWithEmail
[DEV][SignInWithEmail] ✅ SUCCESS - user123
```

#### 프로덕션 빌드 (kDebugMode = false)

```bash
flutter build apk --release
```

**기대 결과**:
- DevLogger 코드가 tree-shaking으로 완전히 제거됨
- APK에 DevLogger import나 호출이 포함되지 않음
- 빌드 크기 증가 없음

**검증 방법**:
```bash
# APK 디컴파일 후 DevLogger 검색
# 결과: 0개 발견 (완전히 제거됨)
```

### 운영 Logger 병행 검증

**DevLogger와 Logger 동시 동작 확인**:

```dart
// UseCase 예시
Future<Either<AuthFailure, UserProfile>> call({...}) async {
  // DevLogger: 개발 디버깅 (kDebugMode only)
  DevLogger.params({'email': email}, tag: 'SignIn');

  try {
    final result = await _repository.signIn(...);

    // DevLogger: 개발 로그
    result.fold(
      (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SignIn'),
      (user) => DevLogger.result(isSuccess: true, data: user.uid, tag: 'SignIn'),
    );

    return result;
  } catch (error, stackTrace) {
    // DevLogger: 개발 에러 로그
    DevLogger.error('Sign in failed', error: error, stackTrace: stackTrace, tag: 'SignIn');

    // Logger: 운영 에러 로그 (Firebase Crashlytics)
    Logger.error(
      'SignInWithEmailUseCase: Sign in failed',
      error: error,
      stackTrace: stackTrace,
      tag: 'SignInWithEmailUseCase',
    );

    return left(AuthFailure.serverError(error.toString()));
  }
}
```

**검증 결과**:
- ✅ DevLogger: Console에 출력 (개발 환경만)
- ✅ Logger: Firebase Crashlytics에 전송 (모든 환경)
- ✅ 충돌 없음: 각자 독립적으로 동작

---

## FAQ

### Q1. DevLogger vs Logger - 언제 사용하나요?

**DevLogger** (개발 디버깅):
- 용도: UseCase 실행 흐름 추적, 파라미터 확인, 디버깅
- 환경: kDebugMode (개발 환경만)
- 출력: Console (debugPrint)
- 비용: 0원 (로컬)

**Logger** (운영 모니터링):
- 용도: 프로덕션 에러 추적, 성능 모니터링, 사용자 영향 분석
- 환경: 모든 환경 (개발 + 프로덕션)
- 출력: Firebase Crashlytics, Cloud Logging
- 비용: Firebase 종량제

**결론**: 둘 다 사용 (목적이 다름)

---

### Q2. 기존 debugPrint는 어떻게 하나요?

**권장 접근**:

1. **UseCase Layer**: 모두 DevLogger로 교체
   ```dart
   // ❌ Before
   debugPrint('SignIn called with email: $email');

   // ✅ After
   DevLogger.params({'email': email}, tag: 'SignIn');
   ```

2. **Presentation Layer**: 그대로 유지 (선택사항)
   ```dart
   // Widget이나 Provider에서는 debugPrint 사용 가능
   debugPrint('Button pressed');
   ```

3. **Data Layer**: 그대로 유지 (Repository는 Logger 사용)

**이유**:
- DevLogger는 UseCase 전용으로 설계됨
- Presentation/Data Layer는 별도 로깅 전략 (선택사항)

---

### Q3. 모든 UseCase에 tag를 다 적어야 하나요?

**권장**: 네, tag를 적는 것이 좋습니다.

**이유**:
1. **로그 필터링**: Console에서 특정 UseCase만 검색 가능
2. **디버깅 효율**: 어느 UseCase의 로그인지 즉시 파악
3. **팀 협업**: 다른 개발자가 로그를 쉽게 이해

**예시**:
```bash
# Console에서 검색
[DEV][SignIn]  # SignIn 관련 로그만 필터링
[DEV][CreatePost]  # CreatePost 관련 로그만 필터링
```

**선택사항**: tag 생략 시
```dart
DevLogger.params({'email': email});  // tag 없음
// 출력: [DEV] 📋 PARAMS: {email: test@example.com}
```

---

### Q4. CreatePostUseCase 리팩토링은 필수인가요?

**아니요, 선택사항입니다.**

**DevLogger만 추가** (2시간):
- 현재 nested fold 구조 유지
- 각 fold 내부에 DevLogger 추가
- 실행 순서 동일하게 유지

**리팩토링 + DevLogger** (4시간):
- Early Return 패턴으로 평탄화
- DevLogger 추가가 더 쉬워짐
- 코드 가독성 향상

**권장**: DevLogger만 먼저 추가 → 리팩토링은 별도 Phase로

---

### Q5. Stream UseCase는 로그가 너무 많이 나오지 않나요?

**네, Stream은 반복 로그가 나타납니다.**

**예시**:
```
[DEV][WatchUserProfile] ✅ SUCCESS - user123
[DEV][WatchUserProfile] ✅ SUCCESS - user123  ← 1초 후
[DEV][WatchUserProfile] ✅ SUCCESS - user123  ← 2초 후
```

**해결법**:

1. **필요시에만 확인**: 디버깅할 때만 해당 Feature 실행
2. **Console 필터**: tag로 필터링하여 다른 로그는 숨김
3. **선택적 비활성화**: Stream UseCase는 DevLogger 주석 처리 (선택사항)

**권장**: 그대로 두기 (Stream 업데이트 주기 확인에 유용)

---

### Q6. AccountManagementUseCase는 어떻게 처리하나요?

**현재 문제**: 12개 메서드가 1개 파일에 존재 (SRP 위반)

**해결 옵션**:

**Option 1: Phase 1 진행 전 분리** (권장)
- 12개 메서드 → 7-12개 개별 UseCase로 분리
- 각 UseCase에 DevLogger 적용
- 예상 시간: 3시간

**Option 2: Phase 1에서 skip**
- Auth Feature 나머지 9개만 진행
- AccountManagement는 별도 Phase 0.5로 처리

**Option 3: 현재 상태로 DevLogger 추가**
- 12개 메서드 각각에 DevLogger 추가
- 나중에 분리 시 DevLogger는 그대로 유지

**권장**: Option 1 (Clean Architecture 원칙 준수)

---

### Q7. 운영 Logger도 같이 수정해야 하나요?

**아니요, DevLogger만 추가하면 됩니다.**

**현재 상태**:
```dart
try {
  // 비즈니스 로직
} catch (error, stackTrace) {
  Logger.error('UseCase failed', error: error, stackTrace: stackTrace);
  return left(Failure.serverError(error.toString()));
}
```

**DevLogger 추가 후**:
```dart
try {
  DevLogger.params({...});
  DevLogger.checkpoint('...');

  // 비즈니스 로직

  DevLogger.result(isSuccess: true);
} catch (error, stackTrace) {
  DevLogger.error('UseCase failed', error: error, stackTrace: stackTrace);
  Logger.error('UseCase failed', error: error, stackTrace: stackTrace);  // 그대로 유지
  return left(Failure.serverError(error.toString()));
}
```

**병행 운영**:
- DevLogger: 개발 디버깅 (kDebugMode)
- Logger: 운영 모니터링 (Firebase)
- 충돌 없음

---

### Q8. Phase별로 꼭 순서대로 진행해야 하나요?

**권장: 순서대로 진행**

**이유**:
1. **템플릿 검증**: Phase 1 (Auth)에서 템플릿 완성도 확인
2. **학습 곡선**: Type A → Type B → Type C → Type D 순으로 난이도 상승
3. **리스크 관리**: 초기 Phase에서 문제 발견 시 전체 계획 조정 가능

**예외**:
- 특정 Feature가 긴급하면 우선 적용 가능
- 단, Type A 템플릿은 반드시 먼저 검증

---

### Q9. 전체 15시간이 너무 긴데, 줄일 수 있나요?

**가능합니다. 병렬 작업으로 단축:**

**순차 실행** (1명): 15시간

**병렬 실행** (2명): 8-9시간
- Person A: Auth (2h) + Profile (3h) + Chat (2h) = 7h
- Person B: Notifications (1h) + Post (2h) + Creation (2h) + Voting (0.5h) + Search (1h) = 6.5h
- Phase 9 (검증): 1h (함께)

**병렬 실행** (3명): 5-6시간
- Person A: Auth + Profile = 5h
- Person B: Chat + Post = 4h
- Person C: Notifications + Creation + Voting + Search = 4.5h
- Phase 9 (검증): 1h (함께)

**주의**: Phase 1 (Auth) 완료 후 템플릿 공유 필수

---

### Q10. DevLogger 파일이 1개뿐이라 나중에 확장이 어렵지 않나요?

**괜찮습니다. 확장 전략:**

**현재 설계** (5개 메서드):
```dart
class DevLogger {
  static void params(...);
  static void checkpoint(...);
  static void result(...);
  static void validation(...);
  static void error(...);
}
```

**확장 가능성**:

1. **새 메서드 추가** (예: network 로깅):
   ```dart
   static void network({required String url, required int statusCode, String? tag}) {
     if (kDebugMode) {
       debugPrint('[DEV]${tag != null ? '[$tag]' : ''} 🌐 NETWORK: $url - $statusCode');
     }
   }
   ```

2. **설정 옵션 추가**:
   ```dart
   static bool enabled = true;  // 전역 on/off
   static Set<String> enabledTags = {};  // 특정 tag만 활성화
   ```

3. **출력 포맷 변경**:
   ```dart
   static void setFormatter(String Function(String) formatter) {
     // Custom 포맷터 주입
   }
   ```

**결론**: 1개 파일이지만 충분히 확장 가능

---

## 부록

### A. 참고 문서

- `lib/services/logging/README.md` - Logger vs DevLogger 비교
- `lib/services/logging/LOGGING_LEVEL_POLICY.md` - 로깅 레벨 정책
- `CLAUDE.md` - 프로젝트 전체 문서

### B. 관련 이슈

- AccountManagementUseCase SRP 위반: 12 메서드 → 7-12 UseCase 분리 필요
- SearchPostsUseCase 구현 필요 (현재 stub)

### C. 버전 히스토리

- v1.0.0 (2025-11-18): 초안 작성
- 예정: Phase별 완료 시 버전 업데이트

---

**작성일**: 2025-11-18
**작성자**: Claude Code + User Collaboration
**문서 버전**: v1.0.0
**총 페이지**: ~100줄 (Markdown)
