# Logger 마이그레이션 빠른 참조 카드

> **작성일**: 2025-11-15
> **목적**: print → Logger 변환을 위한 빠른 참조
> **상세 가이드**: [PRINT_TO_LOGGER_MIGRATION.md](PRINT_TO_LOGGER_MIGRATION.md)

---

## 🎯 1분 요약

| 항목 | 내용 |
|------|------|
| **현재 상태** | print 391개 ❌ (Production 배포 불가) |
| **목표** | Logger 사용으로 전환 ✅ |
| **우선순위** | Creation Feature (97개 print) |
| **예상 시간** | 7시간 (Phase 1-4) |

---

## 🔄 빠른 변환 테이블

### Repository (Data Layer)

```dart
# Before (print)
print('[Repository] Firestore write: id=$id');
print('[Repository] Firestore write completed');

# After (Logger)
Logger.info('Firestore write: id=${Logger.maskSensitive(id)}', tag: 'Repository');
Logger.info('Firestore write completed', tag: 'Repository');
```

### Notifier (Presentation Layer - 선택적)

```dart
# Before (print)
print('✅ Draft auto-saved');
print('⚠️ Draft auto-save failed: $e');

# After (Logger)
Logger.debug('Draft auto-saved (debounced 500ms)', tag: 'CreatePostNotifier');
Logger.error('Draft auto-save failed', error: e, tag: 'CreatePostNotifier');
```

### Provider/Widget

```dart
# ❌ 로깅 불필요 (Either 패턴 또는 AsyncValue.when이 자동 처리)
# Provider는 Either<Failure, T> 반환
# Widget은 AsyncValue.when() 사용
```

---

## 🗑️ 삭제 vs 변환 빠른 참조

### 결정 테이블

| 위치 | 작업 | 이유 | 예시 개수 |
|------|------|------|-----------|
| **Widget** | 🔴 DELETE | DevTools 사용 | 50+ |
| **Provider** | 🔴 DELETE | Either 패턴 | 144+ |
| **Notifier (중복)** | 🔴 DELETE | Repository 로깅 | 4 |
| **Form 이벤트** | 🔴 DELETE | 정보 과다 | 15+ |
| **Repository** | ✅ CONVERT | Data Layer 로깅 | 97 |
| **AI/API** | ✅ CONVERT | 도메인 Logger | 76 |
| **Notifier (고유)** | ✅ CONVERT | 비중복 로직 | 소량 |

### 빠른 체크리스트

**DELETE 체크**:
- [ ] Widget build() 내부? → DELETE
- [ ] Provider fold() 내부? → DELETE
- [ ] Repository에서 이미 로깅? → DELETE
- [ ] Form 입력 이벤트? → DELETE

**CONVERT 체크**:
- [ ] Repository Firestore 쓰기? → CONVERT
- [ ] AI/외부 API 호출? → CONVERT
- [ ] Notifier 고유 로직 (Repository 미로깅)? → CONVERT

### 우선순위

```bash
# Phase 1: DELETE 먼저 (1시간) - 즉시 시작
Widget 디버깅 (50+) + Provider (144+) + Notifier 중복 (4) + Form (15+) = 218개

# Phase 2: CONVERT 나중 (6시간) - Phase 1 완료 후
Repository (97) + AI/API (76) + Notifier 고유 (소량) = 173개
```

**상세 가이드**: [PRINT_TO_LOGGER_MIGRATION.md](PRINT_TO_LOGGER_MIGRATION.md) "삭제 vs 변환 결정 가이드" 섹션

---

## ✅ 레이어별 체크리스트

### Domain Layer

- [ ] ❌ **로깅 금지** (Pure Dart, 프레임워크 독립)
- [ ] ✅ Either<Failure, T> 패턴으로 에러 전파

### Data Layer (Repository)

- [ ] ✅ **Firestore 쓰기 작업** 로깅 (`Logger.info`)
- [ ] ✅ **캐시 히트/미스** 로깅 (`Logger.debug`)
- [ ] ✅ **외부 API 호출** (AI, Perspective) 로깅 (`Logger.info`)
- [ ] ✅ **에러 발생** 로깅 (`Logger.error`)
- [ ] ✅ 민감 정보 마스킹 (`Logger.maskSensitive()`)
- [ ] ❌ Firestore 읽기는 **로깅 불필요** (캐시 로그로 충분)

### Presentation Layer

#### Provider

- [ ] ❌ **로깅 불필요** (Either 패턴이 에러 자동 처리)
- [ ] ✅ Either → AsyncValue 변환만

#### Notifier

- [ ] ✅ **비즈니스 로직만** 로깅
  - [ ] Draft 자동 저장 (`Logger.debug`)
  - [ ] 미디어 업로드 (`Logger.info`)
  - [ ] AI 콘텐츠 검열 (`Logger.info`)
- [ ] ❌ 일반 상태 변경은 로깅 불필요

#### Widget

- [ ] ❌ **로깅 불필요** (AsyncValue.when이 자동 처리)
- [ ] ✅ AsyncValue.when() 사용
  ```dart
  async.when(
    data: (data) => SuccessWidget(data),
    loading: () => LoadingWidget(),  // 자동 로딩 처리
    error: (error, stack) => ErrorWidget(error),  // 자동 에러 처리
  )
  ```

---

## 📝 일반적인 패턴

### 1. 작업 시작/완료

```dart
# Before
print('[Service] Operation started: id=$id');
print('[Service] Operation completed');

# After
Logger.info('Operation started: id=${Logger.maskSensitive(id)}', tag: 'Service');
Logger.info('Operation completed', tag: 'Service');
```

### 2. 에러 처리

```dart
# Before
try {
  await operation();
} catch (e) {
  print('Error: $e');
}

# After
try {
  await operation();
} catch (e) {
  Logger.error('Operation failed', error: e, tag: 'Service');
  rethrow;  // Either 패턴으로 에러 전파
}
```

### 3. 민감 정보 마스킹

```dart
# Before (❌ GDPR 위반!)
print('User: userId=$userId, email=$email');

# After (✅ 안전)
Logger.info(
  'User: userId=${Logger.maskSensitive(userId)}, '
  'email=${Logger.maskSensitive(email)}',
  tag: 'UserService',
);
```

### 4. 캐시 히트/미스

```dart
# Before
print('Cache HIT: key=$key');
print('Cache MISS: key=$key');

# After (도메인 Logger 사용 권장)
CacheLogger.l1Hit(key);
CacheLogger.l1Miss(key);

# 또는
Logger.debug('L1 HIT: key=${Logger.maskSensitive(key)}', tag: 'Cache/L1');
Logger.debug('L1 MISS: key=${Logger.maskSensitive(key)}', tag: 'Cache/L1');
```

### 5. AI/외부 API 호출

```dart
# Before
print('[AI] Gemini API call started');
print('[AI] Gemini API call completed: tokens=$tokens');

# After (도메인 Logger 사용 권장)
TargetAudienceLogger.aiRecommendationStarted(contentId, count);
TargetAudienceLogger.aiRecommendationCompleted(
  totalCandidates: candidates.length,
  recommendedCount: userIds.length,
  avgScore: avgScore,
);

# 또는
Logger.info('Gemini API call started', tag: 'AI/Gemini');
Logger.info('Gemini API call completed: tokens=$tokens', tag: 'AI/Gemini');
```

### 6. 미디어 업로드

```dart
# Before
print('[Upload] Started: file=$fileName');
print('[Upload] Progress: ${progress}%');
print('[Upload] Completed in ${duration}ms');

# After (도메인 Logger 사용 권장)
MediaLogger.uploadStarted(mediaId: mediaId, mediaType: type, fileSize: size);
MediaLogger.uploadProgress(mediaId: mediaId, progress: progress);
MediaLogger.uploadCompleted(mediaId: mediaId, duration: duration, fileSize: size);

# 또는
Logger.info('Upload started: id=${Logger.maskSensitive(mediaId)}', tag: 'Media/Upload');
Logger.info('Upload completed: duration=${duration.inSeconds}s', tag: 'Media/Upload');
```

---

## 🏗 도메인 Logger 빠른 생성

### 생성 기준

**✅ 생성해야 하는 경우**:
- print 문 10개 이상
- 복잡한 로그 포맷 (여러 metadata)
- 민감 정보 마스킹 필요
- 재사용 가능한 로그 패턴

**❌ 생성 불필요한 경우**:
- print 문 10개 미만
- 단순한 로그 (1-2줄)
- `Logger.info()` 직접 사용으로 충분

### 템플릿

```dart
/// lib/services/logging/loggers/example_logger.dart
import '/services/logging/logger_service.dart';

/// Example 도메인 전용 Logger
class ExampleLogger {
  static const String _tag = 'Example';

  /// Operation started
  static void operationStarted(String id, int count) {
    Logger.info(
      'Operation started: id=${Logger.maskSensitive(id)}, count=$count',
      tag: '$_tag/Operation',
    );
  }

  /// Operation completed
  static void operationCompleted({
    required int resultCount,
    required Duration duration,
  }) {
    Logger.info(
      'Operation completed: results=$resultCount, duration=${duration.inSeconds}s',
      tag: '$_tag/Operation',
    );
  }

  /// Operation error
  static void operationError(String id, dynamic error) {
    Logger.error(
      'Operation failed: id=${Logger.maskSensitive(id)}',
      error: error,
      tag: '$_tag/Operation',
    );
  }
}
```

---

## 🔍 검증 명령어

### 1. print 문 찾기

```bash
# 모든 print 문 검색
grep -r "print(" lib/ --include="*.dart" \
  --exclude="*_test.dart" \
  --exclude="debug_*.dart" \
  --exclude="logger_service.dart" \
  | grep -v "debugPrint"

# Feature별 print 문 개수
grep -r "print(" lib/features/creation/ --include="*.dart" | wc -l
```

### 2. 민감 정보 노출 확인

```bash
# userId 노출 검색
grep -r "print.*userId" lib/ --include="*.dart"

# email 노출 검색
grep -r "print.*email" lib/ --include="*.dart"

# contentId 노출 검색
grep -r "print.*contentId" lib/ --include="*.dart"
```

### 3. Logger 사용 확인

```bash
# Logger 사용 개수
grep -r "Logger\." lib/ --include="*.dart" | wc -l

# Feature별 Logger 사용
grep -r "Logger\." lib/features/creation/ --include="*.dart" | wc -l
```

### 4. 마이그레이션 진행률

```bash
# 전체 진행률
echo "print: $(grep -r 'print(' lib/ --include='*.dart' | grep -v 'debugPrint' | wc -l)"
echo "Logger: $(grep -r 'Logger\.' lib/ --include='*.dart' | wc -l)"

# Feature별 진행률
for feature in auth profile chat notifications creation voting post search; do
  print_count=$(grep -r "print(" lib/features/$feature/ --include="*.dart" 2>/dev/null | wc -l)
  logger_count=$(grep -r "Logger\." lib/features/$feature/ --include="*.dart" 2>/dev/null | wc -l)
  echo "$feature: print=$print_count, Logger=$logger_count"
done
```

---

## ❓ 자주 묻는 질문 (FAQ)

### Q1. Provider에서 로깅이 필요한가요?

**A**: ❌ **불필요**. Provider는 Either 패턴으로 에러를 자동 전파합니다.

```dart
# ❌ 불필요한 로깅
@riverpod
FutureOr<UserProfile> userProfile(UserProfileRef ref, String userId) {
  print('Getting user profile');  // ❌ 불필요
  final useCase = getIt<GetUserProfileUseCase>();
  return useCase(userId).then(
    (either) => either.fold(
      (failure) {
        print('Error: $failure');  // ❌ 불필요 (AsyncValue가 자동 처리)
        throw Exception(failure.getUserMessage());
      },
      (profile) => profile,
    ),
  );
}

# ✅ 올바른 방법
@riverpod
FutureOr<UserProfile> userProfile(UserProfileRef ref, String userId) {
  final useCase = getIt<GetUserProfileUseCase>();
  return useCase(userId).then(
    (either) => either.fold(
      (failure) => throw Exception(failure.getUserMessage()),
      (profile) => profile,
    ),
  );
}
```

### Q2. 모든 Firestore 작업을 로깅해야 하나요?

**A**: ❌ **쓰기 작업만** 로깅합니다. 읽기는 캐시 로그로 충분합니다.

```dart
# ✅ Firestore 쓰기 - 로깅 필요
await _firestore.collection('posts').doc(postId).set(data);
Logger.info('Post created: postId=${Logger.maskSensitive(postId)}', tag: 'PostRepository');

# ❌ Firestore 읽기 - 로깅 불필요 (캐시 로그로 추적됨)
final doc = await _firestore.collection('posts').doc(postId).get();
// Logger 호출 불필요
```

### Q3. debugPrint는 어떻게 하나요?

**A**: ✅ **유지**. `debugPrint`는 Flutter 프레임워크용이므로 그대로 둡니다.

```dart
# ✅ debugPrint 유지 (Flutter 프레임워크용)
debugPrint('Widget rebuilt: $runtimeType');

# ❌ print 제거
print('Custom log message');  // → Logger.info()
```

### Q4. 에러 로그에 StackTrace도 포함하나요?

**A**: ✅ **자동 포함**. `Logger.error()`는 StackTrace를 자동으로 기록합니다.

```dart
try {
  await operation();
} catch (e, stackTrace) {
  // ✅ StackTrace 자동 포함
  Logger.error('Operation failed', error: e, tag: 'Service');
  // stackTrace는 Logger 내부에서 자동 캡처됨
}
```

### Q5. kDebugMode 체크가 필요한가요?

**A**: ❌ **불필요**. Logger가 자동으로 처리합니다.

```dart
# ❌ 수동 kDebugMode 체크 불필요
if (kDebugMode) {
  Logger.info('Debug message');
}

# ✅ Logger가 자동으로 환경 감지
Logger.info('Message');  // kDebugMode가 false면 자동으로 건너뜀
```

---

## 📊 우선순위 매트릭스

| Feature | print 개수 | 우선순위 | 예상 시간 |
|---------|-----------|---------|----------|
| **Creation** | 97개 | 🔴 **P1** | 3시간 |
| Auth | 12개 | 🟡 P2 | 30분 |
| Profile | 45개 | 🟡 P2 | 1.5시간 |
| Chat | 38개 | 🟡 P2 | 1시간 |
| Voting | 56개 | 🟡 P2 | 1.5시간 |
| Notifications | 28개 | 🟢 P3 | 1시간 |
| Post | 18개 | 🟢 P3 | 30분 |
| Search | 35개 | 🟢 P3 | 1시간 |

**Phase 1 권장**: Creation Feature 집중 (3시간)

---

## 🎯 빠른 시작 (5분)

1. **도메인 Logger 생성** (1분)
   ```bash
   # lib/services/logging/loggers/target_audience_logger.dart 생성
   # 템플릿: loggers/README.md 참조
   ```

2. **import 추가** (1분)
   ```dart
   import '/services/logging/loggers/target_audience_logger.dart';
   ```

3. **print → Logger 변환** (3분)
   ```bash
   # Before
   print('[TargetAudienceService] AI 추천 시작: postId=$contentId');

   # After
   TargetAudienceLogger.aiRecommendationStarted(contentId, count);
   ```

4. **검증** (30초)
   ```bash
   grep -r "print(" lib/features/creation/ --include="*.dart" | wc -l
   flutter analyze
   ```

---

## 📚 관련 문서

- **상세 가이드**: [PRINT_TO_LOGGER_MIGRATION.md](PRINT_TO_LOGGER_MIGRATION.md) (2000줄)
- **도메인 Logger**: [loggers/README.md](loggers/README.md) (534줄)
- **Logger 서비스**: [logger_service.dart](logger_service.dart) (444줄)

---

**마지막 업데이트**: 2025-11-15
**버전**: v1.0.0
**작성자**: Claude Code (Quick Reference)
