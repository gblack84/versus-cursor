# 📡 /lib/features/posts/data/datasources

> Feature-First Architecture - Posts 데이터소스 계층

## 📋 개요

Posts 기능의 **Data Sources Layer**를 담당하는 디렉토리입니다. 원격(Remote) 및 로컬(Local) 데이터 소스를 분리하여 데이터 접근을 추상화합니다.

### 🎯 목적
- **데이터 소스 분리**: 원격/로컬 데이터 접근 로직 분리
- **캐싱 전략**: 3-Layer 캐싱 시스템 구현
- **오프라인 지원**: 네트워크 없이도 기본 기능 제공
- **테스트 용이성**: Mock 데이터소스로 단위 테스트 지원

## 🏗️ 디렉토리 구조

```
datasources/
├── remote/                                    # 원격 데이터소스
│   ├── firebase_post_datasource.dart        # Firestore 게시물 데이터
│   ├── cloud_storage_datasource.dart        # Firebase Storage 미디어
│   ├── firebase_vote_datasource.dart        # 투표 데이터 접근
│   ├── perspective_api_datasource.dart      # 텍스트 검열 API
│   ├── gemini_api_datasource.dart          # AI 논리 검증 API
│   └── cloud_vision_datasource.dart        # 이미지 검열 API
│
└── local/                                    # 로컬 데이터소스
    ├── post_local_datasource.dart          # 게시물 로컬 캐시
    ├── media_local_datasource.dart         # 미디어 파일 캐시
    ├── vote_local_datasource.dart          # 투표 데이터 캐시
    └── moderation_cache_datasource.dart    # 검열 결과 캐시
```

## 📂 Remote 데이터소스 사양

### FirebasePostDatasource
- **역할**: Firestore 게시물 데이터 관리
- **주요 기능**:
  - 게시물 CRUD 작업 (생성, 조회, 수정, 삭제)
  - 피드 가져오기 (페이지네이션 지원)
  - 사용자별 게시물 조회
  - 인기 게시물 조회
  - 실시간 게시물 스트림
- **컬렉션**: `posts`
- **에러 처리**: ServerException, NotFoundException

### CloudStorageDatasource
- **역할**: Firebase Storage 미디어 파일 관리
- **주요 기능**:
  - 파일/바이트 업로드
  - 파일 다운로드
  - 파일 삭제 (단일/다중)
  - 메타데이터 관리
- **캐싱**: 1년 Cache-Control 설정
- **에러 처리**: StorageException

### FirebaseVoteDatasource
- **역할**: 투표 데이터 관리
- **주요 기능**:
  - 투표 제출 (트랜잭션 보장)
  - 투표 통계 조회
  - 사용자 투표 기록 조회
  - 실시간 투표 스트림
- **컬렉션**: `posts/{postId}/votes`
- **에러 처리**: ValidationException (중복 투표)

### PerspectiveApiDatasource (예정)
- **역할**: Google Perspective API 텍스트 검열
- **주요 기능**:
  - 텍스트 독성 분석
  - 욕설/혐오 표현 감지
  - 점수 기반 필터링

### GeminiApiDatasource (예정)
- **역할**: Google Gemini AI 논리 검증
- **주요 기능**:
  - A/B 선택지 논리성 검증
  - 콘텐츠 품질 평가
  - AI 기반 카테고리 분류

### CloudVisionDatasource (예정)
- **역할**: Google Cloud Vision 이미지 검열
- **주요 기능**:
  - 이미지 안전성 검사
  - 성인/폭력 콘텐츠 감지
  - 이미지 라벨링

## 📂 Local 데이터소스 사양

### PostLocalDatasource
- **역할**: 게시물 로컬 캐싱
- **주요 기능**:
  - 게시물 캐시 저장/조회
  - 피드 캐싱 (카테고리/태그별)
  - 캐시 유효성 검사 (5분 TTL)
  - 만료 캐시 자동 정리
- **스토리지**: Hive Box (`posts_cache`, `feed_cache`)

### MediaLocalDatasource
- **역할**: 미디어 파일 로컬 캐싱
- **주요 기능**:
  - 이미지 파일 캐싱
  - 메모리 + 디스크 2중 캐싱
  - 캐시 크기 계산
  - 만료 캐시 정리 (7일 TTL)
- **스토리지**: 파일 시스템 (`media_cache` 디렉토리)

### VoteLocalDatasource
- **역할**: 투표 데이터 로컬 캐싱
- **주요 기능**:
  - 투표 상태 캐싱
  - 사용자 투표 기록 캐싱
  - 실시간 동기화 지원

### ModerationCacheDatasource (예정)
- **역할**: 검열 결과 캐싱
- **주요 기능**:
  - API 응답 캐싱
  - 중복 검열 방지
  - 비용 절감

## 🔄 데이터 흐름

```mermaid
graph TD
    A[Repository] --> B{Network Check}
    B -->|Online| C[Remote Datasource]
    B -->|Offline| D[Local Datasource]
    
    C --> E[Firebase/API]
    D --> F[Hive/File System]
    
    C --> G[Cache Update]
    G --> D
    
    H[3-Layer Cache] --> I[Memory Cache]
    H --> J[Local DB (Hive)]
    H --> K[Remote (Firestore)]
    
    I --> L[< 10ms Response]
    J --> M[10-30ms Response]
    K --> N[50-100ms Response]
```

## 🧪 테스트 전략

### Mock 데이터소스
- 모든 데이터소스는 인터페이스 기반 설계
- Mock 구현체로 단위 테스트 지원
- 네트워크 지연 시뮬레이션
- 에러 시나리오 테스트

## 🔐 보안 고려사항

### 데이터 보호
- **로컬 암호화**: 민감한 데이터는 암호화 저장
- **네트워크 보안**: HTTPS 통신 강제
- **API 키 관리**: 환경 변수로 안전하게 관리

### 접근 제어
- **Firebase Rules**: Firestore 보안 규칙 설정
- **인증 검증**: 모든 요청에 사용자 인증 확인
- **권한 관리**: 역할 기반 접근 제어

## ⚠️ 에러 처리

### 커스텀 예외 클래스
- `DataSourceException`: 기본 예외 클래스
- `NetworkException`: 네트워크 관련 예외
- `CacheException`: 캐시 관련 예외
- `ServerException`: 서버 에러
- `StorageException`: 스토리지 에러
- `NotFoundException`: 리소스 없음
- `ValidationException`: 유효성 검사 실패

## ✅ 체크리스트

### 구현 완료
- [ ] Firebase Post Datasource
- [ ] Cloud Storage Datasource
- [ ] Firebase Vote Datasource
- [ ] Post Local Datasource
- [ ] Media Local Datasource
- [ ] Vote Local Datasource

### 구현 예정
- [ ] Perspective API Datasource
- [ ] Gemini API Datasource
- [ ] Cloud Vision Datasource
- [ ] Moderation Cache Datasource
- [ ] WebSocket 실시간 데이터소스
- [ ] GraphQL 데이터소스

## 📚 참고 자료

- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Flutter Caching Strategies](https://flutter.dev/docs/cookbook/networking/cached-images)

---

*이 문서는 Feature-First Architecture의 Posts 기능 데이터소스 가이드입니다.*
*최종 업데이트: 2025-08-25*