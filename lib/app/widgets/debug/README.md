# 🐛 Debug Tools

> 개발자 전용 디버깅 도구 모음 (kDebugMode 전용)
> **최종 업데이트**: 2025-11-10 | **버전**: 1.0.0

[![kDebugMode](https://img.shields.io/badge/Access-kDebugMode%20only-red)](https://api.flutter.dev/flutter/foundation/kDebugMode-constant.html)
[![Security](https://img.shields.io/badge/Security-Production%20Safe-green)](https://flutter.dev)

---

## 📋 목차

- [개요](#-개요)
- [DebugLogPage 상세](#-debuglogpage-상세)
- [사용 가이드](#-사용-가이드)
- [Logger API 통합](#-logger-api-통합)
- [보안](#-보안)
- [Future Enhancements](#-future-enhancements)

---

## 🎯 개요

`/lib/app/widgets/debug` 디렉토리는 개발자 전용 디버깅 도구를 제공합니다. 현재 **DebugLogPage**만 포함되어 있으며, 향후 성능 모니터, 네트워크 인스펙터 등이 추가될 예정입니다.

### 핵심 특징

✅ **kDebugMode 전용**: Release 빌드에서 자동 제외
✅ **Logger 통합**: core/utils/logger.dart와 연동
✅ **터미널 스타일 UI**: 검은 배경 + 초록 텍스트
✅ **클립보드 복사**: 전체/최근 100개 로그 복사 지원

---

## 📂 DebugLogPage 상세

### 파일 정보

| 항목 | 값 |
|------|-----|
| **경로** | `/lib/app/widgets/debug/debug_log_page.dart` |
| **라인 수** | 63줄 |
| **클래스** | `DebugLogPage` (StatelessWidget) |
| **라우트** | `/debug/logs` |
| **접근 제어** | `kDebugMode == true` |
| **Migration** | ✅ StatelessWidget (상태 없음, Riverpod 불필요) |

### UI 구조

```
DebugLogPage
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "Debug Logs"
│   │   └── Actions
│   │       ├── IconButton (copy_all) → 전체 로그 복사
│   │       └── IconButton (delete_forever) → 로그 삭제
│   ├── Body
│   │   └── SingleChildScrollView
│   │       └── Container (검은 배경)
│   │           └── SelectableText
│   │               - Text: Logger.getAllLogs()
│   │               - Style: Monospace, 초록색
│   │               - Selectable: true
│   └── FloatingActionButton
│       - Icon: content_copy
│       - OnPressed: 최근 100개 로그 복사
```

### 주요 기능

#### 1. 로그 조회 (실시간)

```dart
// Logger.getAllLogs() 호출
SelectableText(
  Logger.getAllLogs(),
  style: TextStyle(
    fontFamily: 'Courier',  // Monospace 폰트
    color: Colors.green[400],
    fontSize: 12,
  ),
)
```

**특징**:
- ✅ 전체 로그 출력 (최대 1000개)
- ✅ SelectableText로 텍스트 선택 가능
- ✅ SingleChildScrollView로 스크롤 지원

#### 2. 전체 로그 복사

```dart
// AppBar의 복사 아이콘
IconButton(
  icon: Icon(Icons.copy_all),
  onPressed: () async {
    await Clipboard.setData(ClipboardData(text: Logger.getAllLogs()));
    // SnackBar 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📋 로그가 클립보드에 복사되었습니다')),
    );
  },
)
```

**사용 시나리오**:
1. 앱 크래시 후 전체 로그 복사
2. 외부 도구(VS Code, Notion)에 붙여넣기
3. 팀원과 로그 공유 (Slack, 이메일)

#### 3. 최근 100개 로그 복사

```dart
// FloatingActionButton
FloatingActionButton(
  onPressed: () async {
    final recentLogs = Logger.getRecentLogs(100);
    await Clipboard.setData(ClipboardData(text: recentLogs));
    // SnackBar 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📋 최근 100개 로그 복사')),
    );
  },
  child: Icon(Icons.content_copy),
)
```

**사용 시나리오**:
1. 빠른 디버깅 (최근 로그만 필요)
2. 메모리 절약 (전체 로그 불필요)
3. 특정 작업 후 로그 확인 (100개 이내)

#### 4. 로그 삭제

```dart
// AppBar의 삭제 아이콘
IconButton(
  icon: Icon(Icons.delete_forever),
  onPressed: () {
    Logger.clearLogs();
    // SnackBar 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🗑️ 로그가 삭제되었습니다')),
    );
  },
)
```

**사용 시나리오**:
1. 긴 세션 후 메모리 절약
2. 새로운 테스트 시작 전 로그 초기화
3. 혼란스러운 로그 정리

### UI 스타일

#### 터미널 스타일

```dart
Container(
  color: Colors.black,  // 검은 배경
  padding: EdgeInsets.all(16),
  child: SelectableText(
    Logger.getAllLogs(),
    style: TextStyle(
      fontFamily: 'Courier',  // Monospace 폰트
      color: Colors.green[400],  // 초록 텍스트
      fontSize: 12,
    ),
  ),
)
```

**디자인 근거**:
- **검은 배경**: 터미널 느낌, 눈의 피로 감소
- **초록 텍스트**: 전통적인 터미널 색상
- **Monospace 폰트**: 로그 정렬 및 가독성 향상

#### 반응형 디자인

```dart
// 패딩: 모바일/태블릿/데스크톱 자동 조정
EdgeInsets.all(16)  // 기본 16px

// 폰트 크기: 작은 화면에서도 읽기 쉬움
fontSize: 12  // 고정 크기 (반응형 불필요)
```

---

## 🎓 사용 가이드

### 접근 방법

#### 방법 1: 직접 라우트 이동

```dart
// 앱 실행 중 어디서든
context.go('/debug/logs');

// 또는 named route
context.goNamed('DebugLogs');
```

#### 방법 2: Settings 화면에서 5번 탭

1. Settings 화면 접속 (`/settings`)
2. "설정" 타이틀 5번 연속 탭 (5초 내)
3. 🔧 "Debug mode activated" 스낵바 확인
4. 디버그 로그 페이지 자동 이동

**구현 위치**: `/lib/features/profile/presentation/screens/settings/settings_screen.dart`

```dart
// settings_screen.dart
GestureDetector(
  onTap: kDebugMode ? _onLogoTap : null,
  child: Text('설정'),
)

void _onLogoTap() {
  // 5번 탭 카운트
  if (_logoTapCount >= 5) {
    context.push('/debug/logs');
  }
}
```

#### 방법 3: 개발자 메뉴에 버튼 추가

```dart
// TestpageSelectWidget 또는 개발자 전용 페이지
ElevatedButton(
  onPressed: () => context.go('/debug/logs'),
  child: Text('디버그 로그 보기'),
)
```

---

### 로그 활용 시나리오

#### 시나리오 1: 버그 재현 후 로그 분석

```dart
// 1. 버그 재현 작업 수행
await signInUseCase(email, password);  // 로그인 실패 버그

// 2. DebugLogPage 접속
context.go('/debug/logs');

// 3. 전체 로그 복사 (AppBar 복사 아이콘)
// 클립보드에 복사됨

// 4. VS Code에 붙여넣기
// 로그 분석 (에러 스택, 타임스탬프 확인)

// 5. 버그 수정 후 로그 삭제
Logger.clearLogs();
```

#### 시나리오 2: 성능 디버깅

```dart
// 1. 성능 테스트 시작
Logger.info('Performance test started');

// 2. 작업 수행 (느린 화면 전환 등)
for (int i = 0; i < 100; i++) {
  await fetchData();  // 100번 데이터 가져오기
  Logger.info('Iteration $i completed');
}

Logger.info('Performance test completed');

// 3. 최근 100개 로그 복사 (FloatingActionButton)
// 로그 분석 (각 iteration 소요 시간 확인)

// 4. 병목 지점 파악
// "Iteration 50 completed" → 3초 소요 (너무 느림)
```

#### 시나리오 3: 팀원과 로그 공유

```dart
// 1. 버그 재현
await submitVote(voteId: 'vote123');  // 투표 제출 실패

// 2. DebugLogPage 접속
context.go('/debug/logs');

// 3. 전체 로그 복사

// 4. Slack/이메일에 붙여넣기
/*
[2025-11-10 14:32:15] INFO: User tapped vote button
[2025-11-10 14:32:16] WARNING: Vote already exists
[2025-11-10 14:32:16] ERROR: Vote submission failed: AlreadyVoted
*/

// 5. 팀원이 로그 분석 후 해결책 제시
```

---

## 🔧 Logger API 통합

DebugLogPage는 `core/utils/logger.dart`와 통합되어 있습니다.

### Logger 클래스 개요

**파일**: `/lib/core/utils/logger.dart`
**라인 수**: 181줄
**패턴**: Singleton

```dart
class Logger {
  // 싱글톤 인스턴스
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  // 메모리 로그 저장소 (최대 1000개)
  static final List<String> _logs = [];
  static const int _maxLogs = 1000;

  // 로그 레벨
  static void debug(String message, {String? tag}) { ... }
  static void info(String message, {String? tag}) { ... }
  static void warning(String message, {String? tag}) { ... }
  static void error(String message, {String? tag}) { ... }

  // 액션 추적
  static void logAction(String action, {Map<String, dynamic>? data}) { ... }
  static void logNavigation(String from, String to) { ... }
  static void logButtonClick(String buttonName) { ... }

  // 로그 조회
  static String getAllLogs() => _logs.join('\n');
  static String getRecentLogs(int count) => _logs.take(count).join('\n');

  // 로그 삭제
  static void clearLogs() => _logs.clear();

  // 민감 정보 마스킹
  static String maskSensitive(String value) { ... }
}
```

### 사용 예시

#### 1. 로그 기록

```dart
// INFO 로그
Logger.info('User logged in: ${user.id}');

// WARNING 로그
Logger.warning('Low memory warning: ${memoryUsage}MB');

// ERROR 로그
Logger.error('Network request failed: $error');

// DEBUG 로그 (개발 중에만)
Logger.debug('User profile loaded', tag: 'ProfileScreen');
```

#### 2. 액션 추적

```dart
// 버튼 클릭
Logger.logButtonClick('SignInButton');

// 화면 전환
Logger.logNavigation('/login', '/home');

// 커스텀 액션 (메타데이터 포함)
Logger.logAction('vote_submitted', data: {
  'voteId': voteId,
  'option': 'A',
  'timestamp': DateTime.now().toIso8601String(),
});
```

#### 3. 민감 정보 마스킹

```dart
// 사용자 ID 마스킹 (처음 3자만 표시)
final maskedUserId = Logger.maskSensitive('user123456');
// → 'use***'

// 이메일 마스킹
final maskedEmail = Logger.maskSensitive('john.doe@example.com');
// → 'joh***'

// 로그에 마스킹된 정보 기록
Logger.info('User action: ${maskedUserId}');
```

### Logger 메모리 관리

#### 원형 버퍼 (Circular Buffer)

```dart
static void _addLog(String log) {
  // 최대 1000개 로그 유지
  if (_logs.length >= _maxLogs) {
    _logs.removeAt(0);  // 가장 오래된 로그 제거
  }
  _logs.add(log);
}
```

**장점**:
- ✅ 메모리 오버플로 방지
- ✅ 항상 최신 1000개 로그 유지
- ✅ 자동 관리 (수동 삭제 불필요)

#### 로그 포맷

```dart
// 타임스탬프 + 레벨 + 태그 + 메시지
[2025-11-10 14:32:15] INFO [ProfileScreen]: User profile loaded
[2025-11-10 14:32:16] WARNING: Low memory warning: 450MB
[2025-11-10 14:32:17] ERROR: Network request failed: SocketException
```

---

## 🔒 보안

### kDebugMode 이중 체크

#### 1. nav.dart에서 라우트 레벨 체크

```dart
// lib/app/router/navigation/nav.dart
GoRoute(
  name: 'DebugLogs',
  path: '/debug/logs',
  pageBuilder: (context, state) {
    // ✅ 개발 모드 체크
    if (!kDebugMode) {
      return MaterialPage(
        child: Scaffold(
          appBar: AppBar(title: Text('Access Denied')),
          body: Center(
            child: Text(
              'Debug mode only',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      );
    }

    // 개발 모드에서만 DebugLogPage 표시
    return MaterialPage(child: DebugLogPage());
  },
)
```

#### 2. Release 빌드에서 자동 제외

```dart
// kDebugMode는 컴파일 타임 상수
// Release 빌드: kDebugMode == false
// → DebugLogPage 코드 완전 제외 (Tree Shaking)

if (!kDebugMode) {
  return MaterialPage(child: AccessDeniedScreen());  // Release: 이 코드만 포함
}
return MaterialPage(child: DebugLogPage());  // Debug: 이 코드만 포함
```

**결과**:
- ✅ Release 빌드 크기 절감 (DebugLogPage 코드 제외)
- ✅ 보안 강화 (사용자에게 로그 노출 방지)
- ✅ 성능 향상 (Logger 메모리 사용 없음)

### 민감 정보 보호

#### DO ✅

```dart
// ✅ 사용자 ID 마스킹
final maskedUserId = Logger.maskSensitive(user.uid);
Logger.info('User action: $maskedUserId');

// ✅ 에러 메시지만 로깅 (스택 제외)
Logger.error('Login failed: ${e.message}');

// ✅ 요청 URL만 로깅 (파라미터 제외)
Logger.info('API call: /api/users');
```

#### DON'T ❌

```dart
// ❌ 비밀번호 로깅 금지
Logger.info('Password: $password');  // 절대 금지!

// ❌ API 키 로깅 금지
Logger.info('API Key: $apiKey');  // 절대 금지!

// ❌ 전체 사용자 객체 로깅 금지
Logger.info('User: ${user.toString()}');  // 민감 정보 포함 가능

// ❌ 민감한 요청 파라미터 로깅 금지
Logger.info('API call: /api/login?email=user@example.com&password=***');  // 이메일 노출
```

---

## 🚀 Future Enhancements

### 우선순위 1 (단기 - 1개월)

- [ ] **로그 레벨 필터**: INFO, WARNING, ERROR 레벨별 필터링
  ```dart
  // UI: Chip 선택
  ChoiceChip(label: Text('INFO'), selected: showInfo),
  ChoiceChip(label: Text('WARNING'), selected: showWarning),
  ChoiceChip(label: Text('ERROR'), selected: showError),

  // 필터링 로직
  final filteredLogs = Logger.getAllLogs()
      .split('\n')
      .where((log) => log.contains('INFO') || log.contains('ERROR'))
      .join('\n');
  ```

- [ ] **로그 검색**: 키워드 기반 검색
  ```dart
  // UI: TextField
  TextField(
    decoration: InputDecoration(
      hintText: '로그 검색...',
      prefixIcon: Icon(Icons.search),
    ),
    onChanged: (query) {
      // 검색 로직
      final searchResults = Logger.getAllLogs()
          .split('\n')
          .where((log) => log.toLowerCase().contains(query.toLowerCase()))
          .join('\n');
    },
  )
  ```

### 우선순위 2 (중기 - 3개월)

- [ ] **실시간 로그 스트리밍**: StreamBuilder로 자동 업데이트
  ```dart
  // Logger 클래스에 Stream 추가
  static final StreamController<String> _logStream = StreamController.broadcast();

  static void info(String message) {
    _logs.add(message);
    _logStream.add(message);  // 스트림에 추가
  }

  // DebugLogPage에서 구독
  StreamBuilder<String>(
    stream: Logger.logStream,
    builder: (context, snapshot) {
      return SelectableText(Logger.getAllLogs());
    },
  )
  ```

- [ ] **로그 Export**: .txt 파일로 내보내기
  ```dart
  // File I/O
  import 'dart:io';

  Future<void> exportLogs() async {
    final file = File('${Directory.systemTemp.path}/debug_logs.txt');
    await file.writeAsString(Logger.getAllLogs());

    // Share 패키지로 공유
    await Share.shareFiles([file.path], text: 'Debug Logs');
  }
  ```

### 우선순위 3 (장기 - 6개월)

- [ ] **성능 모니터**: FPS, 메모리 사용량 실시간 표시
  ```dart
  // lib/app/widgets/debug/performance_monitor.dart
  class PerformanceMonitor extends StatefulWidget {
    @override
    Widget build(BuildContext context) {
      return Overlay(
        child: Column(
          children: [
            Text('FPS: ${_fps}'),
            Text('Memory: ${_memoryUsage}MB'),
          ],
        ),
      );
    }
  }
  ```

- [ ] **네트워크 인스펙터**: API 요청/응답 로깅
  ```dart
  // HTTP Interceptor
  class DebugInterceptor extends Interceptor {
    @override
    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
      Logger.info('API Request: ${options.method} ${options.path}');
      super.onRequest(options, handler);
    }

    @override
    void onResponse(Response response, ResponseInterceptorHandler handler) {
      Logger.info('API Response: ${response.statusCode} ${response.data}');
      super.onResponse(response, handler);
    }
  }
  ```

---

## 📚 관련 문서

- [widgets/README.md](../README.md) - App Widgets 메인 문서
- [core/utils/README.md](../../../core/utils/README.md) - Logger 클래스 상세
- [app/router/navigation/nav.dart](../../router/navigation/nav.dart) - 라우트 등록

---

**마지막 업데이트**: 2025-11-10
**작성자**: Claude Code
**문서 버전**: 1.0.0
**kDebugMode**: ✅ Release 빌드 안전
