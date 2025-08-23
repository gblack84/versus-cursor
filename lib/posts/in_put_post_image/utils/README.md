# 🛠️ InPutPostImage Utils 디렉토리

> 이미지 게시물 작성 모듈에서 사용되는 공통 유틸리티 클래스 모음

## 🎯 개요

이 디렉토리는 이미지 게시물 작성(`in_put_post_image`) 모듈 전반에서 사용되는 범용 유틸리티 클래스들을 포함합니다. 디버깅, 에러 처리, 네비게이션 등 공통 기능을 제공하여 코드 재사용성과 유지보수성을 향상시킵니다.

### 주요 특징
- 🔍 **중앙 집중식 로깅 시스템** - 태그 기반, 레벨별 로깅
- 🛡️ **통합 에러 처리** - 타입별 분류 및 사용자 친화적 메시지
- ⚡ **성능 최적화** - 프로덕션 빌드 자동 최적화
- 🎨 **일관된 UI/UX** - 통일된 토스트 메시지 및 페이지 전환

## 📐 네이밍 컨벤션

| 구분 | 규칙 | 예시 |
|------|------|------|
| **파일명** | snake_case | `debug_helper.dart` |
| **클래스명** | PascalCase | `DebugHelper` |
| **메서드명** | camelCase | `logError()` |
| **상수** | UPPER_SNAKE_CASE | `LOG_LEVEL` |
| **변수명** | camelCase | `minimumLevel` |

> 상세 규칙은 [프로젝트 네이밍 컨벤션](../../../NAMING_CONVENTION.md) 참조

## 📁 디렉토리 구조

```
utils/
├── debug_helper.dart       # 디버깅 및 로깅 유틸리티
├── error_handler.dart      # 중앙 집중식 에러 처리
├── no_animation_page_route.dart  # 애니메이션 없는 페이지 전환
└── README.md              # 현재 문서
```

## 🔧 주요 구성요소

### 1. DebugHelper (`debug_helper.dart`)

#### 개요
프로덕션과 개발 환경을 구분하여 효율적인 로깅을 제공하는 유틸리티 클래스입니다.

#### 주요 기능
- **레벨별 로깅**: DEBUG, INFO, WARNING, ERROR
- **태그 기반 필터링**: 기능별 로그 분류
- **중복 방지 로깅**: 세션 동안 같은 로그 한 번만 출력
- **자동 환경 감지**: 릴리즈 빌드에서 자동 비활성화
- **민감 정보 마스킹**: 개인정보 보호

#### 로그 레벨 체계
```dart
enum LogLevel {
  DEBUG,    // 🔍 상세 디버깅 정보
  INFO,     // ℹ️ 일반 정보
  WARNING,  // ⚠️ 경고 메시지
  ERROR,    // ❌ 에러 정보
}
```

#### 핵심 메서드

##### 기본 로깅
```dart
// 레벨별 로깅
DebugHelper.debug('디버그 메시지');
DebugHelper.info('정보 메시지');
DebugHelper.warning('경고 메시지');
DebugHelper.error('에러 메시지', error: exception);

// 태그 사용
DebugHelper.log('이미지 업로드 시작', tag: 'Upload');
```

##### 중복 방지 로깅
```dart
// 세션 동안 한 번만 출력
DebugHelper.logOnce(
  'user_${userId}',  // 고유 ID
  '사용자 정보 로드: $userId',
  tag: 'UserService',
  level: LogLevel.INFO,
);
```

##### 특화 로깅 메서드
```dart
// 도메인별 특화 로깅
DebugHelper.logLayout('레이아웃 변경: horizontal');
DebugHelper.logUpload('파일 업로드: image.jpg');
DebugHelper.logImageSelection('이미지 3개 선택');
DebugHelper.logModeration('검열 통과');
DebugHelper.logApi('API 호출: /posts');
DebugHelper.logFirebase('Firestore 쓰기');
DebugHelper.logVote('투표 완료', level: LogLevel.INFO);
```

##### 유틸리티 메서드
```dart
// 디버그 모드에서만 실행
DebugHelper.runInDebug(() {
  print('개발 환경에서만 실행되는 코드');
});

// 데이터 마스킹
String masked = DebugHelper.maskSensitive('1234567890', visibleChars: 3);
// 결과: "123....890"

// 대용량 데이터 요약
String summary = DebugHelper.maskData(largeMap);
// 결과: "Map(150 items)"
```

#### 메모리 관리
- 로그 ID 10,000개 초과 시 자동 정리
- 오래된 5,000개 제거 후 계속 진행
- 메모리 누수 방지

### 2. ErrorHandler (`error_handler.dart`)

#### 개요
애플리케이션 전체의 에러를 중앙에서 처리하고 사용자에게 적절한 피드백을 제공합니다.

#### 에러 타입 분류
```dart
enum ErrorType {
  network,          // 네트워크 연결 문제
  storage,          // 저장 공간 부족
  validation,       // 입력값 검증 실패
  permission,       // 권한 없음
  imageProcessing,  // 이미지 처리 실패
  moderation,       // 콘텐츠 검열 실패
  unknown,          // 알 수 없는 에러
}
```

#### 핵심 메서드

##### 에러 처리
```dart
// 기본 에러 처리
ErrorHandlingResult result = ErrorHandler.handle(
  error,
  type: ErrorType.network,
  customMessage: '네트워크 연결을 확인해주세요',
  showToast: true,
  context: context,
);
```

##### 안전한 비동기 작업
```dart
// try-catch 자동 래핑
final data = await ErrorHandler.tryAsync<String>(
  () async {
    return await fetchData();
  },
  type: ErrorType.network,
  defaultValue: '',
  onError: (result) {
    print('에러 발생: ${result.userMessage}');
  },
);
```

##### 안전한 동기 작업
```dart
// 동기 작업 래핑
final value = ErrorHandler.trySync<int>(
  () {
    return int.parse(userInput);
  },
  type: ErrorType.validation,
  defaultValue: 0,
);
```

#### 에러 메시지 자동 변환
```dart
// Firebase 에러 → 한국어 메시지
'permission-denied' → '권한이 없습니다.'
'not-found' → '요청한 데이터를 찾을 수 없습니다.'
'quota-exceeded' → '할당량을 초과했습니다.'
```

#### Toast 메시지 표시
```dart
// 에러 토스트 (빨간색)
ErrorHandler.handle(error, showToast: true);

// 성공 토스트 (초록색)
ErrorHandler.showSuccessToast('업로드 완료!');
```

### 3. NoAnimationPageRoute (`no_animation_page_route.dart`)

#### 개요
애니메이션 없이 즉시 페이지를 전환하는 커스텀 라우트입니다.

#### 특징
- **전환 시간**: 0ms (즉시 전환)
- **역방향 전환**: 0ms
- **상태 유지**: maintainState = true
- **불투명**: opaque = true

#### 사용 예시
```dart
// 일반 페이지 전환
Navigator.push(
  context,
  NoAnimationPageRoute(
    builder: (context) => NextPage(),
  ),
);

// 라우트 설정과 함께
Navigator.push(
  context,
  NoAnimationPageRoute(
    builder: (context) => DetailPage(id: itemId),
    settings: RouteSettings(
      name: '/detail',
      arguments: {'id': itemId},
    ),
  ),
);
```

#### 사용 시나리오
- 모달 → 페이지 전환 시
- 탭 전환과 유사한 UX 필요 시
- 빠른 화면 전환이 필요한 경우
- 애니메이션이 UX를 해치는 경우

## 💡 사용 예시

### 통합 사용 예시
```dart
class ImageUploadService {
  Future<void> uploadImage(File imageFile) async {
    // 디버그 로깅
    DebugHelper.logUpload('업로드 시작: ${imageFile.path}');
    
    // 안전한 비동기 작업
    final result = await ErrorHandler.tryAsync(
      () async {
        // 중복 방지 로깅
        DebugHelper.logOnce(
          'file_${imageFile.hashCode}',
          '파일 처리 중: ${imageFile.path}',
          tag: 'Upload',
        );
        
        // 실제 업로드 로직
        final url = await _performUpload(imageFile);
        
        // 성공 로깅
        DebugHelper.info('업로드 성공', tag: 'Upload');
        
        return url;
      },
      type: ErrorType.network,
      customMessage: '이미지 업로드 실패',
      onError: (error) {
        // 에러 로깅
        DebugHelper.error('업로드 실패', error: error.originalError);
      },
    );
    
    if (result != null) {
      // 성공 피드백
      ErrorHandler.showSuccessToast('이미지 업로드 완료');
      
      // 페이지 전환 (애니메이션 없이)
      Navigator.push(
        context,
        NoAnimationPageRoute(
          builder: (_) => ImageDetailPage(url: result),
        ),
      );
    }
  }
}
```

## 🔄 변경 이력

### v2.1.0 (2025-07-13)
- DebugHelper에 `logOnce` 메서드 추가 (중복 로그 방지)
- ErrorHandler에 Firebase 에러 자동 변환 추가
- 메모리 관리 개선 (10,000개 제한)

### v2.0.0 (2025-07-08)
- 로그 레벨 시스템 도입
- 태그 기반 필터링 구현
- 민감 정보 마스킹 유틸리티 추가

### v1.1.0 (2025-07-07)
- ErrorHandler 클래스 추가
- Toast 메시지 통합
- 에러 타입 분류 시스템 구현

### v1.0.0 (2025-07-05)
- 초기 버전 릴리즈
- DebugHelper 기본 기능 구현
- NoAnimationPageRoute 추가

## 📊 성능 고려사항

### 로깅 성능
- **릴리즈 빌드**: 모든 로그 자동 비활성화 (0ms 오버헤드)
- **디버그 빌드**: 평균 <1ms per log
- **메모리 사용**: 최대 10,000개 로그 ID 캐싱

### 에러 처리 성능
- **try-catch 오버헤드**: ~0.1ms
- **Toast 표시**: ~10ms (UI 스레드)
- **스택 트레이스**: 디버그 모드에서만 수집

### 페이지 전환 성능
- **전환 시간**: 0ms (즉시)
- **메모리 사용**: 표준 MaterialPageRoute와 동일
- **CPU 사용**: 애니메이션 없어 더 낮음

## 🚀 향후 개선 계획

### 계획된 기능
1. **원격 로깅 지원**
   - Crashlytics 연동
   - 서버 로그 전송
   
2. **고급 에러 분석**
   - 에러 패턴 분석
   - 자동 복구 시도
   
3. **성능 모니터링**
   - 메서드 실행 시간 측정
   - 메모리 사용량 추적

### 제안 사항
- 로그 필터링 UI 구현
- 에러 리포트 생성 기능
- 커스텀 애니메이션 라우트 추가

## 📚 참고 자료

- [Flutter 디버깅 가이드](https://flutter.dev/docs/testing/debugging)
- [에러 처리 베스트 프랙티스](https://dart.dev/guides/language/effective-dart/usage#do-use-try-catch)
- [커스텀 라우트 구현](https://flutter.dev/docs/cookbook/animation/page-route-animation)

---

*이 문서는 InPutPostImage 모듈의 유틸리티 디렉토리를 설명합니다.*
*최종 업데이트: 2025-08-23*