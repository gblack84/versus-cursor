# 🌐 Backend API 통합 레이어

> Versus Space 앱의 외부 API 통합 및 HTTP 통신 관리 모듈  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Backend API 디렉토리는 모든 외부 API 통신과 HTTP 요청을 관리하는 중앙 집중식 레이어입니다. REST API 호출, 스트리밍 응답, 비디오 인코딩 서비스 등을 포함합니다.

## 🏗️ 현재 구조

```
/lib/backend/api/
├── algolia/                  # 🟡 비어있음 (실제 구현은 features/search에)
└── rest/                      # ✅ REST API 통합
    ├── api_calls.dart         # ✅ 구체적 API 호출 구현
    ├── api_manager.dart       # ✅ HTTP 요청 매니저
    └── get_streamed_response.dart  # ✅ 스트림 응답 처리
```

## 📊 구현 상태

| 컴포넌트 | 상태 | 파일 | 문제점 |
|---------|------|------|--------|
| **API Manager** | 🟢 구현됨 | api_manager.dart | 싱글톤 패턴, 테스트 어려움 |
| **Encoder API** | 🟢 구현됨 | api_calls.dart | 하드코딩된 URL |
| **Search API** | 🟡 부분적 | api_calls.dart | API 키 하드코딩, 예제 코드 |
| **Stream Handler** | 🟢 구현됨 | get_streamed_response.dart | 매우 단순함 |
| **Algolia 통합** | 🔴 미구현 | algolia/ | 디렉토리만 존재 |

## 🔄 API Manager 시스템

### 핵심 기능

```dart
class ApiManager {
  // 싱글톤 패턴
  static ApiManager? _instance;
  static ApiManager get instance => _instance ??= ApiManager._();
  
  // 캐싱 시스템
  static Map<ApiCallOptions, ApiCallResponse> _apiCache = {};
  
  // 인증 토큰
  static String? _accessToken;
}
```

### 지원되는 기능

#### 1. HTTP 메서드 지원
- GET, POST, PUT, PATCH, DELETE
- Multipart/form-data 업로드
- 스트리밍 응답 처리

#### 2. 요청 타입
```dart
enum BodyType {
  NONE,
  JSON,
  TEXT,
  X_WWW_FORM_URL_ENCODED,
  MULTIPART,
}
```

#### 3. 캐싱 시스템
- 동일한 요청에 대한 자동 캐싱
- `clearCache(callName)` 메서드로 캐시 무효화
- 세션 기반 메모리 캐시

#### 4. 응답 처리
```dart
class ApiCallResponse {
  final dynamic jsonBody;
  final Map<String, String> headers;
  final int statusCode;
  
  bool get succeeded => statusCode >= 200 && statusCode < 300;
}
```

## 🎬 Encoder API 통합

### 목적
비디오 파일 인코딩 및 썸네일 생성을 위한 외부 서비스 통합

### 엔드포인트
```dart
// Base URL
'https://encoder-636984750551.asia-northeast3.run.app'

// Endpoints
'/generate-upload-url' // 업로드 URL 생성
'/encode'              // 인코딩 요청
```

### 사용 예시
```dart
// 1. 업로드 URL 획득
final uploadUrlResponse = await EncoderGroup.getUploadUrlCall.call(
  fileName: 'video.mp4',
  contentType: 'video/mp4',
);

// 2. 인코딩 요청
final encodingResponse = await EncoderGroup.requestEncodingCall.call(
  gcsPath: 'path/to/video',
  thumbUrl: 'thumbnail_url',
  postId: 'post_123',
  ownerUid: 'user_456',
);
```

## 🔍 Algolia 검색 API

### 현재 문제점
1. **하드코딩된 API 키**: 보안 위험
2. **예제 쿼리**: "검색어" 하드코딩
3. **잘못된 위치**: features/search에 실제 구현

### 개선 필요
```dart
// 현재 (❌ 나쁨)
class SearchAlgoliaCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
    {
      "query": "검색어"  // 하드코딩된 예제
    }''';
    // API 키 하드코딩
    'X-Algolia-API-Key': '123e265bbab0702b220a66a59f22ab8e',
```

## 🚨 주요 문제점

### 1. 아키텍처 문제
- **싱글톤 패턴**: 테스트 어려움, 상태 관리 복잡
- **직접 의존성**: DI 패턴 미사용
- **계층 혼재**: API 호출과 비즈니스 로직 혼재

### 2. 보안 문제
- **API 키 노출**: 소스 코드에 하드코딩
- **URL 하드코딩**: 환경별 설정 불가
- **인증 토큰 관리**: 전역 변수로 관리

### 3. 코드 품질
- **테스트 부재**: 단위 테스트 0%
- **에러 처리**: 기본적인 try-catch만 존재
- **타입 안전성**: dynamic 타입 과다 사용

## 🎯 Feature-First Architecture 관점

### 현재 구조 문제
```
/lib/backend/api/rest/api_calls.dart
└── 구체적인 API 호출이 Backend에 직접 구현됨
```

### 올바른 구조
```
/lib/backend/api/
├── clients/              # API 클라이언트 추상화
│   ├── i_http_client.dart
│   └── http_client_impl.dart
├── config/               # 환경 설정
│   ├── api_config.dart
│   └── environment.dart
└── interceptors/         # 요청/응답 인터셉터
    ├── auth_interceptor.dart
    └── logging_interceptor.dart

/lib/features/encoder/data/datasources/
└── encoder_remote_datasource.dart  # Encoder 관련 API 호출

/lib/features/search/data/datasources/
└── search_remote_datasource.dart   # Search 관련 API 호출
```

## 🔧 사용 방법

### 기본 API 호출
```dart
final response = await ApiManager.instance.makeApiCall(
  callName: 'MyAPI',
  apiUrl: 'https://api.example.com/endpoint',
  callType: ApiCallType.POST,
  headers: {'Content-Type': 'application/json'},
  params: {'key': 'value'},
  body: jsonEncode({'data': 'value'}),
  bodyType: BodyType.JSON,
  returnBody: true,
  cache: true,
);

if (response.succeeded) {
  final data = response.jsonBody;
  // 처리 로직
}
```

### 파일 업로드
```dart
final response = await ApiManager.instance.makeApiCall(
  callName: 'FileUpload',
  apiUrl: 'https://api.example.com/upload',
  callType: ApiCallType.POST,
  params: {
    'file': AppUploadedFile(
      bytes: fileBytes,
      name: 'image.jpg',
    ),
  },
  bodyType: BodyType.MULTIPART,
);
```

### 스트리밍 응답
```dart
final response = await ApiManager.instance.makeApiCall(
  callName: 'StreamAPI',
  apiUrl: 'https://api.example.com/stream',
  callType: ApiCallType.GET,
  isStreamingApi: true,
);

// response.streamedResponse 사용
```

## 📈 메트릭

| 지표 | 현재 | 목표 |
|-----|------|------|
| **테스트 커버리지** | 0% | 80% |
| **타입 안전성** | 60% | 95% |
| **코드 재사용성** | 낮음 | 높음 |
| **보안 수준** | 낮음 | 높음 |
| **문서화** | 30% | 100% |

## 🔗 관련 문서

- [마이그레이션 계획](./MIGRATION_Part3.md)
- [테스트 가이드](./TEST.md)
- [Backend 전체 구조](/lib/backend/README.md)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)

## 📝 사용처 분석

### EncoderGroup
- 비디오 업로드 플로우
- 썸네일 생성
- 비디오 편집 기능

### SearchAlgoliaCall
- 검색 기능 (실제로는 features/search에서 구현)
- 자동완성
- 검색 결과 표시

### ApiManager
- 모든 외부 API 통신
- Firebase Functions 호출
- 서드파티 서비스 통합

## ⚠️ 주의사항

1. **API 키 관리**: 환경 변수로 이동 필요
2. **에러 처리**: 체계적인 에러 처리 시스템 필요
3. **테스트**: Mock 클라이언트 구현 필요
4. **캐싱**: 만료 정책 필요
5. **인증**: Bearer 토큰 자동 갱신 메커니즘 필요

---

*이 문서는 Backend API 레이어의 현재 상태와 개선 방향을 설명합니다.*  
*Feature-First Architecture 마이그레이션이 필요한 상태입니다.*