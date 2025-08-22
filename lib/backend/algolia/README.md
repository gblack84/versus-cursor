# Algolia Search Integration

Versus Space 앱의 Algolia 검색 엔진 통합을 담당하는 모듈입니다.

## 📋 개요

이 디렉토리는 Algolia 검색 서비스와의 통합을 관리하며, 앱 전반에서 사용되는 고성능 검색 기능을 제공합니다. 위치 기반 검색, 텍스트 검색, 캐싱 메커니즘을 포함한 통합 검색 솔루션을 구현합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase (const prefix k 사용)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/algolia/
├── README.md                    # 이 문서
├── algolia_manager.dart        # Algolia 서비스 매니저 (싱글톤)
└── serialization_util.dart     # Algolia 데이터 직렬화 유틸리티
```

## 🔧 주요 구성요소

### 1. AppAlgoliaManager (`algolia_manager.dart`)

앱의 모든 Algolia 검색 작업을 관리하는 싱글톤 매니저 클래스입니다.

**핵심 기능:**
- 싱글톤 패턴으로 단일 인스턴스 관리
- 텍스트 및 위치 기반 검색 지원
- 검색 결과 캐싱 메커니즘
- 에러 핸들링 및 로깅

**주요 메서드:**
```dart
Future<List<AlgoliaObjectSnapshot>> algoliaQuery({
  required String index,      // 검색할 인덱스명
  String? term,               // 검색어
  int? maxResults,            // 최대 결과 수
  FutureOr<LatLng>? location, // 위치 기반 검색
  double? searchRadiusMeters, // 검색 반경
  bool useCache = false,      // 캐시 사용 여부
})
```

**API 설정:**
```dart
const kAlgoliaApplicationId = '0GAS0MPT9Z';
const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';
```

**특징:**
- User-Agent 커스터마이징: `VersusSpace_1.0.0`
- 동일한 쿼리에 대한 캐싱으로 성능 최적화
- 검색어 또는 위치 중 최소 하나는 필수

### 2. AlgoliaQueryParams (`algolia_manager.dart`)

검색 파라미터를 캡슐화하고 캐시 키로 사용되는 불변(immutable) 클래스입니다.

**속성:**
- `index`: 검색 대상 인덱스
- `term`: 검색어 (선택)
- `latLng`: 위치 정보 (선택)
- `maxResults`: 최대 결과 개수 (선택)
- `searchRadiusMeters`: 검색 반경 (미터 단위, 선택)

**특징:**
- Equatable 상속으로 값 기반 동등성 비교
- 캐시 키로 사용되어 중복 쿼리 방지

### 3. Serialization Utility (`serialization_util.dart`)

Algolia 검색 결과를 앱에서 사용하는 데이터 타입으로 변환하는 유틸리티 함수입니다.

**convertAlgoliaParam 함수:**
```dart
dynamic convertAlgoliaParam<T>(
  dynamic data,
  ParamType paramType,
  bool isList,
  {StructBuilder<T>? structBuilder}
)
```

**지원 타입 변환:**
- **int**: 숫자를 정수로 반올림
- **double**: 숫자를 실수로 변환
- **DateTime**: 밀리초 타임스탬프를 DateTime으로 변환
- **LatLng**: Algolia의 `_geoloc` 필드를 LatLng 객체로 변환
- **Color**: CSS 색상 문자열을 Flutter Color로 변환
- **DocumentReference**: Firestore 문서 참조로 변환

**특징:**
- 리스트 타입 자동 처리
- null 안전성 보장
- 에러 발생 시 null 반환으로 앱 크래시 방지

## 🔍 검색 플로우

### 기본 검색 플로우
```
1. 사용자가 검색어 입력 또는 위치 정보 제공
    ↓
2. AppAlgoliaManager.algoliaQuery() 호출
    ↓
3. 캐시 확인 (useCache=true인 경우)
    ↓ (캐시 미스)
4. Algolia API 쿼리 생성 및 실행
    ↓
5. 검색 결과를 AlgoliaObjectSnapshot 리스트로 수신
    ↓
6. 캐시에 저장 및 결과 반환
```

### 위치 기반 검색
```dart
// 예시: 현재 위치 기준 5km 반경 내 검색
final results = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'posts',
  term: 'versus',
  location: currentLocation,
  searchRadiusMeters: 5000,
  maxResults: 20,
  useCache: true,
);
```

## 🚀 사용 예시

### 텍스트 검색
```dart
// 게시물 인덱스에서 키워드 검색
final searchResults = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'posts',
  term: '축구 vs 농구',
  maxResults: 50,
  useCache: true,
);
```

### 위치 기반 검색
```dart
// 특정 위치 주변 콘텐츠 검색
final nearbyPosts = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'posts',
  location: LatLng(37.5665, 126.9780), // 서울
  searchRadiusMeters: 10000, // 10km
  maxResults: 30,
);
```

### 하이브리드 검색
```dart
// 텍스트 + 위치 조합 검색
final hybridResults = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'users',
  term: 'developer',
  location: userLocation,
  searchRadiusMeters: 50000,
  useCache: false, // 실시간 검색
);
```

## 📊 인덱스 구조

Algolia에서 사용하는 주요 인덱스:
- **posts**: 게시물 검색
- **users**: 사용자 검색
- **comments**: 댓글 검색
- **chats**: 채팅 메시지 검색

각 인덱스는 Firestore 컬렉션과 동기화되며, Firebase Functions를 통해 자동 업데이트됩니다.

## ⚡ 성능 최적화

### 캐싱 전략
- AlgoliaQueryParams를 키로 사용한 메모리 캐싱
- 동일한 검색 쿼리 반복 방지
- 세션 단위 캐시 (앱 재시작 시 초기화)

### 검색 최적화
- `setHitsPerPage`로 결과 수 제한
- `setAroundRadius`로 검색 범위 제한
- 인덱스별 최적화된 검색 필드 설정

## 🔒 보안 고려사항

### API 키 관리
- 검색 전용 API 키 사용 (읽기 권한만 부여)
- 프로덕션 환경에서는 환경 변수로 관리 권장
- 키 노출 시 즉시 재생성 필요

### 데이터 보안
- 민감한 정보는 검색 인덱스에서 제외
- 사용자별 권한 확인은 클라이언트에서 추가 구현
- 검색 결과 필터링 로직 필요

## 🐛 에러 처리

### 에러 핸들링
```dart
try {
  snapshot = await query.getObjects();
} catch (error, stackTrace) {
  print('Algolia error: $error\nStack trace: $stackTrace');
  snapshot = null;
}
```

### 일반적인 에러
- 네트워크 연결 실패
- API 키 만료 또는 권한 부족
- 인덱스 이름 오타
- 할당량 초과

## 📈 모니터링

### 검색 메트릭
- 검색 쿼리 수
- 평균 응답 시간
- 캐시 히트율
- 에러율

Algolia 대시보드에서 실시간 모니터링 가능합니다.

## 🔗 관련 문서
- [Backend 모듈 전체](../README.md)
- [Firebase 통합](../firebase/README.md)
- [스키마 정의](../schema/README.md)
- [Algolia 공식 문서](https://www.algolia.com/doc/)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 상세 분석 추가
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: Algolia 통합 구현

---

*이 문서는 `/lib/backend/algolia` 디렉토리의 검색 엔진 통합 구현을 설명합니다.*