# 📂 Search Services

> 검색 기능의 비즈니스 서비스 레이어

## 📋 개요

Services는 검색 기능의 특정 비즈니스 로직을 캡슐화하고, 여러 Repository에서 재사용할 수 있는 공통 기능을 제공합니다.

## 🎯 서비스 책임

### Services의 역할
- 특정 비즈니스 로직 캡슐화
- 캐싱 전략 구현
- 필터 변환 및 처리
- 검색 기록 관리
- 데이터 변환 유틸리티
- 성능 최적화 로직

### Services가 하지 않는 것
- 직접적인 외부 API 호출 (DataSource 책임)
- UI 상태 관리 (Presentation 책임)
- 도메인 규칙 정의 (Domain 책임)

## 📁 파일 구조

```
services/
├── algolia_manager.dart          # Algolia 매니저 (기존)
├── search_cache_service.dart     # 검색 결과 캐싱
├── search_history_service.dart   # 검색 기록 관리
└── search_filter_service.dart    # 검색 필터 처리
```

## 🔄 마이그레이션 대상

### 이동할 파일
```bash
# Algolia Manager 이동
git mv lib/backend/algolia/algolia_manager.dart lib/features/search/data/services/

# Serialization Util 이동 (필요시)
git mv lib/backend/algolia/serialization_util.dart lib/features/search/data/services/
```

### 새로 생성할 파일
```bash
touch lib/features/search/data/services/search_cache_service.dart
touch lib/features/search/data/services/search_history_service.dart
touch lib/features/search/data/services/search_filter_service.dart
```

## 📂 서비스 사양

### AlgoliaManager (기존 코드 리팩토링)
- **역할**: Algolia 검색 엔진 관리 및 인덱싱
- **주요 기능**:
  - Application ID: 0GAS0MPT9Z
  - API Key: 환경 변수로 관리
  - 3개 인덱스 관리: posts, users, chats
  - 인덱스별 설정 초기화
  - 객체 인덱싱/업데이트/삭제
  - 배치 작업 지원
- **검색 가능 속성**:
  - Posts: title, description, tags
  - Users: displayName, userName, bio
  - Chats: lastMessage, chatName
- **랭킹 전략**: votesCount, createdAt 우선순위

### SearchCacheService
- **역할**: 검색 결과 메모리 캐싱 관리
- **주요 기능**:
  - LRU (Least Recently Used) 캐시 구현
  - 5분 TTL (Time To Live)
  - 최대 100개 캐시 항목
  - 캐시 유효성 검사
  - 캐시 통계 제공
- **캐시 전략**:
  - Key-Value 기반 저장
  - 자동 만료 처리
  - LRU 제거 정책
  - 히트율 추적
- **성능 최적화**:
  - 메모리 사용량 모니터링
  - 캐시 히트/미스 추적

### SearchHistoryService
- **역할**: 검색 기록 저장 및 분석
- **주요 기능**:
  - 사용자별 검색 기록 관리
  - 최대 50개 기록, 30일 보관
  - 중복 검색어 자동 제거
  - 최근 검색어 조회
  - 인기 검색어 분석
  - 트렌드 추적
- **저장소**: Hive 로컬 데이터베이스
- **분석 기능**:
  - 기간별 인기 검색어 (24시간 기본)
  - 검색 빈도 계산
  - 상승/하락 트렌드 분석
- **데이터 관리**:
  - 자동 만료 처리
  - 크기 제한 관리
  - 사용자별 격리

### SearchFilterService
- **역할**: 검색 필터 변환 및 처리
- **주요 기능**:
  - Algolia 필터 빌드
  - Firestore 쿼리 생성
  - 필터 검증 및 정규화
  - 필터 병합
- **필터 유형**:
  - 카테고리 필터
  - 날짜 범위 필터
  - 태그 필터
  - 관련성 점수 필터
- **정렬 옵션**:
  - 날짜순 (오름차순/내림차순)
  - 인기순 (votesCount 기준)
  - 관련성순 (Algolia만 지원)
- **데이터 검증**:
  - 날짜 범위 유효성
  - 페이지네이션 파라미터
  - 관련성 점수 범위 (0-1)

## 🧪 테스트 전략

### 테스트 범위
- **단위 테스트**: 각 서비스별 핵심 기능 검증
- **통합 테스트**: 서비스 간 상호작용 검증
- **성능 테스트**: 캐시 효율성 및 응답 시간

### 테스트 시나리오
- 캐시 저장 및 조회
- 캐시 만료 처리
- 검색 기록 중복 제거
- 필터 검증 및 변환
- 인기 검색어 계산

## 📝 마이그레이션 체크리스트

- [ ] AlgoliaManager 이동 및 리팩토링
  - [ ] 환경 변수로 API 키 관리
  - [ ] 인덱스 설정 메서드 추가
  - [ ] 배치 작업 지원
- [ ] SearchCacheService 구현
  - [ ] LRU 캐시 구현
  - [ ] TTL 관리
  - [ ] 통계 수집
- [ ] SearchHistoryService 구현
  - [ ] Hive 통합
  - [ ] 중복 제거 로직
  - [ ] 트렌딩 분석
- [ ] SearchFilterService 구현
  - [ ] Algolia 필터 변환
  - [ ] Firestore 쿼리 빌더
  - [ ] 필터 검증
- [ ] 테스트 작성
  - [ ] 각 서비스별 단위 테스트
  - [ ] 통합 테스트

---

*Services는 검색 기능의 재사용 가능한 비즈니스 로직을 제공합니다.*