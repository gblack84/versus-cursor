# 📂 Search DataSources

> 검색 기능의 외부 데이터 소스 접근 레이어

## 📋 개요

DataSources는 검색 기능의 모든 외부 데이터 소스와의 직접적인 통신을 담당합니다. Algolia API, Firestore, 로컬 캐시 등과의 low-level 통신을 처리합니다.

## 🎯 책임 범위

### 주요 책임
- Algolia Search API와의 직접 통신
- Firestore 데이터베이스 쿼리 실행
- 로컬 캐시(Hive) 읽기/쓰기
- 네트워크 요청 및 응답 처리
- 데이터 직렬화/역직렬화

### 책임이 아닌 것
- 비즈니스 로직 처리 (Domain Layer)
- 데이터 변환 및 매핑 (Repository)
- 에러 처리 정책 (Repository)
- 캐싱 전략 결정 (Service Layer)

## 📁 파일 구조

```
datasources/
├── algolia_datasource.dart        # Algolia API 통신
├── local_search_datasource.dart   # 로컬 캐시 접근
└── firestore_search_datasource.dart # Firestore 쿼리
```

## 🔄 마이그레이션 대상 파일

### 이동할 파일들
```bash
# Algolia 관련
git mv lib/backend/algolia/algolia_manager.dart lib/features/search/data/datasources/algolia_datasource.dart

# 새로 생성할 파일
# local_search_datasource.dart - Hive 캐시 접근
# firestore_search_datasource.dart - Firestore 직접 쿼리
```

## 📂 DataSource 사양

### AlgoliaDataSource
- **역할**: Algolia Search API와의 직접 통신
- **주요 기능**:
  - 게시물 검색 (필터, 페이지네이션 지원)
  - 사용자 검색
  - 채팅 메시지 검색
  - 검색 결과 하이라이팅
- **에러 처리**: AlgoliaException으로 통일된 예외 처리
- **인덱스**: posts_index, users_index, chats_index

### LocalSearchDataSource
- **역할**: 로컬 캐시 관리 및 검색 기록 저장
- **주요 기능**:
  - 검색 결과 캐싱 (5분 TTL)
  - 검색 기록 관리 (최대 50개)
  - 중복 검색어 제거
  - 오프라인 지원
- **스토리지**: Hive Box 활용
- **캐시 전략**: LRU with TTL

### FirestoreSearchDataSource
- **역할**: Firestore 데이터베이스 직접 쿼리
- **주요 기능**:
  - 텍스트 검색 (prefix matching)
  - 검색 기록 저장/조회
  - 인기 검색어 집계
  - 실시간 스트림 지원
- **제한사항**: Firestore의 제한적인 텍스트 검색 (정확한 prefix 매칭만 지원)
- **보완책**: Algolia와 병행 사용

## 🚨 에러 처리

### 커스텀 예외 클래스
- `AlgoliaException`: Algolia API 관련 에러
- `CacheException`: 로컬 캐시 관련 에러
- `FirestoreException`: Firestore 쿼리 관련 에러

### 에러 처리 전략
- 네트워크 에러 시 로컬 캐시 폴백
- 캐시 실패는 무시하고 진행
- 검색 실패 시 빈 결과 반환

## ✅ 마이그레이션 체크리스트

- [ ] AlgoliaDataSource 구현
  - [ ] algolia_manager.dart 이동 및 리팩토링
  - [ ] 검색 메서드 구현
  - [ ] 에러 처리 추가
- [ ] LocalSearchDataSource 구현
  - [ ] Hive 박스 설정
  - [ ] 캐싱 로직 구현
  - [ ] 검색 기록 관리
- [ ] FirestoreSearchDataSource 구현
  - [ ] Firestore 쿼리 구현
  - [ ] 스트림 처리
  - [ ] 인기 검색어 로직
- [ ] 테스트 작성
  - [ ] 단위 테스트
  - [ ] 통합 테스트

---

*DataSources는 검색 기능의 가장 낮은 수준의 데이터 접근 레이어입니다.*