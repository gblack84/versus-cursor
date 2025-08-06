# Utils Directory

## 개요 (Overview)
이 디렉토리는 공통으로 사용되는 유틸리티 함수와 도구들을 포함합니다. 특정 도메인에 속하지 않는 범용적인 기능들이 위치합니다.

## 파일 설명 (File Descriptions)

### debug_helper.dart
- **역할**: 디버깅을 위한 유틸리티 함수 모음
- **주요 기능**:
  - 조건부 디버그 로그 출력
  - 태그 기반 로깅 시스템
  - 로그 레벨 지원 (DEBUG, INFO, WARNING, ERROR)
  - 영구 중복 방지 로깅 (v2.0.0 추가)
  - 프로덕션에서 자동 비활성화
- **주요 메서드**:
  ```dart
  // 기본 로깅 메서드
  static void log(String message, {String? tag})
  static void debug(String message, {String? tag})
  static void info(String message, {String? tag})
  static void warning(String message, {String? tag})
  static void error(String message, {dynamic error, String? tag})
  
  // 영구 중복 방지 로깅 (v2.0.0 신규)
  static void logOnce(String logId, String message, {String? tag, LogLevel level})
  
  // 특화 로깅 메서드
  static void logError(String message, dynamic error)
  static void logImageSelection(String message)
  static void logLayout(String message)
  static void logFirebase(String message)
  static void logVote(String message, {LogLevel level})
  
  // 유틸리티 메서드
  static void runInDebug(Function callback)
  static String maskData(dynamic data)
  static String maskSensitive(String value, {int visibleChars})
  ```
- **사용 예시**:
  ```dart
  // 일반 로깅
  DebugHelper.log('이미지 업로드 시작', tag: 'UPLOAD');
  
  // 중복 방지 로깅 (세션 동안 한 번만 출력)
  DebugHelper.logOnce(
    'img_${imageId}',
    '이미지 처리: $imageId',
    tag: 'ImageProcessor'
  );
  
  // 레벨별 로깅
  DebugHelper.info('정보성 메시지');
  DebugHelper.warning('경고 메시지');
  DebugHelper.error('에러 발생', error: exception);
  
  // 개발 모드 전용 실행
  DebugHelper.runInDebug(() {
    print('개발 모드에서만 실행됨');
  });
  ```

### error_handler.dart
- **역할**: 중앙 집중식 에러 처리
- **주요 기능**:
  - 에러 타입별 분류
  - 사용자 친화적 메시지 변환
  - 에러 로깅 및 보고
- **에러 타입**:
  - 네트워크 에러
  - 권한 에러
  - 검증 에러
  - 일반 에러
- **주요 메서드**:
  ```dart
  static Future<T?> tryAsync<T>(Future<T> Function() operation)
  static T? trySync<T>(T Function() operation)
  static String getUserMessage(dynamic error)
  static void showErrorToast(dynamic error)
  ```

### no_animation_page_route.dart
- **역할**: 애니메이션 없는 페이지 전환
- **주요 기능**:
  - 즉시 페이지 전환
  - 특정 상황에서 부드러운 UX 제공
- **사용처**:
  - 모달에서 페이지로 전환
  - 빠른 네비게이션 필요 시
- **사용 예시**:
  ```dart
  Navigator.push(
    context,
    NoAnimationPageRoute(
      builder: (context) => NextPage(),
    ),
  );
  ```

## 유틸리티 설계 원칙

### 1. 순수 함수
- 부작용 없는 함수 작성
- 입력에 대해 예측 가능한 출력
- 테스트 용이성

### 2. 재사용성
- 특정 기능에 종속되지 않음
- 범용적으로 사용 가능
- 명확한 인터페이스

### 3. 성능 최적화
- 불필요한 연산 최소화
- 메모이제이션 활용
- 효율적인 알고리즘

## 일반적인 유틸리티 패턴

### 날짜/시간 처리
```dart
class DateUtils {
  static String formatRelativeTime(DateTime date) {
    // "5분 전", "어제" 등으로 변환
  }
  
  static bool isSameDay(DateTime a, DateTime b) {
    // 같은 날인지 확인
  }
}
```

### 문자열 처리
```dart
class StringUtils {
  static String truncate(String text, int maxLength) {
    // 텍스트 자르기 + "..." 추가
  }
  
  static bool isValidEmail(String email) {
    // 이메일 형식 검증
  }
}
```

### 파일 처리
```dart
class FileUtils {
  static String getFileExtension(String path) {
    // 파일 확장자 추출
  }
  
  static String formatFileSize(int bytes) {
    // "1.5 MB" 형식으로 변환
  }
}
```

## 디버깅 가이드

### DebugHelper 활용
1. **태그 시스템**:
   ```dart
   // 기능별 태그 사용
   DebugHelper.log('시작', tag: 'IMAGE_UPLOAD');
   DebugHelper.log('완료', tag: 'IMAGE_UPLOAD');
   ```

2. **중복 방지 로깅 (v2.0.0)**:
   ```dart
   // 문서별 로깅 - 같은 문서는 한 번만 로깅
   DebugHelper.logOnce(
     'doc_${doc.id}',
     '문서 처리: ${doc.id}',
     tag: 'FirebaseListener'
   );
   
   // 이미지별 로깅 - 같은 이미지는 한 번만 로깅
   DebugHelper.logOnce(
     'img_${url.hashCode}',
     '이미지 로드: $url',
     tag: 'ImageLoader'
   );
   ```

3. **조건부 실행**:
   ```dart
   DebugHelper.runInDebug(() {
     // 무거운 디버그 작업
     _analyzeImageData();
   });
   ```

### ErrorHandler 활용
1. **안전한 비동기 처리**:
   ```dart
   final result = await ErrorHandler.tryAsync(() async {
     return await riskyOperation();
   });
   ```

2. **에러 분류**:
   ```dart
   try {
     await someOperation();
   } catch (e) {
     final message = ErrorHandler.getUserMessage(e);
     showToast(message);
   }
   ```

## 성능 고려사항

1. **로깅 오버헤드**:
   - 프로덕션에서 자동 비활성화
   - 과도한 로깅 피하기

2. **에러 처리 비용**:
   - try-catch 남용 주의
   - 예상 가능한 에러는 사전 검증

3. **메모리 사용**:
   - 대용량 데이터 처리 시 스트림 활용
   - 불필요한 객체 생성 최소화

## 확장 제안

### 추가 유틸리티
1. **ValidationUtils**:
   - 공통 검증 로직
   - 정규식 패턴 모음

2. **CacheUtils**:
   - 메모리 캐시 관리
   - 만료 시간 처리

3. **PlatformUtils**:
   - 플랫폼별 분기 처리
   - 디바이스 정보 추출

### 테스트 유틸리티
```dart
class TestUtils {
  static Future<void> pumpAndSettle(WidgetTester tester) {
    // 공통 테스트 헬퍼
  }
  
  static Widget wrapWithProviders(Widget child) {
    // 테스트용 Provider 래핑
  }
}
```

## 주의사항

1. **의존성 최소화**:
   - 외부 패키지 의존 주의
   - 순수 Dart 코드 선호

2. **네이밍 일관성**:
   - 명확한 함수명
   - 파라미터 설명 주석

3. **문서화**:
   - 복잡한 로직은 주석 필수
   - 사용 예시 제공