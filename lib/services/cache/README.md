# 📋 Cache Service 레이어

> 애플리케이션 전역 3-Layer 캐싱 시스템  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Cache Service는 Versus Space 애플리케이션의 전역 캐싱 시스템을 담당하는 서비스 레이어입니다.
Memory(L1) → Hive(L2) → Firestore(L3)의 3단계 캐싱 아키텍처로 데이터 접근 속도를 극적으로 개선합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/cache/
├── unified_cache_service.dart    # 523줄 - 통합 캐시 서비스 (싱글톤)
├── simple_memory_cache.dart      # 160줄 - L1 메모리 캐시 (LRU)
├── cache_statistics.dart         # 168줄 - 캐시 통계 및 모니터링
└── preload_strategy.dart         # 237줄 - 프리로딩 전략
```

## 🔍 현재 코드 분석

### unified_cache_service.dart (523줄)

#### 핵심 구성요소

**1. UnifiedCacheService 추상 클래스**
```dart
abstract class UnifiedCacheService {
  static late UnifiedCacheService _instance;  // 싱글톤
  
  // 기본 캐시 연산
  Future<T?> get<T>(String key, {CacheLayer? layer});
  Future<void> set<T>(String key, T value, {Duration? ttl, CacheLayer? layer});
  
  // 도메인 특화 메서드
  Future<List<MessagesModel>> getChatMessages(String chatId);
  Future<List<PostsModel>> getFeedPosts({int limit = 20});
  Future<UsersModel?> getUserProfile(String userId);
}
```

**2. CacheLayer Enum**
```dart
enum CacheLayer {
  memory,    // L1: 메모리 캐시
  local,     // L2: 로컬 DB (Hive)
  remote,    // L3: Firestore
  all,       // 모든 레이어
}
```

**3. UnifiedCacheServiceImpl 구현**
- 3-Layer 캐시 조회 로직
- 캐시 히트 시 상위 레이어로 승격
- 패턴 기반 무효화
- 도메인별 최적화

#### 주요 특징

1. **계층적 캐시 조회**: L1 → L2 → L3 → Network
2. **자동 승격**: 하위 레이어 히트 시 상위 레이어로 복사
3. **TTL 관리**: 데이터 타입별 다른 TTL 적용
4. **배치 처리**: 여러 메시지/포스트 한번에 저장
5. **무결성 검증**: 손상된 캐시 엔트리 자동 감지/제거

### simple_memory_cache.dart (160줄)

#### 핵심 구성요소

**1. SimpleMemoryCache 클래스**
```dart
class SimpleMemoryCache {
  static const int maxCacheSize = 100;
  static const Duration defaultTTL = Duration(minutes: 5);
  
  final Map<String, CacheEntry> _cache = {};
  
  T? get<T>(String key) { }
  void set<T>(String key, T value, {Duration? ttl}) { }
  void _evictLRU() { }  // LRU 알고리즘
}
```

**2. CacheEntry 클래스**
```dart
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  DateTime lastAccessed;
  final Duration ttl;
}
```

#### 주요 특징

1. **LRU 정책**: 100개 제한, 가장 오래 사용 안 한 항목 제거
2. **TTL 지원**: 항목별 만료 시간 설정
3. **접근 시간 추적**: 히트 시마다 lastAccessed 업데이트
4. **메모리 효율**: 작은 데이터만 저장 (이미지 제외)

### cache_statistics.dart (168줄)

#### 핵심 구성요소

**1. CacheStatistics 싱글톤**
```dart
class CacheStatistics {
  int _l1Hits = 0;
  int _l2Hits = 0;
  int _l3Hits = 0;
  int _networkFetches = 0;
  
  double get overallHitRate { }
  double get l1HitRate { }
  int get firestoreSavedReads { }
  double get estimatedCostSavings { }
}
```

#### 주요 특징

1. **레이어별 통계**: L1/L2/L3 개별 히트율
2. **응답 시간 추적**: 평균, P95, P99
3. **비용 계산**: Firestore 읽기 절감액 추정
4. **실시간 모니터링**: 디버그 모드 리포트

### preload_strategy.dart (237줄)

#### 핵심 구성요소

**1. PreloadStrategy 클래스**
```dart
class PreloadStrategy {
  static Future<void> preloadRecentChats(String? userId) async {
    // 최근 10개 채팅
    // 각 채팅당 15개 메시지
    // 병렬 처리
  }
  
  static Future<void> preloadPopularPosts() async {
    // 최신 20개 포스트
    // 이미지 메타데이터 포함
  }
}
```

#### 주요 특징

1. **지능형 프리로딩**: 사용 패턴 기반
2. **병렬 처리**: Future.wait로 동시 로드
3. **우선순위**: 최근 > 인기 > 일반
4. **백그라운드**: UI 차단 없이 실행

## 💡 주요 기능

### 1. 3-Layer 캐싱 아키텍처

```
요청 → L1 Memory (< 10ms)
     ↓ MISS
     → L2 Hive (10-30ms)  
     ↓ MISS
     → L3 Firestore Cache (50-100ms)
     ↓ MISS
     → Network (300-500ms)
```

### 2. 도메인별 최적화

```dart
// 채팅 메시지 - 짧은 TTL (5분)
getChatMessages(chatId)

// 피드 포스트 - 중간 TTL (10분)  
getFeedPosts(limit: 30)

// 사용자 프로필 - 긴 TTL (1시간)
getUserProfile(userId)
```

### 3. 무효화 전략

```dart
// 패턴 기반 무효화
invalidate('chat_messages_*')  // 모든 채팅
invalidate('user_profile_123') // 특정 유저

// 레이어별 클리어
clear(layer: CacheLayer.memory)
clear(layer: CacheLayer.all)
```

## 🔄 사용 시나리오

### 1. 채팅방 진입
```dart
// 1. 채팅 메시지 캐시 확인
final messages = await cache.getChatMessages(chatId);

// 2. 백그라운드 동기화
_syncInBackground(chatId);

// 3. 관련 데이터 프리로드
await preloadParticipantProfiles(chatId);
```

### 2. 홈 피드 로드
```dart
// 1. 캐시된 포스트 즉시 표시
final cachedPosts = await cache.getFeedPosts();

// 2. 새 포스트 확인
final newPosts = await checkForNewPosts();

// 3. 캐시 업데이트
await cache.setFeedPosts([...newPosts, ...cachedPosts]);
```

### 3. 프로필 조회
```dart
// 1. 메모리 캐시 확인 (즉시)
final profile = await cache.getUserProfile(userId);

// 2. 친구인 경우 더 긴 캐싱
if (isFriend(userId)) {
  cache.set(key, profile, ttl: Duration(hours: 6));
}
```

## 🚨 현재 문제점

### 1. Feature 의존성 역방향
- **문제**: UnifiedCacheService가 MessagesModel, PostsModel 직접 import
- **영향**: Services → Backend/Features 역방향 의존성 발생
- **해결**: 제네릭 타입 사용, Feature별 캐시 전략 인터페이스

### 2. 싱글톤 패턴 하드코딩
- **문제**: static 싱글톤으로 테스트 어려움
- **영향**: 단위 테스트 시 Mock 주입 불가
- **해결**: DI(Dependency Injection) 패턴 적용 필요

### 3. 캐시 전략 하드코딩
- **문제**: TTL, 크기 제한 등이 코드에 하드코딩
- **영향**: Feature별 최적화 어려움
- **해결**: 전략 패턴으로 Feature별 설정 주입

### 4. 모니터링 부족
- **문제**: 실시간 성능 모니터링 미흡
- **영향**: 최적화 기회 놓침
- **해결**: 실시간 대시보드, ML 기반 예측

## 📊 메트릭스

### 현재 성능
- 캐시 히트율: 60-80%
- L1 응답: <10ms
- L2 응답: 10-30ms  
- L3 응답: 50-100ms
- Network: 300-500ms
- Firestore 읽기 절감: 60-80%

### 개선 목표
- 전체 히트율: 85% 이상
- L1 히트율: 60% 이상
- 평균 응답: 15ms 이하
- 메모리 사용: 30MB 이하

## 🔗 연관 시스템

### 사용처 (Features)
- **chat**: 메시지 캐싱, 채팅방 목록
- **posts**: 피드 캐싱, 이미지 메타데이터
- **profile**: 사용자 정보, 아바타 이미지
- **voting**: 투표 데이터, 실시간 결과
- **notifications**: 알림 목록, 읽음 상태

### 의존성 (Services/Backend)
- `hive_flutter`: L2 로컬 DB
- `cloud_firestore`: L3 원격 캐시
- `/backend/schema`: 데이터 모델 (문제: 역방향 의존성)

### 통합 대상
- **DI System**: GetIt 통합 예정
- **Performance Monitor**: 실시간 모니터링
- **Analytics**: 사용 패턴 분석

## 🎯 Services Layer 유지 필요성

### 왜 Services Layer에 있어야 하는가?

1. **전역 서비스**: 모든 Feature에서 공통으로 사용
2. **인프라 성격**: 데이터 접근 최적화는 인프라 레벨
3. **Feature 독립성**: Feature는 캐싱 구현을 몰라야 함
4. **성능 최적화**: 중앙 집중식 캐시 관리가 효율적

### Feature-First Architecture 준수

```
✅ 올바른 의존성:
Features (chat, posts, profile...)
    ↓ 사용
Services (cache, logger, image...)
    ↓ 사용
Backend (firebase, models...)

❌ 현재 문제:
Services
    ↓ import (역방향!)
Backend/schema (MessagesModel, PostsModel...)
```

## 📝 다음 단계

1. **역방향 의존성 해결**
   - 제네릭 타입으로 변경
   - Feature별 Adapter 패턴
   - 인터페이스 정의

2. **DI 패턴 적용**
   - GetIt 통합
   - 싱글톤 제거
   - 테스트 가능성 향상

3. **Feature별 최적화**
   - 캐시 전략 인터페이스
   - Feature별 설정 주입
   - 동적 TTL 관리

4. **모니터링 강화**
   - 실시간 대시보드
   - ML 기반 예측
   - 자동 최적화

## 🔄 버전 이력

### v2.0.0 (2025-08-28)
- Services Layer 구조 명확화
- 역방향 의존성 문제 식별
- Feature-First 원칙 재정립

### v1.0.0 (2025-08-13)
- 3-Layer 캐싱 시스템 구현
- 60-80% 성능 개선 달성
- 프리로딩 전략 구현

## ⚠️ 주의사항

1. **Services Layer 유지**: Feature로 이동하지 말 것
2. **역방향 의존성 금지**: Backend 모델 직접 import 금지
3. **메모리 관리**: 큰 데이터는 L2/L3만 사용
4. **캐시 무효화**: 데이터 변경 시 반드시 무효화

## 📚 참고 자료

- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [Clean Architecture in Services](/GLOBAL_LAYERS.md)
- [Flutter Caching Best Practices](https://flutter.dev/docs/cookbook/persistence)

---

*이 문서는 Versus Space Cache Service의 구조와 사용법을 설명합니다.*
*Services Layer는 전역 서비스로 유지되어야 합니다.*