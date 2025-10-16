# 🖼️ Image Service 레이어

> 애플리케이션 전역 이미지 캐싱 및 최적화 시스템  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Image Service는 Versus Space 애플리케이션의 전역 이미지 캐싱 및 최적화를 담당하는 서비스 레이어입니다.
CachedNetworkImage 패키지를 활용하여 성능 최적화된 이미지 로딩과 메모리 관리를 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/image/
└── unified_image_cache_service.dart   # 261줄 - 통합 이미지 캐시 서비스
```

## 🔍 현재 코드 분석

### unified_image_cache_service.dart (261줄)

#### 핵심 구성요소

**1. UnifiedImageCacheService 싱글톤 클래스**
```dart
class UnifiedImageCacheService {
  static final UnifiedImageCacheService _instance = UnifiedImageCacheService._internal();
  static UnifiedImageCacheService get instance => _instance;
  
  // 캐시 크기 상수
  static const int MIN_CACHE_WIDTH = 400;   // 최소 캐시 너비
  static const int MAX_CACHE_WIDTH = 1600;  // 최대 캐시 너비  
  static const double SCALE_FACTOR = 2.0;   // 기본 스케일 팩터
  
  // 캐시 추적
  final Set<String> _cachedUrls = {};
  final Set<String> _preloadingUrls = {};
}
```

**2. 캐시 크기 계산 메서드**
- `calculateMemCacheWidth()`: 기본 캐시 너비 계산 (400-1600px)
- `calculateWithPixelRatio()`: 디바이스 픽셀 비율 고려
- `calculateForBox()`: 박스 크기 기반 최적화 계산

**3. 이미지 프리로딩 기능**
- `preloadImages()`: 다중 이미지 병렬 프리로드
- `preloadVoteMessageImages()`: 투표 메시지 이미지 전용
- `preloadAdjacentImages()`: PageView 인접 이미지 프리로드

**4. 캐시 관리 기능**
- `clearOldCache()`: LRU 기반 오래된 캐시 제거
- `evictFromCache()`: 특정 이미지 캐시 제거
- `clearAllCache()`: 전체 캐시 초기화
- `getCacheStats()`: 캐시 통계 정보 제공

#### 주요 특징

1. **싱글톤 패턴**: 앱 전체에서 단일 인스턴스 사용
2. **동적 캐시 크기**: 디스플레이 크기와 픽셀 비율 고려
3. **중복 방지**: URL 추적으로 중복 프리로드 방지
4. **메모리 최적화**: LRU 캐시 정리 및 제한된 프리로드
5. **통계 모니터링**: 캐시 상태 실시간 추적

#### 성능 최적화 전략

- **캐시 크기 제한**: 400-1600px 범위로 제한
- **프리로드 제한**: 최대 5개 이미지 동시 프리로드
- **중복 체크**: Set 자료구조로 O(1) 중복 체크
- **자동 정리**: 100개 초과 시 오래된 캐시 자동 제거

## 💡 주요 기능

### 1. 이미지 캐시 크기 계산
```dart
// 기본 계산
int width = UnifiedImageCacheService.calculateMemCacheWidth(300.0);

// 픽셀 비율 고려
int width = UnifiedImageCacheService.calculateWithPixelRatio(context, 300.0);

// 박스 기반 계산
int width = UnifiedImageCacheService.calculateForBox(
  context,
  boxWidth: 200.0,
  isHorizontal: true,
);
```

### 2. 이미지 프리로딩
```dart
// 다중 이미지 프리로드
await UnifiedImageCacheService.instance.preloadImages(
  context,
  ['url1', 'url2', 'url3'],
  maxPreloadCount: 3,
);

// 투표 메시지 이미지
await UnifiedImageCacheService.instance.preloadVoteMessageImages(
  context,
  imageUrlsA: ['urlA1', 'urlA2'],
  imageUrlsB: ['urlB1', 'urlB2'],
);
```

### 3. 캐시 관리
```dart
// 캐시 상태 확인
bool cached = UnifiedImageCacheService.instance.isCached(imageUrl);

// 캐시 통계
Map stats = UnifiedImageCacheService.instance.getCacheStats();

// 오래된 캐시 정리
UnifiedImageCacheService.instance.clearOldCache(keepRecentCount: 50);
```

## 🔄 사용 시나리오

### 1. 채팅 메시지 이미지
- 투표 카드 이미지 프리로딩
- 메시지 목록 스크롤 시 인접 이미지 프리로드
- 멀티 이미지 지원 (A/B 각각 여러 이미지)

### 2. 피드 포스트
- 홈 피드 이미지 최적화
- 스크롤 시 다음 포스트 이미지 프리로드
- 썸네일과 원본 이미지 차별화

### 3. 프로필 이미지
- 사용자 프로필 이미지 캐싱
- 채팅 목록 아바타 최적화
- 작은 크기로 메모리 절약

### 4. 갤러리 뷰
- PageView 기반 이미지 갤러리
- 현재 이미지 앞뒤 2개씩 프리로드
- 스와이프 시 부드러운 전환

## 🚨 현재 문제점

### 1. 캐시 정책 미흡
- **문제**: 고정된 LRU 정책만 사용
- **영향**: 중요 이미지 손실 가능
- **해결**: 우선순위 기반 캐시 정책 필요

### 2. 네트워크 최적화 부재
- **문제**: 네트워크 상태 미고려
- **영향**: 느린 네트워크에서 과도한 프리로드
- **해결**: 네트워크 상태별 전략 차별화

### 3. 에러 처리 단순
- **문제**: 단순 try-catch로만 처리
- **영향**: 에러 원인 파악 어려움
- **해결**: 체계적인 에러 분류 및 리포팅

### 4. 테스트 부재
- **문제**: 단위 테스트 없음
- **영향**: 리팩토링 시 안정성 보장 불가
- **해결**: 테스트 커버리지 80% 이상 확보

## 📊 메트릭스

### 현재 성능
- 캐시 히트율: ~60% (추정)
- 프리로드 성공률: ~85%
- 메모리 사용량: 이미지당 ~200KB (800px 기준)
- 응답 시간: 캐시 히트 시 <10ms

### 개선 목표
- 캐시 히트율: >75%
- 프리로드 성공률: >95%
- 메모리 최적화: 이미지당 <150KB
- 응답 시간: 캐시 히트 시 <5ms

## 🔗 연관 시스템

### 사용처 (9개 통합 완료)

**Chat Feature** (2개):
- ✅ `ChatDetailWidgetClean` - 메시지 목록 이미지 프리로딩 (직접 사용, line 140)
- ✅ `AIChatPageClean` - AI 채팅방 이미지 프리로딩 (직접 사용, line 179)

**Voting Feature** (4개):
- ✅ `VoteCardMessage` - 투표 카드 이미지 프리로딩 (Phase 1.1)
- ✅ `VotingDialog` - 투표 알림 이미지 프리로딩 (Phase 1.3)
- ✅ `VotingImageViewer` - PageView 인접 이미지 프리로딩 (Phase 2)
- ✅ `VoteCardHeader` - 투표 카드 헤더 아바타 캐싱 (Phase 3.3)

**Profile Feature** (2개):
- ✅ `ProfileAvatar` - 재사용 가능한 아바타 위젯 캐싱 (Phase 3.1)
- ✅ `HomePageWidget` - 피드 카드 사용자 아바타 캐싱 (Phase 3.2)

**Creation Feature** (1개):
- ✅ `BaseMediaSelectionBox` - 이미지 선택 시 프리로딩 (기존)

### 통합 상태
- **완료**: 9개 컴포넌트 (Chat 2개 + Voting 4개 + Profile 2개 + Creation 1개)
- **직접 사용**: Chat Feature는 UnifiedImageCacheService를 직접 호출
- **Phase 3 완료**: Profile Feature 통합 (ProfileAvatar 중앙 집중식 캐싱)

### 의존성
- `cached_network_image`: 네트워크 이미지 캐싱
- `flutter/painting`: 이미지 캐시 인터페이스
- **Services**: UnifiedCacheService (메시지 캐싱과 협업)

### 통합 대상
- **네트워크 서비스**: 네트워크 상태 감지
- **분석 서비스**: 캐시 성능 메트릭 수집
- **설정 서비스**: 사용자별 캐시 정책

## 🎯 Clean Architecture 마이그레이션 필요

### 현재 위치
```
/lib/services/image/  # 전역 서비스 (유지)
└── unified_image_cache_service.dart  # 단일 파일
```

### 목표 구조
```
/lib/services/image/            # Services Layer 유지
  ├── domain/                   # 도메인 레이어
  │   ├── entities/            # ImageCache, CachePolicy
  │   ├── usecases/            # PreloadImages, ClearCache
  │   └── repositories/        # ImageCacheRepository
  ├── data/                     # 데이터 레이어
  │   ├── services/            # NetworkAwareService, OptimizationService
  │   ├── datasources/         # NetworkImageSource, LocalCache
  │   └── repositories/        # ImageCacheRepositoryImpl
  ├── presentation/             # 프레젠테이션 레이어
  │   ├── providers/            # ImageCacheProvider
  │   └── widgets/              # OptimizedImage, PreloadedImage
  └── utils/                    # 유틸리티
      ├── calculators/          # 이미지 크기 계산
      └── constants/            # 캐시 상수
```

### 마이그레이션 이점
1. **Services Layer 유지**: 전역 서비스 역할 보존
2. **Clean Architecture**: 레이어별 책임 분리
3. **Features → Services**: 모든 Feature에서 사용 가능
4. **점진적 마이그레이션**: 기존 코드와 호환성 유지

## 📝 다음 단계

1. **네트워크 상태 통합**
   - NetworkService와 연동
   - WiFi/Cellular 구분 캐싱
   - 오프라인 모드 지원

2. **우선순위 캐싱**
   - 이미지 중요도 분류
   - 우선순위 기반 eviction
   - 고정 캐시 지원

3. **성능 모니터링**
   - 캐시 히트율 추적
   - 메모리 사용량 모니터링
   - 성능 메트릭 대시보드

4. **에러 리포팅**
   - 구조화된 에러 로깅
   - 에러 타입별 처리
   - 자동 재시도 메커니즘

## 🔄 버전 이력

### v1.0.0 (2025-08)
- UnifiedImageCacheService 초기 구현
- ChatImageCacheService에서 마이그레이션
- 기본 프리로드 및 캐시 관리 기능

### v1.1.0 (계획)
- 네트워크 상태 기반 최적화
- 우선순위 캐싱 시스템
- 성능 모니터링 통합

### v2.0.0 (계획)
- Feature-First 마이그레이션
- 비디오 캐싱 지원
- AI 기반 프리로드 예측

## ⚠️ 주의사항

1. **메모리 관리**: 대량 이미지 프리로드 시 OOM 주의
2. **네트워크 사용**: 모바일 데이터에서 과도한 프리로드 방지
3. **캐시 크기**: 디바이스 저장 공간 모니터링 필요
4. **동시성**: 병렬 프리로드 시 race condition 주의

## 📚 참고 자료

- [CachedNetworkImage Documentation](https://pub.dev/packages/cached_network_image)
- [Flutter Image Caching Guide](https://flutter.dev/docs/cookbook/images/cached-images)
- [Memory Optimization Best Practices](https://flutter.dev/docs/perf/memory)