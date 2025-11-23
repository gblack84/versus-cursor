# Logging Level Policy - Production Environment

**작성일**: 2025-11-18
**버전**: 1.0.0
**상태**: Draft (Phase 2 - 실행 전 검토 필요)

---

## 📋 Executive Summary

이 문서는 Versus Space Flutter 앱의 **Production 환경에서 실행되는 로깅 레벨 정책**을 정의합니다.

**핵심 원칙**:
- ✅ **ERROR**: 모든 환경에서 활성화 (Development + Production)
- ⚠️ **WARNING**: Production에서 선택적 활성화 (성능/비용 이슈만)
- ℹ️ **INFO**: Production에서 비활성화 (Business metrics는 Analytics로 대체)
- 🔍 **DEBUG**: Development 전용 (Production에서 완전 비활성화)

**목표**:
- Production 에러 가시성: 0% → **100%** (Phase 1 완료)
- Warning 활성화: **20-30%** (성능/비용 관련만)
- Crashlytics 비용: 무료 플랜 한도 내 유지 (10K events/month)
- 개발 생산성: Debug logging 풍부하게 유지

---

## 🎯 Logging Level 정의

### 1. ERROR (에러) - 필수 Production 활성화

**정의**: 시스템 실패로 인한 사용자 영향이 있는 상황

**Production 활성화**: ✅ **YES** (Phase 1 완료)

**전송 대상**: Firebase Crashlytics (non-fatal errors)

**사용 기준**:
- ❌ 사용자 작업 실패 (로그인, 게시물 업로드, 투표 제출)
- ❌ 필수 데이터 로드 실패 (프로필, 채팅, 알림)
- ❌ 외부 서비스 통신 실패 (Firebase, Gemini AI, Perspective API)
- ❌ 캐시 손상/복구 불가능
- ❌ 보안 위반 감지 (무단 접근, 권한 오류)

**Production 예시**:
```dart
// 1. Authentication 실패
AuthLogger.signInError(
  authMethod: 'email',
  error: e,
);
// → Crashlytics 전송: "Sign in failed - Method: email"

// 2. Cache 손상
CacheLogger.cacheError(
  layer: 'L2-Hive',
  operation: 'open',
  error: e,
);
// → Crashlytics 전송: "Cache operation failed - Layer: L2-Hive, Operation: open"

// 3. AI Moderation 실패
ModerationLogger.perspectiveError(
  error: e,
  apiKey: Logger.maskSensitive(apiKey),
);
// → Crashlytics 전송: "Perspective API error - API Key: ***"
```

**Metadata 자동 첨부**:
- `tag`: Logger 계층 구조 (예: `Auth/SignIn`, `Cache/L1`)
- `timestamp`: ISO 8601 형식
- `environment`: Production/Development 자동 감지
- `userId`: 사용자 컨텍스트 (PII 마스킹 필수)

**KPI**:
- **Daily Error Events**: 100-300개 (Phase 1 완료 후 1주일 예상)
- **Error Rate**: <1% (총 사용자 작업 대비)
- **Crashlytics 무료 플랜**: 10K events/month (300 events/day 평균)

---

### 2. WARNING (경고) - 선택적 Production 활성화

**정의**: 즉시 실패는 아니지만 주의가 필요한 상황

**Production 활성화**: ⚠️ **선택적** (성능/비용 이슈만)

**전송 대상**: Firebase Crashlytics (선택적) 또는 로컬 로그만

**활성화 대상** (20-30% 예상):
1. **성능 저하 감지**
   - ⚠️ Cache miss rate >40% (예상 60% 대비 낮음)
   - ⚠️ Firestore query time >500ms
   - ⚠️ Image upload time >10s
   - ⚠️ Memory usage >80%

2. **비용 관련 알림**
   - ⚠️ Firestore 읽기 급증 (1시간 내 1000회 초과)
   - ⚠️ Storage 다운로드 급증 (1GB/hour 초과)
   - ⚠️ AI API 호출 급증 (Gemini 100회/hour 초과)

3. **품질 저하 감지**
   - ⚠️ AI moderation confidence <0.7 (일반적으로 0.9+)
   - ⚠️ Network retry 3회 이상
   - ⚠️ Deprecated API 사용 감지

**비활성화 대상** (70-80%):
- ❌ 일반적인 cache miss (정상 동작)
- ❌ 네트워크 재시도 1-2회 (정상 복구)
- ❌ 사용자 입력 검증 실패 (정상 UX)

**Production 예시** (활성화):
```dart
// 1. Cache hit rate 저하
CacheLogger.cacheWarning(
  message: 'L1 cache hit rate degraded',
  details: 'Current: 25% (Expected: 60%+)',
);
// → Crashlytics 전송 (성능 이슈)

// 2. Firestore 비용 급증
CacheLogger.cacheWarning(
  message: 'Firestore read spike detected',
  details: '1500 reads in last hour (Expected: <500)',
);
// → Crashlytics 전송 (비용 이슈)
```

**Production 예시** (비활성화):
```dart
// ❌ 일반적인 cache miss
CacheLogger.cacheWarning(
  message: 'Cache miss - fetching from Firestore',
  key: 'user_profile_123',
);
// → 로컬 로그만 (kDebugMode에서만 출력)

// ❌ 1회 네트워크 재시도
Logger.warning(
  'Network request retry',
  tag: 'Post/Upload',
);
// → 로컬 로그만
```

**구현 방법**:
```dart
// WARNING 레벨에 조건부 Crashlytics 전송 추가
static void warning(String message, {String? tag, Map<String, dynamic>? details}) {
  // Development: 항상 console 출력
  if (kDebugMode) {
    debugPrint('[${tag ?? _defaultTag}] ⚠️ WARNING: $message');
    if (details != null) {
      debugPrint('Details: $details');
    }
  }

  // Production: 특정 조건에서만 Crashlytics 전송
  if (!kDebugMode && _shouldSendWarningToCrashlytics(message, tag)) {
    try {
      FirebaseCrashlytics.instance.log(
        '⚠️ WARNING [${tag ?? _defaultTag}]: $message',
      );
      if (details != null) {
        FirebaseCrashlytics.instance.setCustomKey('warning_details', details.toString());
      }
    } catch (e) {
      // Crashlytics 실패 무시
    }
  }
}

// WARNING Crashlytics 전송 조건
static bool _shouldSendWarningToCrashlytics(String message, String? tag) {
  // 성능 저하 키워드
  if (message.contains('degraded') ||
      message.contains('slow') ||
      message.contains('timeout')) {
    return true;
  }

  // 비용 관련 키워드
  if (message.contains('spike') ||
      message.contains('quota') ||
      message.contains('limit')) {
    return true;
  }

  // 특정 Tag
  if (tag?.contains('Cache') == true &&
      (message.contains('hit rate') || message.contains('corruption'))) {
    return true;
  }

  // 기본: 전송 안 함
  return false;
}
```

**KPI**:
- **Daily Warning Events**: 20-50개 (선택적 전송만)
- **Warning Rate**: <5% (총 작업 대비)

---

### 3. INFO (정보) - Production 비활성화

**정의**: 정상 동작 중 비즈니스 메트릭이나 상태 변화

**Production 활성화**: ❌ **NO** (Firebase Analytics로 대체)

**이유**:
- ✅ **Firebase Analytics**가 비즈니스 메트릭 추적에 더 적합
  - User properties, Custom events, Conversion tracking
  - BigQuery 통합으로 대용량 분석 가능
  - 무료 플랜: Unlimited events
- ❌ **Crashlytics**는 에러 추적 전용
  - 무료 플랜: 10K events/month (제한적)
  - INFO 로그 전송 시 ERROR 이벤트 한도 소진

**대체 구현**:
```dart
// ❌ BEFORE: INFO 로그 (Production에서 의미 없음)
Logger.info(
  'User signed in',
  tag: 'Auth',
  details: {'method': 'email', 'userId': userId},
);
// → kDebugMode에서만 출력, Production 무시

// ✅ AFTER: Firebase Analytics 사용
FirebaseAnalytics.instance.logEvent(
  name: 'user_signed_in',
  parameters: {
    'method': 'email',
    'user_id': userId,
    'timestamp': DateTime.now().toIso8601String(),
  },
);
// → Production에서 Analytics로 전송
```

**Migration 가이드**:
| 기존 INFO 로그 | 대체 방법 |
|---------------|----------|
| 사용자 로그인/로그아웃 | `FirebaseAnalytics.logLogin()` |
| 게시물 생성/삭제 | `FirebaseAnalytics.logEvent('post_created')` |
| 투표 제출 | `FirebaseAnalytics.logEvent('vote_submitted')` |
| 프로필 업데이트 | `FirebaseAnalytics.logEvent('profile_updated')` |
| 캐시 히트율 (통계) | `FirebaseAnalytics.setUserProperty('cache_hit_rate')` |
| 앱 시작/종료 | `FirebaseAnalytics.logAppOpen()` |

**현재 구현**:
```dart
// INFO 메서드는 kDebugMode 유지 (변경 없음)
static void info(String message, {String? tag, Map<String, dynamic>? details}) {
  if (kDebugMode) {
    debugPrint('[${tag ?? _defaultTag}] ℹ️ INFO: $message');
    if (details != null) {
      debugPrint('Details: $details');
    }
  }
  // Production: 아무것도 하지 않음
}
```

**Development 사용 예시** (유지):
```dart
// Development: 정상 동작 확인용
Logger.info(
  'Cache hit',
  tag: 'Cache/L1',
  details: {'key': 'user_profile_123', 'ttl': '5min'},
);
// → Development console에만 출력
```

---

### 4. DEBUG (디버그) - Development 전용

**정의**: 개발자를 위한 상세 디버깅 정보

**Production 활성화**: ❌ **NO** (완전 비활성화)

**이유**:
- ✅ **Tree Shaking**: `if (kDebugMode)` 블록은 release build에서 완전히 제거됨
- ✅ **성능**: Production에서 불필요한 문자열 생성/로깅 오버헤드 제거
- ✅ **보안**: 민감한 디버깅 정보 (API 키, 토큰, 내부 로직) 노출 방지

**현재 구현** (변경 없음):
```dart
static void debug(String message, {String? tag, Map<String, dynamic>? details}) {
  if (kDebugMode) {
    debugPrint('[${tag ?? _defaultTag}] 🔍 DEBUG: $message');
    if (details != null) {
      debugPrint('Details: $details');
    }
  }
  // Production: 완전히 tree-shaken (코드 자체가 제거됨)
}
```

**Development 사용 예시** (권장):
```dart
// 1. 함수 진입점 추적
Logger.debug('Entering createPost()', tag: 'Creation');

// 2. 변수 값 검증
Logger.debug(
  'Draft auto-save triggered',
  tag: 'Creation/Draft',
  details: {
    'userId': userId,
    'draftId': draftId,
    'title': title.substring(0, min(20, title.length)),
  },
);

// 3. 조건 분기 추적
Logger.debug(
  'Cache strategy selected',
  tag: 'Cache',
  details: {'layer': 'L1', 'reason': 'Memory hit'},
);

// 4. 타이밍 분석
Logger.debug(
  'Firestore query completed',
  tag: 'Post/Query',
  details: {'duration': '${stopwatch.elapsedMilliseconds}ms'},
);
```

**과도한 DEBUG 로그 주의**:
```dart
// ❌ 나쁜 예: 루프 내부 DEBUG 로그 (성능 저하)
for (var i = 0; i < 1000; i++) {
  Logger.debug('Processing item $i');  // 1000번 호출
}

// ✅ 좋은 예: 배치 단위 로그
Logger.debug(
  'Batch processing started',
  details: {'itemCount': 1000},
);
// ... processing ...
Logger.debug('Batch processing completed');
```

---

## 📊 Logger별 Production 활성화 정책

### Critical 5 Loggers (Phase 1 완료 - 100% 활성화)

| Logger | ERROR | WARNING | INFO | DEBUG |
|--------|-------|---------|------|-------|
| **AuthLogger** | ✅ Crashlytics | ⚠️ 선택적 | ❌ Analytics | ❌ Dev only |
| **CacheLogger** | ✅ Crashlytics | ✅ 성능 이슈 | ❌ Analytics | ❌ Dev only |
| **ModerationLogger** | ✅ Crashlytics | ⚠️ AI confidence | ❌ Analytics | ❌ Dev only |
| **NotificationsLogger** | ✅ Crashlytics | ⚠️ 전달 실패율 | ❌ Analytics | ❌ Dev only |
| **PostLogger** | ✅ Crashlytics | ⚠️ 업로드 지연 | ❌ Analytics | ❌ Dev only |

**Phase 1 성과** (2025-11-18):
- **223개 error call sites** → Crashlytics 자동 전송
- Production error visibility: 0% → **100%**

---

### Important 6 Loggers (Phase 2 예정)

| Logger | ERROR | WARNING | INFO | DEBUG |
|--------|-------|---------|------|-------|
| **VotingLogger** | ✅ 활성화 예정 | ⚠️ 투표 지연 | ❌ Analytics | ❌ Dev only |
| **ChatLogger** | ✅ 활성화 예정 | ⚠️ 메시지 누락 | ❌ Analytics | ❌ Dev only |
| **MediaLogger** | ✅ 활성화 예정 | ✅ 업로드 실패 | ❌ Analytics | ❌ Dev only |
| **ProfileLogger** | ✅ 활성화 예정 | ⚠️ 동기화 지연 | ❌ Analytics | ❌ Dev only |
| **TargetAudienceLogger** | ✅ 활성화 예정 | ⚠️ AI 추천 실패 | ❌ Analytics | ❌ Dev only |
| **CreationLogger** | ✅ 활성화 예정 | ✅ Draft 손실 | ❌ Analytics | ❌ Dev only |

**Phase 2 목표** (44시간 예상):
- Important 6 ERROR logging → Crashlytics 전송
- WARNING 선택적 활성화 (성능/비용 이슈)
- INFO → Firebase Analytics 마이그레이션

---

### Support & Development Loggers (Phase 3)

| Logger | ERROR | WARNING | INFO | DEBUG | 정책 |
|--------|-------|---------|------|-------|------|
| **ServicesLogger** | ✅ 활성화 | ⚠️ 선택적 | ❌ Analytics | ❌ Dev | Phase 3 |
| **BatchLogger** | ✅ 활성화 | ⚠️ 배치 지연 | ❌ Analytics | ❌ Dev | Phase 3 |
| **SearchLogger** | ✅ 활성화 | ❌ 비활성화 | ❌ Analytics | ❌ Dev | Phase 3 |
| **StateLogger** | ❌ Dev only | ❌ Dev only | ❌ Dev only | ❌ Dev | Dev 전용 |
| **RouterLogger** | ❌ Dev only | ❌ Dev only | ❌ Dev only | ❌ Dev | Dev 전용 |
| **UtilsLogger** | ❌ Dev only | ❌ Dev only | ❌ Dev only | ❌ Dev | Dev 전용 |

**개발 전용 Logger 기준**:
- UI 상태 추적 (StateLogger): 프레임워크 내부 동작, Production 무관
- 라우팅 디버깅 (RouterLogger): 개발 시 네비게이션 검증
- 유틸리티 (UtilsLogger): 헬퍼 함수 동작 확인

---

## 🔒 보안 및 PII 마스킹

### PII (Personally Identifiable Information) 정책

**Production 로깅에서 절대 전송 금지**:
- ❌ 사용자 이메일 (전체)
- ❌ 전화번호
- ❌ 실명 (Full name)
- ❌ 주소/위치 정보
- ❌ 결제 정보
- ❌ Firebase Auth UID (해싱 후 전송)
- ❌ API 키/토큰 (완전 마스킹)

**허용되는 정보**:
- ✅ 사용자 ID (해싱 후, 예: `user_abc123`)
- ✅ 에러 타입/코드 (예: `auth/user-not-found`)
- ✅ 집계 통계 (예: `cache_hit_rate: 60%`)
- ✅ 타임스탬프
- ✅ Feature/Tag 정보

**자동 마스킹 구현**:
```dart
// Logger.maskSensitive() 메서드 사용
static String maskSensitive(String? value) {
  if (value == null || value.isEmpty) return '(null)';
  if (value.length <= 4) return '***';
  return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
}

// 사용 예시
AuthLogger.signInError(
  authMethod: 'email',
  error: e,
  // email은 로그에 포함하지 않음 (PII)
);

ModerationLogger.perspectiveError(
  error: e,
  apiKey: Logger.maskSensitive(apiKey),  // "ab***yz" 형태로 마스킹
);
```

**Crashlytics Custom Keys 정책**:
```dart
// ✅ 안전: 집계/통계 데이터
FirebaseCrashlytics.instance.setCustomKey('cache_hit_rate', 0.65);
FirebaseCrashlytics.instance.setCustomKey('feature', 'Auth');
FirebaseCrashlytics.instance.setCustomKey('error_type', 'network_timeout');

// ❌ 금지: PII 데이터
// FirebaseCrashlytics.instance.setCustomKey('user_email', 'user@example.com');
// FirebaseCrashlytics.instance.setCustomKey('user_name', 'John Doe');

// ✅ 안전: 해싱된 사용자 ID
final hashedUserId = sha256.convert(utf8.encode(userId)).toString().substring(0, 8);
FirebaseCrashlytics.instance.setCustomKey('user_id_hash', hashedUserId);
```

---

## 📈 Performance & Cost 관리

### Firebase Crashlytics 무료 플랜 한도

**Free Tier Limits**:
- **Events**: 10,000 events/month
- **Retention**: 90 days
- **Users**: Unlimited
- **Crash-free users**: Tracked automatically

**예상 사용량** (Phase 1-2 완료 후):
- **Daily ERROR Events**: 100-300개 (3,000-9,000/month)
- **Daily WARNING Events**: 20-50개 (600-1,500/month)
- **Total**: 3,600-10,500/month → **무료 플랜 한도 이내**

**초과 방지 전략**:
1. ✅ WARNING 선택적 활성화 (성능/비용 이슈만)
2. ✅ INFO 비활성화 (Analytics로 대체)
3. ✅ DEBUG 완전 비활성화 (Tree shaking)
4. ✅ 중복 에러 집계 (동일 에러 1시간 내 1회만 전송)

**중복 에러 방지 구현** (Phase 2):
```dart
static final Map<String, DateTime> _errorCache = {};
static const Duration _errorCooldown = Duration(hours: 1);

static void error(String message, {dynamic error, String? tag, StackTrace? stackTrace}) {
  // Development: 항상 출력
  if (kDebugMode) {
    debugPrint('[${tag ?? _defaultTag}] ❌ ERROR: $message');
    // ...
  }

  // Production: 중복 체크 후 전송
  if (error != null && !kDebugMode) {
    final errorKey = '${tag ?? _defaultTag}:$message';
    final lastSent = _errorCache[errorKey];

    // 1시간 내 동일 에러는 전송 안 함
    if (lastSent != null && DateTime.now().difference(lastSent) < _errorCooldown) {
      return;
    }

    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace ?? StackTrace.current,
        reason: message,
        information: [
          'tag: ${tag ?? _defaultTag}',
          'timestamp: ${DateTime.now().toIso8601String()}',
        ],
        fatal: false,
      );

      _errorCache[errorKey] = DateTime.now();
    } catch (crashlyticsError) {
      // ...
    }
  }
}
```

### 성능 영향 최소화

**Logger 호출 비용**:
- **kDebugMode 블록**: Tree-shaken in release → **0ms 오버헤드**
- **Crashlytics 전송**: 비동기 큐 → **<1ms 블로킹**
- **PII 마스킹**: 문자열 조작 → **<0.1ms**

**Best Practices**:
1. ✅ 에러 발생 시에만 호출 (정상 경로에서 호출 안 함)
2. ✅ 문자열 보간은 필요시에만 (lazy evaluation)
3. ✅ 복잡한 객체 직렬화 피하기 (toJson() 호출 최소화)

```dart
// ❌ 나쁜 예: 항상 문자열 생성
Logger.debug('User profile: ${user.toJson()}');  // toJson() 항상 호출

// ✅ 좋은 예: kDebugMode 내부에서만 생성
if (kDebugMode) {
  Logger.debug('User profile: ${user.toJson()}');  // Production에서 제거됨
}

// ✅ 더 좋은 예: 에러 발생 시에만 호출
try {
  // ...
} catch (e) {
  Logger.error('Profile update failed', error: e, tag: 'Profile');
  // → 에러 발생 시에만 오버헤드
}
```

---

## 🎯 Success Metrics (Phase 2)

### 1주일 후 검증 (Crashlytics Console)

**Error Visibility**:
- [ ] Daily error events: 100-300개 기록됨
- [ ] Error types 분류: 10-15개 distinct error types
- [ ] Stack traces 정상 표시
- [ ] Metadata (tag, timestamp) 정상 첨부

**Performance**:
- [ ] Crashlytics 전송 지연: <100ms (비동기 큐)
- [ ] 앱 응답 시간 영향: <1% 증가
- [ ] 메모리 사용량 증가: <5MB

**Warning 활성화** (선택적):
- [ ] Cache hit rate 저하 감지: 2-5건/일
- [ ] Firestore 비용 급증 감지: 0-2건/일

### 1개월 후 검증

**Quality**:
- [ ] **Error Rate**: <1% (총 사용자 작업 대비)
- [ ] **Crash-free Users**: >99.5%
- [ ] **Production Incidents**: 5-10건 사전 감지

**Cost**:
- [ ] **Crashlytics Events**: 3,600-10,500/month (무료 플랜 한도 이내)
- [ ] **Firestore 비용**: Cache 덕분에 40-60% 절감 유지

**Business Impact**:
- [ ] **Critical Error 탐지**: 223개 call sites 모니터링
- [ ] **평균 해결 시간**: <24시간 (Crashlytics 알림 덕분)
- [ ] **사용자 이탈 방지**: 에러 조기 발견으로 UX 개선

---

## 🔧 Implementation Checklist

### Phase 2 Task 1: Logging Level Policy (완료)

- [x] 정책 문서 작성 (LOGGING_LEVEL_POLICY.md)
- [x] ERROR/WARNING/INFO/DEBUG 정의
- [x] Logger별 활성화 정책 수립
- [x] PII 마스킹 정책 확정
- [x] Performance & Cost 관리 전략 수립

### Phase 2 Task 2: WARNING 선택적 활성화 (다음 단계)

- [ ] Logger.warning() 메서드 수정
  - [ ] _shouldSendWarningToCrashlytics() 구현
  - [ ] 키워드 기반 필터링 (degraded, slow, spike, quota)
  - [ ] Tag 기반 필터링 (Cache, Firestore, AI)
- [ ] CacheLogger.cacheWarning() 검증
  - [ ] Hit rate 저하 감지 테스트
  - [ ] Firestore 비용 급증 감지 테스트
- [ ] flutter analyze 검증

### Phase 2 Task 3: Important 6 Loggers 활성화

- [ ] VotingLogger ERROR 검증 (가장 높은 사용량)
- [ ] ChatLogger ERROR 검증
- [ ] MediaLogger ERROR 검증
- [ ] ProfileLogger ERROR 검증
- [ ] TargetAudienceLogger ERROR 검증
- [ ] CreationLogger ERROR 검증

### Phase 2 Task 4: Production Build & Testing

- [ ] Android Release APK 빌드
- [ ] iOS Release IPA 빌드 (macOS only)
- [ ] Web Release 빌드
- [ ] Firebase Console 연동 확인
- [ ] 실제 에러 발생 시뮬레이션 테스트

---

## 📚 참고 문서

- **PRODUCTION_LOGGING_PLAN.md**: Phase 1-2 전체 계획
- **PHASE_1_COMPLETION_SUMMARY.md**: Firebase Crashlytics 통합 완료 보고
- **logger_service.dart**: 18개 Domain Logger 구현 (4,295 lines)
- **Firebase Crashlytics 공식 문서**: https://firebase.google.com/docs/crashlytics
- **Flutter kDebugMode 가이드**: https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html

---

## 📞 FAQ

### Q1: WARNING도 모두 Crashlytics로 전송해야 하나요?

**A**: ❌ **NO**. WARNING은 선택적으로 전송합니다.

**이유**:
- Crashlytics 무료 플랜: 10K events/month (제한적)
- 대부분의 WARNING은 정상 동작 범위 (cache miss, 1-2회 재시도)
- **성능 저하**, **비용 급증**, **품질 이슈**만 전송하여 한도 내 유지

**전송 기준**:
```dart
// ✅ 전송: 성능 저하
CacheLogger.cacheWarning('L1 hit rate degraded: 25% (Expected: 60%+)');

// ✅ 전송: 비용 급증
CacheLogger.cacheWarning('Firestore read spike: 1500/hour (Expected: <500)');

// ❌ 전송 안 함: 일반 cache miss
CacheLogger.cacheWarning('Cache miss - fetching from Firestore');
```

---

### Q2: INFO는 왜 비활성화하나요? Business metrics는 어떻게 추적하나요?

**A**: INFO는 **Firebase Analytics**로 대체합니다.

**이유**:
- Crashlytics는 **에러 추적 전용** (무료 플랜 10K events/month)
- Analytics는 **비즈니스 메트릭 전용** (무료 플랜 Unlimited events)
- Analytics는 BigQuery 통합으로 대용량 분석 가능

**Migration 예시**:
```dart
// ❌ BEFORE: INFO 로그 (Production 무의미)
Logger.info('User signed in', tag: 'Auth', details: {'method': 'email'});

// ✅ AFTER: Firebase Analytics
FirebaseAnalytics.instance.logLogin(loginMethod: 'email');

// ❌ BEFORE: 게시물 생성 INFO
Logger.info('Post created', tag: 'Post', details: {'postId': postId});

// ✅ AFTER: Firebase Analytics Custom Event
FirebaseAnalytics.instance.logEvent(
  name: 'post_created',
  parameters: {'post_id': postId, 'type': 'voting'},
);
```

---

### Q3: DEBUG 로그는 언제 사용하나요?

**A**: **Development 환경에서만** 사용합니다.

**목적**:
- 함수 진입점 추적 (`Entering createPost()`)
- 변수 값 검증 (`Draft auto-save triggered`)
- 조건 분기 추적 (`Cache strategy selected: L1`)
- 타이밍 분석 (`Firestore query completed in 250ms`)

**Production 영향**: **0%** (Tree shaking으로 완전 제거)

**주의사항**:
```dart
// ❌ 나쁜 예: 루프 내부 DEBUG (성능 저하)
for (var i = 0; i < 1000; i++) {
  Logger.debug('Processing item $i');
}

// ✅ 좋은 예: 배치 단위 DEBUG
Logger.debug('Batch processing: 1000 items');
// ... processing ...
Logger.debug('Batch processing completed');
```

---

### Q4: 중복 에러 방지는 어떻게 구현되나요?

**A**: **1시간 Cooldown** 정책으로 동일 에러 중복 전송 방지합니다.

**구현**:
```dart
static final Map<String, DateTime> _errorCache = {};
static const Duration _errorCooldown = Duration(hours: 1);

// 동일 tag + message 조합으로 중복 체크
final errorKey = '${tag ?? _defaultTag}:$message';
final lastSent = _errorCache[errorKey];

// 1시간 내 동일 에러는 전송 안 함
if (lastSent != null && DateTime.now().difference(lastSent) < _errorCooldown) {
  return;  // Skip Crashlytics transmission
}

// 새 에러 또는 Cooldown 만료 → 전송
FirebaseCrashlytics.instance.recordError(...);
_errorCache[errorKey] = DateTime.now();
```

**효과**: Crashlytics 이벤트 사용량 **30-50% 절감** (반복 에러 제거)

---

### Q5: PII 마스킹은 자동으로 되나요?

**A**: ❌ **NO**. 개발자가 명시적으로 `Logger.maskSensitive()` 호출해야 합니다.

**자동 마스킹 대상**:
- API 키/토큰 (예: `ab***yz`)
- 사용자 ID (해싱 권장)

**절대 로깅 금지**:
- 이메일 (전체)
- 전화번호
- 실명
- 결제 정보

**사용 예시**:
```dart
// ✅ 안전: API 키 마스킹
ModerationLogger.perspectiveError(
  error: e,
  apiKey: Logger.maskSensitive(apiKey),  // "ab***yz"
);

// ✅ 안전: 사용자 ID 해싱
final hashedUserId = sha256.convert(utf8.encode(userId)).toString().substring(0, 8);
FirebaseCrashlytics.instance.setCustomKey('user_id_hash', hashedUserId);

// ❌ 금지: 이메일 그대로 전송
// AuthLogger.signInError(email: 'user@example.com');  // NEVER!
```

---

**작성일**: 2025-11-18
**작성자**: Claude (Sonnet 4.5)
**버전**: 1.0.0 (Draft)
**다음 단계**: Phase 2 Task 2 - WARNING 선택적 활성화 구현
