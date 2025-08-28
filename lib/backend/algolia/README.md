# 🔍 Backend Algolia 검색 통합

> Versus Space 앱의 Algolia 검색 엔진 통합 모듈  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Backend Algolia 디렉토리는 Algolia 검색 서비스와의 통합을 위한 **계획 문서**를 포함하고 있습니다.
실제 구현은 Feature-First Architecture에 따라 `/lib/features/search/data/services/`에 위치합니다.

## ⚠️ 현재 상태

### 문서와 실제 구현의 불일치
```
계획된 위치: /lib/backend/algolia/
├── algolia_manager.dart       # ❌ 존재하지 않음
└── serialization_util.dart    # ❌ 존재하지 않음

실제 구현 위치: /lib/features/search/data/services/
├── algolia_manager.dart       # ✅ 실제 구현
└── serialization_util.dart    # ✅ 실제 구현
```

### 구현 상태 평가
| 컴포넌트 | 상태 | 위치 | 문제점 |
|---------|------|------|--------|
| **AlgoliaManager** | 🟢 구현됨 | features/search | Backend 레이어가 아닌 Feature에 위치 |
| **Serialization** | 🟢 구현됨 | features/search | Backend 레이어가 아닌 Feature에 위치 |
| **캐싱 시스템** | 🟢 구현됨 | features/search | 단순 메모리 캐시만 구현 |
| **에러 처리** | 🟡 부분적 | features/search | try-catch만 있고 체계적 에러 처리 없음 |

## 🏗️ 실제 구현 분석

### 1. AppAlgoliaManager (features/search/data/services/)
```dart
class AppAlgoliaManager {
  // 싱글톤 패턴
  static AppAlgoliaManager? _instance;
  static AppAlgoliaManager get instance => _instance ??= AppAlgoliaManager._();
  
  // Algolia 설정
  const kAlgoliaApplicationId = '0GAS0MPT9Z';
  const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';
  
  // 캐시 시스템
  static Map<AlgoliaQueryParams, List<AlgoliaObjectSnapshot>> _algoliaCache = {};
}
```

**특징**:
- ✅ 싱글톤 패턴 구현
- ✅ 쿼리 파라미터 캐싱
- ✅ 텍스트/위치 기반 검색
- ❌ Backend 레이어가 아닌 Feature 레이어에 위치
- ❌ Repository 패턴 미사용

### 2. Serialization Utility (features/search/data/services/)
```dart
dynamic convertAlgoliaParam<T>(
  dynamic data,
  ParamType paramType,
  bool isList,
  {StructBuilder<T>? structBuilder}
)
```

**지원 타입**:
- int, double, DateTime
- LatLng (지리 좌표)
- Color, DocumentReference
- 커스텀 Struct 타입

## 🎯 아키텍처 문제점

### 1. 계층 위반 🔴 심각
```
현재: Feature → Backend 의존성 없음
문제: Search Feature가 독립적으로 구현되어 Backend 레이어 활용 안 함
```

### 2. 중복 가능성 🟡 중간
```
다른 Feature에서도 검색이 필요할 경우 코드 중복 발생
예: Chat Feature에서 메시지 검색, Post Feature에서 게시물 검색
```

### 3. 인터페이스 부재 🔴 심각
```
Repository 패턴이나 DataSource 인터페이스 없음
테스트와 모킹이 어려움
```

## 📂 Feature-First Architecture 관점

### 현재 구조 (잘못된 구조)
```
/lib/backend/algolia/
└── README.md                 # 문서만 존재

/lib/features/search/data/services/
├── algolia_manager.dart      # 모든 구현이 Feature에
└── serialization_util.dart   # Feature 종속적
```

### 올바른 구조 (목표)
```
/lib/backend/api/algolia/
├── algolia_client.dart       # Algolia 클라이언트 래퍼
├── algolia_config.dart       # 설정 (API 키 등)
└── algolia_serializer.dart   # 공통 직렬화 유틸

/lib/features/search/
├── data/
│   ├── datasources/
│   │   └── search_remote_datasource.dart  # Algolia 클라이언트 사용
│   └── repositories/
│       └── search_repository_impl.dart     # Repository 구현
└── domain/
    └── repositories/
        └── search_repository.dart          # Repository 인터페이스
```

## 🔄 마이그레이션 필요성

### 우선순위: 🔴 높음

**이유**:
1. **재사용성**: 다른 Feature에서도 검색 기능 필요
2. **테스트**: Repository 패턴 없이 테스트 어려움
3. **확장성**: 새로운 검색 인덱스 추가 시 문제
4. **유지보수**: Feature와 Backend 책임 분리 필요

### 영향 범위
- Search Feature 전체
- 향후 검색 기능 추가 시 모든 Feature
- 테스트 코드 작성
- API 키 관리 및 보안

## 📊 현재 사용처

### Search Feature
```dart
// features/search/presentation/screens/search_screen.dart
final results = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'posts',
  term: searchQuery,
  maxResults: 50,
  useCache: true,
);
```

### 다른 Feature에서의 잠재적 사용
- Chat: 메시지 검색
- Posts: 게시물 검색
- Users: 사용자 검색
- Comments: 댓글 검색

## 🚀 개선 계획

### Phase 1: Backend 레이어 구축 (2일)
1. `/backend/api/algolia/` 디렉토리 생성
2. AlgoliaClient 래퍼 구현
3. 공통 Serializer 구현
4. Configuration 관리

### Phase 2: Repository 패턴 적용 (2일)
1. SearchRepository 인터페이스 정의
2. SearchRepositoryImpl 구현
3. RemoteDataSource 분리
4. 에러 처리 체계화

### Phase 3: Feature 리팩토링 (1일)
1. 기존 코드를 Repository 사용으로 변경
2. DI 적용
3. 테스트 코드 작성
4. 문서 업데이트

## 📝 API 사용 예시

### 현재 (Feature 직접 사용)
```dart
// ❌ Feature가 직접 Algolia 관리
final results = await AppAlgoliaManager.instance.algoliaQuery(
  index: 'posts',
  term: 'versus',
);
```

### 개선 후 (Repository 패턴)
```dart
// ✅ Repository를 통한 추상화
class SearchScreen {
  final SearchRepository repository;
  
  Future<List<Post>> search(String query) async {
    final results = await repository.searchPosts(
      query: query,
      filters: SearchFilters(maxResults: 50),
    );
    return results.fold(
      (failure) => throw failure,
      (posts) => posts,
    );
  }
}
```

## 🔗 관련 문서

- [Search Feature 문서](/lib/features/search/README.md)
- [Backend 전체 구조](/lib/backend/README.md)
- [마이그레이션 계획](./MIGRATION_Part3.md)
- [테스트 가이드](./TEST.md)
- [Feature-First Architecture 가이드](/FEATURE_ARCHITECTURE.md)

## ⚠️ 주의사항

1. **API 키 노출**: 현재 하드코딩된 API 키를 환경 변수로 이동 필요
2. **캐시 만료**: 현재 세션 기반 캐시만 있어 만료 정책 필요
3. **에러 처리**: 네트워크 에러, API 한계 등 체계적 처리 필요
4. **보안**: 검색 결과 필터링 및 권한 체크 필요

## 📈 메트릭

| 지표 | 현재 | 목표 |
|-----|------|------|
| **코드 위치** | Feature 레이어 | Backend 레이어 |
| **재사용성** | 낮음 (Feature 종속) | 높음 (전역 서비스) |
| **테스트 가능성** | 낮음 | 높음 (Repository 패턴) |
| **에러 처리** | 기본적 | 체계적 |
| **캐싱 전략** | 메모리만 | 다층 캐싱 |

---

*이 문서는 Backend Algolia 모듈의 현재 상태와 개선 계획을 설명합니다.*  
*실제 구현은 Feature-First Architecture 마이그레이션이 필요한 상태입니다.*