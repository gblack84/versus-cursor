# 📋 Logger Service 레이어

> 애플리케이션 전역 로깅 시스템  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Logger Service는 Versus Space 애플리케이션의 전역 로깅 시스템을 담당하는 서비스 레이어입니다.
메모리 기반 순환 버퍼와 파일 기반 영구 저장소를 제공하여 디버깅과 모니터링을 지원합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/logger/
├── app_logger.dart      # 64줄 - 메모리 기반 로거
└── file_logger.dart     # 90줄 - 파일 기반 로거
```

## 🔍 현재 코드 분석

### app_logger.dart (64줄)

#### 핵심 구성요소

**1. AppLogger 싱글톤 클래스**
```dart
class AppLogger {
  static final List<String> _logs = [];        // 메모리 버퍼
  static const int _maxLogs = 1000;           // 최대 로그 개수
}
```

**2. 로깅 메서드**
- `logAction()`: 일반 액션 로깅
- `logNavigation()`: 네비게이션 추적
- `logButtonClick()`: UI 인터랙션 기록
- `logError()`: 에러 및 스택트레이스 기록

**3. 로그 조회 메서드**
- `getAllLogs()`: 모든 로그 반환
- `getRecentLogs()`: 최근 N개 로그 반환
- `clearLogs()`: 로그 버퍼 초기화

#### 주요 특징

1. **순환 버퍼 구조**: 1000개 초과 시 오래된 로그 자동 제거
2. **타임스탬프 자동 추가**: ISO 8601 형식
3. **구조화된 데이터**: Map 형태의 추가 데이터 지원
4. **디버그 모드 출력**: kDebugMode일 때만 콘솔 출력

### file_logger.dart (90줄)

#### 핵심 구성요소

**1. FileLogger 싱글톤 클래스**
```dart
class FileLogger {
  static File? _logFile;
  static const String _logFileName = 'app_debug.log';
}
```

**2. 파일 관리 메서드**
- `initialize()`: 로그 파일 초기화 및 크기 관리
- `log()`: 비동기 로그 작성
- `readAllLogs()`: 전체 로그 파일 읽기
- `clearLogs()`: 로그 파일 삭제 및 재생성

#### 주요 특징

1. **영구 저장**: Application Documents 디렉토리 사용
2. **자동 크기 관리**: 1MB 초과 시 자동 초기화
3. **비동기 I/O**: Future 기반 파일 작업
4. **에러 핸들링**: try-catch로 안전한 파일 작업

## 💡 주요 기능

### 1. 구조화된 로깅
```dart
// 액션 로깅 with 데이터
AppLogger.logAction('POST_CREATE', data: {
  'postId': 'abc123',
  'type': 'versus',
  'duration': 1500,
});

// 네비게이션 추적
AppLogger.logNavigation(from: '/home', to: '/profile');

// 에러 로깅 with 스택트레이스
AppLogger.logError('Network timeout', stackTrace: stackTrace);
```

### 2. 영구 저장
```dart
// 중요 이벤트 파일 저장
await FileLogger.log('Critical operation completed');

// 로그 파일 읽기
final logs = await FileLogger.readAllLogs();
```

### 3. 로그 관리
```dart
// 최근 50개 로그 조회
final recentLogs = AppLogger.getRecentLogs(50);

// 메모리 로그 초기화
AppLogger.clearLogs();

// 파일 로그 초기화
await FileLogger.clearLogs();
```

## 🔄 사용 시나리오

### 1. 사용자 플로우 추적
```dart
// 투표 생성 플로우
AppLogger.logAction('VOTE_CREATE_START');
AppLogger.logAction('IMAGE_SELECTED', data: {'count': 2});
AppLogger.logAction('AI_MODERATION', data: {'result': 'passed'});
AppLogger.logAction('VOTE_CREATED', data: {'voteId': 'xyz789'});
```

### 2. 성능 모니터링
```dart
final startTime = DateTime.now();
await heavyOperation();
final duration = DateTime.now().difference(startTime);

AppLogger.logAction('PERFORMANCE', data: {
  'operation': 'image_upload',
  'duration_ms': duration.inMilliseconds,
  'size_kb': fileSize,
});
```

### 3. 에러 추적
```dart
try {
  await firebaseOperation();
} catch (e, s) {
  AppLogger.logError('Firebase operation failed: $e', stackTrace: s);
  await FileLogger.log('CRITICAL: Firebase failure - $e');
}
```

### 4. 네비게이션 플로우
```dart
// GoRouter observer에서 사용
AppLogger.logNavigation(
  from: previousRoute.path,
  to: currentRoute.path,
);
```

## 🚨 현재 문제점

### 1. 통합 부재
- **문제**: AppLogger와 FileLogger가 독립적으로 동작
- **영향**: 일관성 없는 로깅 전략
- **해결**: 통합 LoggingService 필요

### 2. 로그 레벨 부재
- **문제**: Debug/Info/Warning/Error 구분 없음
- **영향**: 프로덕션에서 불필요한 로그
- **해결**: LogLevel enum 도입 필요

### 3. 필터링 기능 없음
- **문제**: 카테고리/레벨별 필터링 불가
- **영향**: 디버깅 시 노이즈 많음
- **해결**: LogFilter 시스템 필요

### 4. 성능 최적화 부족
- **문제**: 동기적 메모리 접근, 비효율적 파일 I/O
- **영향**: 고빈도 로깅 시 성능 저하
- **해결**: 배치 처리, 백그라운드 작업자 필요

## 📊 메트릭스

### 현재 성능
- 메모리 사용량: ~1MB (1000개 로그)
- 파일 크기 제한: 1MB
- 로그 추가 시간: <1ms (메모리), ~10ms (파일)
- 로그 조회 시간: <1ms (메모리), ~50ms (파일)

### 개선 목표
- 메모리 효율: 50% 감소 (압축 적용)
- 필터링 속도: <1ms (인덱싱)
- 배치 처리: 100개 로그/배치
- 검색 성능: O(log n) (이진 검색)

## 🔗 연관 시스템

### 사용처
- **Features**: 모든 Feature에서 로깅 사용
  - auth: 로그인/로그아웃 추적
  - chat: 메시지 전송/수신 기록
  - posts: 게시물 생성/수정/삭제 로깅
  - voting: 투표 제출/완료 추적
  - notifications: 알림 발송 성공/실패
- **Services**: 다른 서비스와 연동
  - cache: 캐시 히트/미스 통계
  - image: 이미지 처리 성능 추적
  - moderation: AI 검열 결과 로깅
- **Core**: 시스템 레벨 이벤트
  - navigation: 라우팅 변경 추적
  - theme: 테마 변경 기록
  - localization: 언어 변경 추적

### 의존성
- `path_provider: ^2.0.0`: 파일 시스템 접근
- `flutter/foundation.dart`: kDebugMode 플래그

### 통합 대상
- **원격 로깅**: Crashlytics, Sentry
- **분석 도구**: Firebase Analytics, Mixpanel
- **모니터링**: Performance Monitoring

## 🎯 Clean Architecture 마이그레이션 필요

### 현재 위치
```
/lib/services/logger/  # 전역 서비스 (유지)
├── app_logger.dart    # 단일 파일
└── file_logger.dart   # 단일 파일
```

### 목표 구조
```
/lib/services/logger/          # Services Layer 유지
  ├── domain/                  # 도메인 레이어
  │   ├── entities/           # LogEntry, LogLevel
  │   ├── usecases/           # LogAction, FilterLogs
  │   └── repositories/       # ILogRepository
  ├── data/                    # 데이터 레이어
  │   ├── services/           # LoggingService, RemoteLogger
  │   ├── datasources/        # MemoryDataSource, FileDataSource
  │   └── repositories/       # LogRepositoryImpl
  ├── presentation/            # 프레젠테이션 레이어
  │   ├── providers/          # LogProvider
  │   └── widgets/            # LogViewer, LogExporter
  └── utils/                   # 유틸리티
      ├── formatters/          # 로그 포맷터
      └── filters/             # 로그 필터
```

### 마이그레이션 이점
1. **Services Layer 유지**: 전역 서비스 역할 보존
2. **Clean Architecture**: 레이어별 책임 분리
3. **Features → Services**: 모든 Feature에서 사용 가능
4. **점진적 마이그레이션**: 기존 코드와 호환성 유지

## 📝 다음 단계

1. **통합 LoggingService 구현**
   - AppLogger와 FileLogger 통합
   - 로그 레벨 시스템 도입
   - 카테고리별 필터링 추가

2. **성능 최적화**
   - 배치 처리 구현
   - 백그라운드 작업자 추가
   - 메모리 압축 알고리즘 적용

3. **원격 로깅 통합**
   - Crashlytics 연동
   - Sentry 통합
   - 커스텀 백엔드 지원

4. **개발자 도구**
   - LogViewer UI 컴포넌트
   - 로그 내보내기 기능
   - 실시간 로그 스트리밍

## 🔄 버전 이력

### v1.0.0 (2025-08)
- AppLogger 메모리 기반 로거 구현
- FileLogger 파일 기반 로거 구현
- 기본 로깅 기능 제공

### v1.1.0 (계획)
- 통합 LoggingService
- 로그 레벨 시스템
- 필터링 기능

### v2.0.0 (계획)
- Clean Architecture 적용
- 원격 로깅 통합
- 개발자 도구 추가

## ⚠️ 주의사항

1. **메모리 관리**: 1000개 제한으로 메모리 오버플로우 방지
2. **파일 크기**: 1MB 제한으로 디스크 공간 관리
3. **성능 영향**: 고빈도 로깅 시 성능 모니터링 필요
4. **프라이버시**: 민감 정보 로깅 금지 (개인정보, 비밀번호 등)

## 📚 참고 자료

- [Flutter Logging Best Practices](https://flutter.dev/docs/testing/errors)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Effective Logging Strategies](https://www.loggly.com/blog/logging-best-practices/)