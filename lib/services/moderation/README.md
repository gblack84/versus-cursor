# 📝 Moderation Service 레이어

> 애플리케이션 전역 콘텐츠 검열 서비스  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Moderation Service는 Versus Space 애플리케이션의 **전역 인프라 서비스**로서, 모든 Feature에서 사용하는 콘텐츠 검열 기능을 제공합니다. 텍스트와 이미지의 부적절한 콘텐츠를 감지하고 필터링하는 3단계 검증 시스템을 구현합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/moderation/
├── cloud_image_moderation_service.dart  # 189줄 - Cloud Vision API 통합
├── image_moderation_service.dart        # 123줄 - 이미지 검열 서비스
└── perspective_api_service.dart         # 297줄 - Google Perspective API 텍스트 검열
```

## 🔍 현재 코드 분석

### 1. cloud_image_moderation_service.dart (189줄)

#### 핵심 구성요소

**CloudImageModerationService (싱글톤)**
```dart
class CloudImageModerationService {
  // 이미지 파일 경로로 검열 상태 확인
  static Future<ImageModerationModel?> checkModerationStatus(String filePath)
  
  // 검열 결과를 기다리는 함수 (최대 30초)
  static Future<ImageModerationModel?> waitForModeration(String filePath)
  
  // 검열 상태를 실시간으로 감시하는 스트림
  static Stream<ImageModerationModel?> watchModerationStatus(String filePath)
  
  // SafeSearch 결과 판단 함수들
  static bool isImageSafe(ImageModerationModel? moderation)
  static bool isImageRejected(ImageModerationModel? moderation)
  static bool isModerationPending(ImageModerationModel? moderation)
  static bool hasError(ImageModerationModel? moderation)
}
```

#### 주요 기능
- **Firestore 통합**: imageModeration 컬렉션에서 검열 결과 관리
- **실시간 모니터링**: Stream을 통한 검열 상태 실시간 감시
- **폴링 메커니즘**: 30초 타임아웃으로 검열 결과 대기
- **SafeSearch 결과 해석**: Cloud Vision API 결과를 한국어로 변환
- **URL 파싱**: Firebase Storage URL에서 파일 경로 추출

### 2. image_moderation_service.dart (123줄)

#### 핵심 구성요소

**ImageModerationService**
```dart
class ImageModerationService {
  // 단일 이미지 검열
  static Future<ModerationResult> checkImage({
    required File imageFile,
    required String box,
  })
  
  // 여러 이미지 검열
  static Future<List<ModerationResult>> checkMultipleImages({
    required List<File> imageFiles,
    required String box,
    Function(int current, int total)? onProgress,
  })
  
  // 검열용 이미지 리사이즈 (최대 800px)
  static Future<Uint8List> _resizeImageForModeration(File imageFile)
}

// 검열 결과 모델
class ModerationResult {
  final bool isAppropriate;  // 적절한 콘텐츠 여부
  final String reason;        // 거부 사유
  final bool hasText;        // 텍스트 포함 여부
}
```

#### 주요 기능
- **Cloud Functions 호출**: checkImageContent 함수 호출 (asia-northeast3)
- **이미지 최적화**: 800px로 리사이즈하여 성능 향상
- **Base64 인코딩**: 이미지를 base64로 변환하여 전송
- **진행률 콜백**: 여러 이미지 처리 시 진행률 제공
- **JPEG 압축**: 70% 품질로 압축하여 크기 최적화

### 3. perspective_api_service.dart (297줄)

#### 핵심 구성요소

**PerspectiveApiService**
```dart
class PerspectiveApiService {
  // 텍스트 독성 분석
  static Future<PerspectiveResult> analyzeText(String text)
  
  // 여러 텍스트 필드를 한 번에 분석
  static Future<Map<String, PerspectiveResult>> analyzeMultipleTexts(
    Map<String, String> texts
  )
  
  // 텍스트 검증 (TextFormField용)
  static Future<String?> validateText(String? value)
  
  // API 상태 테스트
  static Future<bool> testConnection()
}

// 분석 결과 모델
class PerspectiveResult {
  final bool isToxic;
  final double toxicityScore;
  final double profanityScore;
  final double threatScore;
  final double insultScore;
  final Map<String, double> allScores;
  final List<ToxicSpan> toxicSpans;  // 독성 텍스트 위치
}
```

#### 주요 기능
- **다국어 지원**: 한국어, 영어 독성 감지
- **다중 속성 분석**: TOXICITY, PROFANITY, THREAT, INSULT 등
- **독성 단어 감지**: 정규식 패턴으로 한국어/영어 욕설 감지
- **위치 정보 제공**: 독성 텍스트의 위치와 점수 반환
- **Rate Limiting 방지**: API 호출 간 100ms 간격 유지

## ⚠️ 현재 문제점 종합

### 1. 아키텍처 문제
- **정적 메서드 남용**: 모든 서비스가 static 메서드로 구현
- **의존성 주입 불가**: 테스트와 모킹이 어려움
- **인터페이스 부재**: 추상화 레벨이 없어 확장성 제한

### 2. 보안 문제
- **API 키 노출**: perspective_api_service.dart에 하드코딩된 API 키
  ```dart
  static const String _apiKey = 'AIzaSyAq1pADTpUpThb1lFKL1Ilrenr8X4IlP_E';
  ```
- **키 관리 부재**: 환경 변수나 보안 저장소 미사용

### 3. 에러 처리 문제
- **일관성 없는 에러 처리**: 서비스마다 다른 에러 처리 방식
- **에러 로깅 부족**: print문만 사용, 구조화된 로깅 없음
- **실패 시 기본값**: 검열 실패 시 통과로 처리 (위험!)

### 4. 성능 문제
- **동기적 처리**: 여러 이미지/텍스트 순차 처리로 느림
- **캐싱 없음**: 동일한 콘텐츠 반복 검사
- **리소스 관리 부족**: 메모리나 네트워크 사용 최적화 없음

## 🎯 Services Layer 유지 필요성

### 왜 Services Layer에 있어야 하는가?

1. **전역 서비스 특성**
   - 모든 Feature(posts, chat, comments)에서 공통 사용
   - 중앙 집중식 검열 정책 관리
   - 일관된 콘텐츠 검증 보장

2. **인프라 레벨 기능**
   - 애플리케이션 보안의 핵심 요소
   - Feature 독립성 보장
   - 외부 API 통합 관리

3. **크로스커팅 관심사**
   - 여러 Feature에 걸친 공통 기능
   - 단일 책임 원칙 준수
   - 중복 코드 방지

### Feature-First Architecture 준수

```
✅ 올바른 의존성:
Features (posts, chat, profile...)
    ↓ 사용
Services (moderation, cache, logger...)
    ↓ 사용
Backend (firebase, models...)

❌ 잘못된 접근:
- Moderation을 Feature로 이동
- Feature별 검열 중복 구현
- Services가 Feature 모델 직접 import
```

## 💡 주요 개선 제안

### 1. 의존성 주입 패턴 적용
```dart
// 인터페이스 정의
abstract class IModerationService {
  Future<ModerationResult> checkContent(String content);
}

// DI 컨테이너 등록
getIt.registerSingleton<IModerationService>(
  ModerationServiceImpl(
    perspectiveApi: getIt(),
    cloudVision: getIt(),
  )
);
```

### 2. API 키 보안 관리
```dart
// 환경 변수 사용
class ApiKeys {
  static String get perspectiveApiKey => 
    const String.fromEnvironment('PERSPECTIVE_API_KEY');
}
```

### 3. 병렬 처리 최적화
```dart
// 여러 콘텐츠 병렬 검사
Future<List<ModerationResult>> checkMultiple(List<String> contents) {
  return Future.wait(
    contents.map((content) => checkContent(content))
  );
}
```

### 4. 캐싱 시스템 추가
```dart
class ModerationCache {
  final _cache = <String, ModerationResult>{};
  
  Future<ModerationResult> getOrCheck(String content) async {
    final hash = content.hashCode.toString();
    return _cache[hash] ??= await _checkContent(content);
  }
}
```

## 🔗 연관 시스템

### 사용처 (Features)
- **posts**: 게시물 제목, 본문, 이미지 검열
- **chat**: 메시지 및 미디어 필터링
- **comments**: 댓글 내용 검열
- **profile**: 프로필 정보 검증

### 의존성 (Backend/External)
- Firebase Functions: checkImageContent
- Google Cloud Vision API: SafeSearch
- Google Perspective API: 텍스트 독성 분석
- Firestore: imageModeration 컬렉션

### 통합 대상
- **Cache Service**: 검열 결과 캐싱
- **Logger Service**: 구조화된 로깅
- **Content Filter**: 한국어 욕설 필터와 통합

## 📊 메트릭스

### 현재 성능
- 텍스트 검열: ~500ms (API 호출)
- 이미지 검열: ~2-3초 (리사이즈 + API)
- 배치 처리: O(n) 순차 처리
- 캐시 히트율: 0% (캐싱 없음)

### 개선 목표
- 텍스트 검열: <200ms (캐싱 활용)
- 이미지 검열: <1초 (병렬 처리)
- 배치 처리: O(1) 병렬 처리
- 캐시 히트율: >60%

## 📝 다음 단계

### Phase 1: 보안 강화 (긴급)
```dart
// API 키 환경 변수로 이동
// 민감 정보 제거
// 보안 설정 문서화
```

### Phase 2: 아키텍처 개선 (1주)
```dart
// 인터페이스 정의
// DI 패턴 적용
// 단위 테스트 추가
```

### Phase 3: 성능 최적화 (2주)
```dart
// 병렬 처리 구현
// 캐싱 시스템 추가
// 메트릭 수집
```

### Phase 4: 통합 개선 (2주)
```dart
// Content Filter와 통합
// 구조화된 로깅
// 모니터링 대시보드
```

## ⚠️ 주의사항

1. **Services Layer 유지**: Feature로 이동하지 말 것
2. **API 키 보안**: 절대 소스 코드에 하드코딩 금지
3. **실패 처리**: 검열 실패 시 차단이 기본값이어야 함
4. **Rate Limiting**: API 호출 제한 준수

## 🏆 품질 목표

### 코드 품질
- 테스트 커버리지: 80% 이상
- 정적 분석 경고: 0개
- 문서화: 모든 public API

### 성능 목표
- 응답 시간: P95 < 1초
- 동시 처리: 100개 콘텐츠 병렬
- 메모리: < 10MB

### 신뢰성 목표
- 가용성: 99.9%
- 오탐율: < 5%
- 미탐율: < 1%

## 📚 참고 자료

- [Google Perspective API](https://perspectiveapi.com)
- [Google Cloud Vision API](https://cloud.google.com/vision)
- [Firebase Functions](https://firebase.google.com/docs/functions)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)

---

*이 문서는 Versus Space Moderation Service의 구조와 사용법을 설명합니다.*  
*Services Layer는 전역 인프라로 유지되어야 합니다.*