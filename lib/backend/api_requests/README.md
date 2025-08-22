# API Requests

Versus Space 앱의 HTTP API 요청 관리 및 외부 서비스 통합을 담당하는 모듈입니다.

## 📋 개요

이 디렉토리는 모든 외부 API 호출을 관리하며, 비디오 인코딩 서비스, Algolia 검색, 그리고 기타 RESTful API 통합을 처리합니다. 강력한 캐싱, 에러 처리, 스트리밍 지원을 포함한 포괄적인 HTTP 클라이언트 구현을 제공합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- **enum**: PascalCase (멤버는 UPPER_CASE)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/api_requests/
├── README.md                    # 이 문서
├── api_calls.dart              # API 호출 정의 및 그룹화
├── api_manager.dart            # HTTP 클라이언트 매니저 (싱글톤)
└── get_streamed_response.dart  # 스트리밍 응답 처리 유틸리티
```

## 🔧 주요 구성요소

### 1. ApiManager (`api_manager.dart`)

앱의 모든 HTTP 요청을 관리하는 싱글톤 매니저 클래스입니다.

**핵심 기능:**
- 싱글톤 패턴으로 단일 인스턴스 관리
- 모든 HTTP 메서드 지원 (GET, POST, PUT, PATCH, DELETE)
- 다양한 바디 타입 지원 (JSON, TEXT, Form URL Encoded, Multipart)
- 자동 캐싱 메커니즘
- 스트리밍 API 지원
- Bearer 토큰 인증 지원

**주요 메서드:**
```dart
Future<ApiCallResponse> makeApiCall({
  required String callName,
  required String apiUrl,
  required ApiCallType callType,
  Map<String, dynamic> headers,
  Map<String, dynamic> params,
  String? body,
  BodyType? bodyType,
  bool returnBody,
  bool encodeBodyUtf8,
  bool decodeUtf8,
  bool cache,
  bool isStreamingApi,
})
```

### 2. ApiCallOptions (`api_manager.dart`)

API 호출 옵션을 캡슐화하는 불변(immutable) 클래스입니다.

**속성:**
- `callName`: API 호출 식별자
- `callType`: HTTP 메서드 (GET, POST, PUT, PATCH, DELETE)
- `apiUrl`: 요청 URL
- `headers`: HTTP 헤더
- `params`: 쿼리 파라미터
- `bodyType`: 요청 바디 타입
- `body`: 요청 바디 내용
- `returnBody`: 응답 바디 반환 여부
- `cache`: 캐싱 활성화 여부
- `isStreamingApi`: 스트리밍 API 여부

**특징:**
- Equatable 상속으로 값 기반 동등성 비교
- `copyWith` 메서드로 부분 수정 지원
- 캐시 키로 사용되어 중복 요청 방지

### 3. ApiCallResponse (`api_manager.dart`)

API 응답을 표준화된 형태로 래핑하는 클래스입니다.

**속성:**
- `jsonBody`: 파싱된 JSON 응답
- `headers`: 응답 헤더
- `statusCode`: HTTP 상태 코드
- `response`: 원본 HTTP Response
- `streamedResponse`: 스트리밍 응답 (해당 시)
- `exception`: 발생한 예외 (있을 경우)

**헬퍼 메서드:**
- `succeeded`: 2xx 상태 코드 확인
- `getHeader(name)`: 특정 헤더 값 가져오기
- `bodyText`: 원본 응답 텍스트
- `exceptionMessage`: 에러 메시지

### 4. EncoderGroup (`api_calls.dart`)

비디오 인코딩 서비스와의 통합을 관리하는 API 그룹입니다.

**Base URL:**
```dart
https://encoder-636984750551.asia-northeast3.run.app
```

#### GetUploadUrlCall
비디오 업로드를 위한 서명된 URL을 생성합니다.
```dart
Future<ApiCallResponse> call({
  String? fileName,
  String? contentType,
})
```
- Google Cloud Storage 서명된 URL 생성
- 업로드할 파일의 메타데이터 전송

#### RequestEncodingCall
비디오 인코딩 작업을 요청합니다.
```dart
Future<ApiCallResponse> call({
  String? gcsPath,      // GCS 경로
  String? thumbUrl,     // 썸네일 URL
  String? postId,       // 게시물 ID
  String? docId,        // 문서 ID
  String? ownerUid,     // 소유자 UID
  int? startMs,         // 시작 시간 (밀리초)
  int? endMs,          // 종료 시간 (밀리초)
})
```

### 5. SearchAlgoliaCall (`api_calls.dart`)

Algolia 검색 서비스 직접 호출을 위한 API 정의입니다.

**엔드포인트:**
```dart
https://0GAS0MPT9Z-dsn.algolia.net/1/indexes/jops_category/query
```

**특징:**
- Algolia API 키 헤더 설정
- JSON 형식 검색 쿼리
- jops_category 인덱스 검색

### 6. ApiPagingParams (`api_calls.dart`)

페이지네이션을 위한 파라미터 관리 클래스입니다.

**속성:**
- `nextPageNumber`: 다음 페이지 번호
- `numItems`: 현재까지 로드된 아이템 수
- `lastResponse`: 마지막 API 응답

### 7. Utility Functions

#### escapeStringForJson
JSON 문자열 이스케이프 처리:
```dart
String? escapeStringForJson(String? input)
```
- 백슬래시, 따옴표, 줄바꿈, 탭 문자 이스케이프
- null 안전 처리

#### HTTP Method Enums

**ApiCallType:**
- GET
- POST
- PUT
- PATCH
- DELETE

**BodyType:**
- NONE
- JSON
- TEXT
- X_WWW_FORM_URL_ENCODED
- MULTIPART

## 🔍 API 호출 플로우

### 기본 요청 플로우
```
1. API 호출 메서드 실행 (EncoderGroup, SearchAlgoliaCall 등)
    ↓
2. ApiManager.makeApiCall() 호출
    ↓
3. 캐시 확인 (cache=true인 경우)
    ↓ (캐시 미스)
4. HTTP 요청 생성 및 전송
    ↓
5. 응답 수신 및 파싱
    ↓
6. ApiCallResponse 객체 생성
    ↓
7. 캐시 저장 (해당 시) 및 결과 반환
```

### Multipart 업로드 플로우
```
1. 파일과 파라미터 준비
    ↓
2. AppUploadedFile 객체 생성
    ↓
3. multipartRequest() 호출
    ↓
4. MultipartFile 생성 및 전송
    ↓
5. 응답 처리
```

## 🚀 사용 예시

### 비디오 업로드 URL 생성
```dart
final response = await EncoderGroup.getUploadUrlCall.call(
  fileName: 'video.mp4',
  contentType: 'video/mp4',
);

if (response.succeeded) {
  final signedUrl = EncoderGroup.getUploadUrlCall.signedUrl(response.jsonBody);
  final gcsPath = EncoderGroup.getUploadUrlCall.gcsPath(response.jsonBody);
  // URL을 사용하여 파일 업로드
}
```

### 비디오 인코딩 요청
```dart
final response = await EncoderGroup.requestEncodingCall.call(
  gcsPath: 'videos/user123/video.mp4',
  thumbUrl: 'https://storage.../thumb.jpg',
  postId: 'post_456',
  docId: 'doc_789',
  ownerUid: 'user_123',
  startMs: 0,
  endMs: 30000, // 30초
);
```

### Algolia 검색
```dart
final response = await SearchAlgoliaCall.call();

if (response.succeeded) {
  final searchResults = response.jsonBody['hits'];
  // 검색 결과 처리
}
```

### 커스텀 API 호출
```dart
final response = await ApiManager.instance.makeApiCall(
  callName: 'customApi',
  apiUrl: 'https://api.example.com/data',
  callType: ApiCallType.POST,
  headers: {
    'Authorization': 'Bearer token123',
    'Content-Type': 'application/json',
  },
  params: {
    'filter': 'active',
    'limit': 10,
  },
  body: json.encode({
    'query': 'search term',
    'options': {'sort': 'date'},
  }),
  bodyType: BodyType.JSON,
  cache: true,
);
```

## ⚡ 성능 최적화

### 캐싱 전략
- ApiCallOptions를 키로 사용한 응답 캐싱
- 동일한 요청 중복 방지
- `clearCache(callName)`으로 선택적 캐시 무효화
- 세션 단위 메모리 캐시

### 스트리밍 지원
- 대용량 파일 다운로드/업로드
- 실시간 데이터 스트림
- 메모리 효율적인 처리

### 연결 재사용
- http.Client 인스턴스 재사용 옵션
- Keep-alive 연결 지원

## 🔒 보안 고려사항

### 인증 관리
- Bearer 토큰 자동 추가
- `_accessToken` 정적 변수 관리
- 헤더 인젝션 방지

### API 키 보안
- 하드코딩된 API 키 주의
- 프로덕션 환경에서 환경 변수 사용 권장
- 민감한 정보 로깅 방지

### 입력 검증
- JSON 이스케이프 처리
- URL 인코딩 자동 적용
- Multipart 파일 타입 검증

## 🐛 에러 처리

### 에러 캐칭
```dart
try {
  // API 호출 실행
} catch (e) {
  result = ApiCallResponse(null, {}, -1, exception: e);
}
```

### 일반적인 에러
- 네트워크 연결 실패
- 타임아웃
- 잘못된 응답 형식
- 인증 실패 (401)
- 권한 부족 (403)
- 서버 에러 (5xx)

### 에러 확인
```dart
if (!response.succeeded) {
  print('API 호출 실패: ${response.statusCode}');
  print('에러 메시지: ${response.exceptionMessage}');
}
```

## 📊 지원 기능

### HTTP 메서드
- ✅ GET - 데이터 조회
- ✅ POST - 데이터 생성
- ✅ PUT - 전체 업데이트
- ✅ PATCH - 부분 업데이트
- ✅ DELETE - 데이터 삭제

### 바디 타입
- ✅ JSON - 구조화된 데이터
- ✅ TEXT - 일반 텍스트
- ✅ Form URL Encoded - 폼 데이터
- ✅ Multipart - 파일 업로드

### 인코딩 옵션
- UTF-8 인코딩/디코딩
- 바이너리 데이터 지원
- 자동 Content-Type 설정

## 📈 모니터링

### 요청 추적
- `callName`을 통한 요청 식별
- 캐시 히트/미스 모니터링
- 응답 시간 측정 가능

### 디버깅
- 상세한 예외 정보
- 헤더 및 바디 검사
- 상태 코드 확인

## 🔗 관련 문서
- [Backend 모듈 전체](../README.md)
- [Algolia 통합](../algolia/README.md)
- [Firebase 통합](../firebase/README.md)
- [스키마 정의](../schema/README.md)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 상세 분석 추가
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: API 요청 관리 시스템 구현

---

*이 문서는 `/lib/backend/api_requests` 디렉토리의 HTTP API 클라이언트 구현을 설명합니다.*