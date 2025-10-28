# Voting Feature - Data Layer

> **Architecture**: Firebase-Centric Architecture v1.0
> **Migration Date**: 2025-01-20
> **Status**: ✅ Core Migration Complete (100%)

## 📊 개요

Voting Feature의 Data Layer는 **Firebase-Centric Architecture v1.0**을 따릅니다.

### 핵심 원칙

- ✅ **Firebase SDK 직접 사용**: Remote DataSource 추상화 제거
- ✅ **Extension Pattern**: Mapper + DTO 패턴을 Extension으로 대체
- ✅ **Local Cache만 추상화**: SharedPreferences만 인터페이스 분리
- ✅ **Adapter Pattern**: 레거시 필드명 호환성 유지
- ✅ **공유 서비스 통합**: IdempotencyService, ShardUtils 활용

### Creation Feature와의 차이점

| 측면 | Creation (Clean Arch v4.0) | Voting (Firebase-Centric v1.0) |
|------|---------------------------|-------------------------------|
| **DataSource** | ✅ Interface 추상화 (`IPostCreationDataSource`, `IStorageDataSource`) | ❌ Firebase SDK 직접 사용 (Local cache만 추상화) |
| **변환 패턴** | Mapper 클래스 (`/mappers`, 3개) | Extension 메서드 (`/extensions`, 6개) |
| **DTO** | ✅ 전용 DTO (`/dto`, 6개) | ❌ Domain 모델 직접 사용 |
| **레거시 호환** | N/A | ✅ Adapter 패턴 (`/adapters`, 2개) |
| **Repository 수** | 8개 | 2개 |
| **외부 AI 통합** | ✅ 3개 (Perspective, Gemini, Vision) | ❌ 없음 |
| **공유 서비스** | ❌ 없음 | ✅ IdempotencyService, ShardUtils |

### 왜 Firebase-Centric인가?

**Clean Architecture v4.0의 문제점**:
- Remote DataSource 추상화로 인한 보일러플레이트 코드 과다
- Firebase SDK가 안정적이고 변경 가능성 낮음
- Mapper + DTO 패턴으로 인한 중간 레이어 증가
- 테스트에서 Firebase를 모킹하는 것은 여전히 필요

**Firebase-Centric의 장점**:
- 코드 간결성 대폭 향상 (보일러플레이트 50% 감소)
- Extension Pattern으로 직관적인 변환
- Domain 모델 직접 사용으로 레이어 감소
- Local Cache만 추상화하여 테스트 용이성 확보

---

## 🏗️ 전체 구조도

```
lib/features/voting/data/
├── repositories/                           # 2개 - Firebase 직접 사용
│   ├── voting_dialog_repository_impl.dart  # 투표 다이얼로그 Repository
│   └── voting_chat_repository_impl.dart    # 채팅 투표 Repository
├── datasources/
│   ├── i_voting_local_datasource.dart      # Local cache 인터페이스
│   ├── voting_local_datasource_impl.dart   # SharedPreferences 구현
│   └── local/
│       ├── services/                        # 5개 캐시 서비스
│       │   ├── vote_cache_service.dart
│       │   ├── vote_counts_cache_service.dart
│       │   ├── post_voting_cache_service.dart
│       │   ├── vote_state_cache_service.dart
│       │   └── vote_expansion_cache_service.dart
│       └── utils/                           # 2개 유틸리티
│           ├── cache_key_builder.dart
│           └── cache_ttl_manager.dart
├── extensions/                              # 6개 - Mapper 대체
│   ├── firestore_error_extensions.dart
│   ├── post_voting_extensions.dart
│   ├── vote_expansion_request_extensions.dart
│   ├── vote_extensions.dart
│   ├── vote_state_extensions.dart
│   └── weight_extensions.dart
├── adapters/                                # 2개 - Legacy 호환
│   ├── votecounts_adapter.dart             # votesA/B ↔ option1/2
│   └── box_calculator_adapter.dart         # 박스 크기 계산 호환
└── services/                                # 1개 - Feature 전용
    └── vote_timer_service.dart             # 투표 타이머 싱글톤

총 파일 수: 19개
총 라인 수: ~1,851줄
```

---

## 📂 디렉토리별 상세 설명

### 1. repositories/ (2개)

#### 📌 핵심 개념: Firebase-Centric Pattern

**Creation과의 차이점**:
- ❌ `IVotingRemoteDataSource` 제거
- ✅ `FirebaseFirestore` 직접 주입
- ✅ Extension으로 변환 처리
- ✅ 공유 서비스 통합 (IdempotencyService, ShardUtils)

#### 1.1 voting_dialog_repository_impl.dart

**위치**: `lib/features/voting/data/repositories/voting_dialog_repository_impl.dart`

**책임**:
- 투표 다이얼로그에서 발생하는 투표 처리
- Idempotency 보장 (중복 투표 방지)
- Sharded Counter 통합 (256 샤드 분산 카운팅)
- Local cache 동기화
- 투표 결과 실시간 조회

**의존성**:
```dart
class VotingDialogRepositoryImpl implements IVotingDialogRepository {
  final FirebaseFirestore _firestore;            // ✅ Direct Firebase injection
  final IVotingLocalDataSource _localDataSource;  // ✅ Only cache abstracted
  final IdempotencyService _idempotencyService;   // ✅ Shared service
  final ShardUtils _shardUtils;                   // ✅ Shared service
}
```

**주요 메서드**:

##### `castVote()` - 투표 실행
```dart
@override
Future<Either<VotingFailure, void>> castVote({
  required String postId,
  required String userId,
  required String voteOption,
  String? eventId,
}) async {
  try {
    // UUID 자동 생성 (eventId 없을 시)
    final actualEventId = eventId ?? const Uuid().v4();

    // Idempotency + Transaction 보장
    await _idempotencyService.executeIdempotent<void>(
      entityType: 'votes',
      entityId: postId,
      userId: userId,
      eventId: actualEventId,
      operation: (transaction) async {
        final postRef = _firestore.collection('posts').doc(postId);

        // ✅ Firebase 직접 사용
        await postRef.update({
          'votedUserIDs${voteOption.toUpperCase()}':
            FieldValue.arrayUnion([userId]),
          'lastVoteAt': FieldValue.serverTimestamp(),
        });

        // ✅ Sharded Counter 증가
        _shardUtils.incrementShard(
          transaction,
          counterType: 'vote',
          entityId: postId,
          userId: userId,
          field: 'votes${voteOption.toUpperCase()}',
        );

        // votes 서브컬렉션에 투표 기록 생성
        final voteRef = postRef.collection('votes').doc(actualEventId);
        transaction.set(voteRef, {
          'user': _firestore.doc('users/$userId'),
          'option': voteOption,
          'createdAt': FieldValue.serverTimestamp(),
          'eventId': actualEventId,
        });
      },
    );

    // Local cache 업데이트
    await _localDataSource.cacheVoteState(
      postId: postId,
      userId: userId,
      voteState: VoteCacheState(
        hasVoted: true,
        voteOption: voteOption,
        votedAt: DateTime.now(),
      ),
    );

    return right(null);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**핵심 포인트**:
1. **Idempotency 보장**: UUID 기반으로 중복 투표 완전 차단
2. **Transaction 사용**: 모든 작업이 원자적으로 실행
3. **Sharded Counter**: 256개 샤드로 분산 카운팅 (초당 256회 처리)
4. **Extension 활용**: `e.toVotingFailure()`로 에러 변환
5. **Local Cache 동기화**: 즉각적인 UI 반응성 확보

##### `getPostVoting()` - 투표 정보 조회
```dart
@override
Future<Either<VotingFailure, PostVoting>> getPostVoting(String postId) async {
  try {
    // 1. Local cache 확인 (TTL 5분)
    final cached = await _localDataSource.getCachedPostVoting(
      postId,
      maxAge: Duration(minutes: 5),
    );
    if (cached != null) {
      return right(cached);
    }

    // 2. Firestore에서 조회
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) {
      return left(VotingFailure.postNotFound(postId));
    }

    // 3. Extension으로 변환
    final voting = doc.data()!.toPostVoting();

    // 4. Cache 저장
    await _localDataSource.cachePostVoting(voting);

    return right(voting);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**캐싱 전략**:
- TTL 5분으로 최신 데이터 보장
- Cache-Aside 패턴 적용
- Firestore 읽기 비용 최소화

##### `getVoteCounts()` - 투표 수 조회
```dart
@override
Future<Either<VotingFailure, VoteCounts>> getVoteCounts(String postId) async {
  try {
    // 1. Local cache 확인
    final cached = await _localDataSource.getCachedVoteCounts(postId);
    if (cached != null) {
      return right(cached);
    }

    // 2. Firestore에서 조회
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) {
      return left(VotingFailure.postNotFound(postId));
    }

    // 3. Adapter로 변환 (Legacy 필드명 처리)
    final voteCounts = VoteCountsAdapter.fromMap(doc.data()!);

    // 4. Cache 저장
    await _localDataSource.cacheVoteCounts(
      postId: postId,
      voteCounts: voteCounts,
    );

    return right(voteCounts);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**Adapter 사용 이유**:
- Firestore의 레거시 필드명 (`option1`, `option2`)
- Domain 모델의 새 필드명 (`votesA`, `votesB`)
- Adapter가 자동으로 매핑 처리

##### `checkUserVote()` - 사용자 투표 여부 확인
```dart
@override
Future<Either<VotingFailure, String?>> checkUserVote({
  required String postId,
  required String userId,
}) async {
  try {
    // 1. Local cache 확인
    final cached = await _localDataSource.getCachedVoteState(
      postId: postId,
      userId: userId,
    );
    if (cached != null && cached.hasVoted) {
      return right(cached.voteOption);
    }

    // 2. Firestore에서 확인
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) {
      return left(VotingFailure.postNotFound(postId));
    }

    final data = doc.data()!;
    final votedA = (data['votedUserIDsA'] as List?)?.contains(userId) ?? false;
    final votedB = (data['votedUserIDsB'] as List?)?.contains(userId) ?? false;

    String? voteOption;
    if (votedA) voteOption = 'A';
    if (votedB) voteOption = 'B';

    // 3. Cache 저장
    if (voteOption != null) {
      await _localDataSource.cacheVoteState(
        postId: postId,
        userId: userId,
        voteState: VoteCacheState(
          hasVoted: true,
          voteOption: voteOption,
          votedAt: DateTime.now(),
        ),
      );
    }

    return right(voteOption);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**빠른 응답**:
- Local cache 우선 확인
- 네트워크 요청 최소화
- UI 즉시 반응

---

#### 1.2 voting_chat_repository_impl.dart

**위치**: `lib/features/voting/data/repositories/voting_chat_repository_impl.dart`

**책임**:
- 채팅방 내 투표 메시지 처리
- AI 채팅방 투표 카드 상태 관리
- 실시간 투표 결과 동기화
- 채팅 메시지 투표 메타데이터 업데이트

**의존성**:
```dart
class VotingChatRepositoryImpl implements IVotingChatRepository {
  final FirebaseFirestore _firestore;
  final IVotingLocalDataSource _localDataSource;
  final IdempotencyService _idempotencyService;
  final ShardUtils _shardUtils;
}
```

**주요 메서드**:

##### `castVoteFromChat()` - 채팅에서 투표 실행
```dart
@override
Future<Either<VotingFailure, void>> castVoteFromChat({
  required String postId,
  required String chatId,
  required String messageId,
  required String userId,
  required String voteOption,
  String? eventId,
}) async {
  try {
    final actualEventId = eventId ?? const Uuid().v4();

    await _idempotencyService.executeIdempotent<void>(
      entityType: 'votes',
      entityId: postId,
      userId: userId,
      eventId: actualEventId,
      operation: (transaction) async {
        // 1. Post 문서 업데이트
        final postRef = _firestore.collection('posts').doc(postId);
        await postRef.update({
          'votedUserIDs${voteOption.toUpperCase()}':
            FieldValue.arrayUnion([userId]),
        });

        // 2. Sharded Counter
        _shardUtils.incrementShard(
          transaction,
          counterType: 'vote',
          entityId: postId,
          userId: userId,
          field: 'votes${voteOption.toUpperCase()}',
        );

        // 3. Chat message 메타데이터 업데이트
        final messageRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId);

        transaction.update(messageRef, {
          'userVoted': true,
          'voteChoice': voteOption,
          'voteParticipatedAt': FieldValue.serverTimestamp(),
        });

        // 4. votes 서브컬렉션
        final voteRef = postRef.collection('votes').doc(actualEventId);
        transaction.set(voteRef, {
          'user': _firestore.doc('users/$userId'),
          'option': voteOption,
          'createdAt': FieldValue.serverTimestamp(),
          'eventId': actualEventId,
          'fromChat': true,
          'chatId': chatId,
          'messageId': messageId,
        });
      },
    );

    return right(null);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**차별화 포인트**:
- `fromChat: true` 플래그로 채팅 투표 추적
- Chat message 메타데이터 동시 업데이트
- Transaction으로 일관성 보장

##### `updateChatVoteCard()` - 투표 카드 상태 업데이트
```dart
@override
Future<Either<VotingFailure, void>> updateChatVoteCard({
  required String chatId,
  required String messageId,
  required Map<String, dynamic> voteData,
}) async {
  try {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'voteResults': voteData['voteResults'],
      'cardStatus': voteData['cardStatus'],
      'voteEndTime': voteData['voteEndTime'],
      'lastVoteUpdate': FieldValue.serverTimestamp(),
    });

    return right(null);
  } on FirebaseException catch (e) {
    return left(e.toVotingFailure());
  } catch (e) {
    return left(VotingFailure.unknown(e.toString()));
  }
}
```

**실시간 동기화**:
- StreamBuilder와 함께 사용
- 투표 완료 시 자동 카드 상태 변경
- UI 실시간 반영

**TODO 항목** (비필수 기능):
- [ ] Chat 직접 투표 기능 구현 (현재는 다이얼로그 우회)
- [ ] 채팅방별 투표 통계 수집 기능
- [ ] Profile 페이지 네비게이션 통합

---

### 2. datasources/local/ (8개)

#### 📌 핵심 개념: Local Cache만 추상화

**왜 Local만 추상화하나요?**

| 레이어 | 추상화 여부 | 이유 |
|--------|------------|------|
| **Remote (Firebase)** | ❌ 추상화 안 함 | • Firebase SDK가 안정적<br>• 변경 가능성 매우 낮음<br>• 추상화 시 보일러플레이트 과다 |
| **Local (SharedPreferences)** | ✅ 추상화 | • 테스트 용이성 확보<br>• 캐시 전략 변경 유연성<br>• Mock 구현 쉬움 |

**추상화의 가치**:
- ✅ **테스트**: Mock 구현으로 단위 테스트 가능
- ✅ **유연성**: SharedPreferences → Hive 전환 용이
- ✅ **분리**: Repository가 캐시 구현에 의존하지 않음

---

#### 2.1 i_voting_local_datasource.dart (179줄)

**위치**: `lib/features/voting/data/datasources/i_voting_local_datasource.dart`

**인터페이스 전체**:
```dart
/// Local data source interface for voting feature
///
/// This interface defines the contract for local data operations (caching)
/// following the Clean Architecture pattern
abstract class IVotingLocalDataSource {
  // ============================================================================
  // Cache Management
  // ============================================================================

  /// Initialize the data source
  Future<void> initialize();

  /// Clear all cached data
  Future<void> clearCache();

  /// Get total cache size in bytes
  Future<int> getCacheSize();

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  // ============================================================================
  // Vote State Cache
  // ============================================================================

  /// Cache user's vote state for a post
  Future<void> cacheVoteState({
    required String postId,
    required String userId,
    required VoteCacheState voteState,
  });

  /// Get cached vote state for a user and post
  Future<VoteCacheState?> getCachedVoteState({
    required String postId,
    required String userId,
  });

  /// Remove cached vote state
  Future<void> removeCachedVoteState({
    required String postId,
    required String userId,
  });

  // ============================================================================
  // Vote Counts Cache
  // ============================================================================

  /// Cache vote counts for a post
  Future<void> cacheVoteCounts({
    required String postId,
    required VoteCounts voteCounts,
  });

  /// Get cached vote counts for a post
  Future<VoteCounts?> getCachedVoteCounts(String postId);

  /// Remove cached vote counts
  Future<void> removeCachedVoteCounts(String postId);

  // ============================================================================
  // PostVoting Cache Operations
  // ============================================================================

  /// Cache PostVoting entity
  Future<void> cachePostVoting(PostVoting voting);

  /// Get cached PostVoting with optional max age
  Future<PostVoting?> getCachedPostVoting(
    String postId, {
    Duration? maxAge,
  });

  /// Remove cached PostVoting
  Future<void> removeCachedPostVoting(String postId);

  // ============================================================================
  // Vote Expansion Request Cache
  // ============================================================================

  /// Cache vote expansion request
  Future<void> cacheVoteExpansionRequest(VoteExpansionRequest request);

  /// Get cached vote expansion request
  Future<VoteExpansionRequest?> getCachedVoteExpansionRequest(String postId);

  /// Remove cached vote expansion request
  Future<void> removeCachedVoteExpansionRequest(String postId);

  // ============================================================================
  // Weight Cache (Poll Details)
  // ============================================================================

  /// Cache weight data for a poll
  Future<void> cacheWeight({
    required String postId,
    required Weight weight,
  });

  /// Get cached weight data
  Future<Weight?> getCachedWeight(String postId);

  /// Remove cached weight data
  Future<void> removeCachedWeight(String postId);
}
```

**설계 원칙**:
1. **도메인 모델 사용**: DTO 없이 `VoteCounts`, `PostVoting` 등 직접 사용
2. **TTL 지원**: `maxAge` 파라미터로 만료 시간 제어
3. **명확한 네이밍**: `cache*`, `getCached*`, `removeCached*` 패턴
4. **초기화 분리**: `initialize()` 메서드로 명시적 초기화

---

#### 2.2 voting_local_datasource_impl.dart

**위치**: `lib/features/voting/data/datasources/voting_local_datasource_impl.dart`

**구현 개요**:
```dart
class VotingLocalDataSourceImpl implements IVotingLocalDataSource {
  final SharedPreferences _prefs;
  final VoteCacheService _voteCacheService;
  final VoteCountsCacheService _voteCountsCache;
  final PostVotingCacheService _postVotingCache;
  final VoteStateCacheService _voteStateCache;
  final VoteExpansionCacheService _voteExpansionCache;

  // 5개 캐시 서비스에 위임
}
```

**위임 패턴**:
- Interface는 모든 메서드 정의
- Implementation은 각 도메인별 캐시 서비스에 위임
- 캐시 서비스는 실제 SharedPreferences 작업 수행

**예시**:
```dart
@override
Future<void> cacheVoteCounts({
  required String postId,
  required VoteCounts voteCounts,
}) {
  return _voteCountsCache.cacheVoteCounts(
    postId: postId,
    voteCounts: voteCounts,
  );
}
```

---

#### 2.3 local/services/ (5개 캐시 서비스)

각 도메인 모델별 전용 캐시 서비스를 제공합니다.

##### vote_cache_service.dart
**책임**: `Vote` 모델 캐싱
- 개별 투표 기록 저장
- JSON 직렬화/역직렬화
- TTL 관리

##### vote_counts_cache_service.dart
**책임**: `VoteCounts` 모델 캐싱
- 투표 집계 결과 캐싱
- 빠른 조회 지원
- 실시간 업데이트 반영

##### post_voting_cache_service.dart
**책임**: `PostVoting` 모델 캐싱
- 게시물 투표 정보 전체 캐싱
- 가장 자주 조회되는 데이터
- TTL 5분 기본값

##### vote_state_cache_service.dart
**책임**: `VoteState` 모델 캐싱
- 사용자별 투표 상태 캐싱
- 투표 여부 빠른 확인
- UI 반응성 향상

##### vote_expansion_cache_service.dart
**책임**: `VoteExpansionRequest` 모델 캐싱
- 투표 확장 요청 캐싱
- 중복 요청 방지
- 관리자 승인 대기 상태 추적

**공통 패턴**:
```dart
class VoteCacheService {
  final SharedPreferences _prefs;
  final CacheKeyBuilder _keyBuilder;
  final CacheTTLManager _ttlManager;

  Future<void> cache(Vote vote) async {
    final key = _keyBuilder.voteKey(vote.id);
    final json = jsonEncode(vote.toJson());
    await _prefs.setString(key, json);
    await _ttlManager.setTTL(key, Duration(hours: 1));
  }

  Future<Vote?> getCached(String voteId) async {
    final key = _keyBuilder.voteKey(voteId);

    // TTL 체크
    if (!await _ttlManager.isValid(key)) {
      await _prefs.remove(key);
      return null;
    }

    final json = _prefs.getString(key);
    if (json == null) return null;

    return Vote.fromJson(jsonDecode(json));
  }
}
```

---

#### 2.4 local/utils/ (2개 유틸리티)

##### cache_key_builder.dart
**책임**: 일관된 캐시 키 생성

```dart
class CacheKeyBuilder {
  static const _prefix = 'voting_cache';

  String voteKey(String voteId) => '$_prefix:vote:$voteId';

  String voteCountsKey(String postId) => '$_prefix:vote_counts:$postId';

  String postVotingKey(String postId) => '$_prefix:post_voting:$postId';

  String voteStateKey({
    required String postId,
    required String userId,
  }) => '$_prefix:vote_state:$postId:$userId';

  String voteExpansionKey(String postId) =>
      '$_prefix:vote_expansion:$postId';

  String weightKey(String postId) => '$_prefix:weight:$postId';
}
```

**규칙**:
- `voting_cache:` 프리픽스
- 도메인별 네임스페이스
- 복합 키 지원 (postId + userId)

##### cache_ttl_manager.dart
**책임**: TTL (Time To Live) 관리

```dart
class CacheTTLManager {
  final SharedPreferences _prefs;

  Future<void> setTTL(String key, Duration duration) async {
    final expiryTime = DateTime.now().add(duration);
    await _prefs.setInt('${key}_ttl', expiryTime.millisecondsSinceEpoch);
  }

  Future<bool> isValid(String key) async {
    final ttl = _prefs.getInt('${key}_ttl');
    if (ttl == null) return false;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(ttl);
    return DateTime.now().isBefore(expiryTime);
  }

  Future<void> removeTTL(String key) async {
    await _prefs.remove('${key}_ttl');
  }

  Future<void> clearExpired() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.endsWith('_ttl')) continue;
      if (!await isValid(key)) {
        await _prefs.remove(key);
        await removeTTL(key);
      }
    }
  }
}
```

**기능**:
- 캐시별 TTL 설정
- 만료 여부 확인
- 만료 엔트리 일괄 정리

---

### 3. extensions/ (6개)

#### 📌 핵심 개념: Extension Pattern

**Mapper Pattern vs Extension Pattern 비교**:

```dart
// ❌ Creation Feature - Mapper Pattern
class VoteMapper {
  Vote toDomain(VoteDto dto) {
    return Vote(
      userId: dto.userId,
      choice: dto.choice,
      timestamp: dto.timestamp,
    );
  }

  VoteDto toDto(Vote domain) {
    return VoteDto(
      userId: domain.userId,
      choice: domain.choice,
      timestamp: domain.timestamp,
    );
  }
}

// 사용:
final mapper = VoteMapper();
final vote = mapper.toDomain(dto);
final dto = mapper.toDto(vote);

// ✅ Voting Feature - Extension Pattern
extension VoteFirestoreX on Vote {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'choice': choice,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

extension VoteFirestoreMapX on Map<String, dynamic> {
  Vote toVote() {
    return Vote(
      userId: this['userId'] as String,
      choice: this['choice'] as String,
      timestamp: (this['timestamp'] as Timestamp).toDate(),
    );
  }
}

// 사용:
final firestoreData = vote.toFirestore();  // 메서드처럼 호출
final vote = data.toVote();               // 직관적
```

**Extension Pattern의 장점**:
1. ✅ **DTO 제거**: 중간 레이어 불필요
2. ✅ **직관적 사용**: 도메인 모델에서 직접 호출
3. ✅ **코드 간결성**: 별도 Mapper 클래스 불필요
4. ✅ **타입 안전성**: Extension이 타입 체크
5. ✅ **Null Safety**: 변환 로직에서 Null 처리

**단점**:
- ❌ 복잡한 변환 로직은 Mapper가 더 나음
- ❌ 여러 DataSource 지원 시 Extension 중복 가능

---

#### 3.1 vote_extensions.dart

**위치**: `lib/features/voting/data/extensions/vote_extensions.dart`

**전체 코드**:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/voting/domain/entities/vote.dart';

/// Firebase Firestore extension for Vote domain model
///
/// **Firebase Optimization Pattern**
/// Replaces VoteDto + VoteMapper pattern with direct conversion.
/// This eliminates intermediate layers while maintaining clean separation.
///
/// See: /features/voting/data/models/vote_dto.dart (deleted)
/// See: /features/voting/data/mappers/vote_mapper.dart (deleted)
extension VoteFirestoreX on Vote {
  /// Convert Vote to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'choice': choice,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

extension VoteFirestoreMapX on Map<String, dynamic> {
  /// Convert Firestore map to Vote domain model
  Vote toVote() {
    return Vote(
      userId: this['userId'] as String,
      choice: this['choice'] as String,
      timestamp: (this['timestamp'] as Timestamp).toDate(),
    );
  }
}
```

**사용 예시**:
```dart
// Repository에서 사용
final vote = Vote(
  userId: 'user123',
  choice: 'A',
  timestamp: DateTime.now(),
);

// Firestore에 저장
await _firestore.collection('votes').add(vote.toFirestore());

// Firestore에서 조회
final doc = await _firestore.collection('votes').doc(voteId).get();
final vote = doc.data()!.toVote();
```

---

#### 3.2 post_voting_extensions.dart

**위치**: `lib/features/voting/data/extensions/post_voting_extensions.dart`

**책임**: `PostVoting` 모델 Firestore 변환

**주요 변환 로직**:
```dart
extension PostVotingFirestoreX on PostVoting {
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'votedUserIDsA': votedUserIDsA,
      'votedUserIDsB': votedUserIDsB,
      'voteStartTime': voteStartTime != null
          ? Timestamp.fromDate(voteStartTime!)
          : null,
      'voteEndTime': voteEndTime != null
          ? Timestamp.fromDate(voteEndTime!)
          : null,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
    };
  }
}

extension PostVotingFirestoreMapX on Map<String, dynamic> {
  PostVoting toPostVoting() {
    return PostVoting(
      postId: this['postId'] as String,
      votedUserIDsA: (this['votedUserIDsA'] as List?)
          ?.map((e) => e as String)
          .toList() ?? [],
      votedUserIDsB: (this['votedUserIDsB'] as List?)
          ?.map((e) => e as String)
          .toList() ?? [],
      voteStartTime: (this['voteStartTime'] as Timestamp?)?.toDate(),
      voteEndTime: (this['voteEndTime'] as Timestamp?)?.toDate(),
      voteStatus: this['voteStatus'] as String?,
      voteCompleted: this['voteCompleted'] as bool? ?? false,
    );
  }
}
```

**특징**:
- Null safety 완벽 처리
- List 타입 안전 변환
- Timestamp ↔ DateTime 자동 변환
- Optional 필드 기본값 제공

---

#### 3.3 vote_state_extensions.dart

**위치**: `lib/features/voting/data/extensions/vote_state_extensions.dart`

**책임**: `VoteState` 모델 Firestore 변환 (UI 상태 관리)

---

#### 3.4 vote_expansion_request_extensions.dart

**위치**: `lib/features/voting/data/extensions/vote_expansion_request_extensions.dart`

**책임**: `VoteExpansionRequest` 모델 Firestore 변환 (투표 기간 연장 요청)

---

#### 3.5 weight_extensions.dart

**위치**: `lib/features/voting/data/extensions/weight_extensions.dart`

**책임**: `Weight` 모델 Firestore 변환 (투표 가중치 데이터)

---

#### 3.6 firestore_error_extensions.dart

**위치**: `lib/features/voting/data/extensions/firestore_error_extensions.dart`

**책임**: `FirebaseException` → `VotingFailure` 변환

**전체 코드**:
```dart
import 'package:firebase_core/firebase_core.dart';
import '/features/voting/domain/failures/voting_failure.dart';

/// Firebase Exception extension for error handling
extension FirebaseExceptionX on FirebaseException {
  /// Convert FirebaseException to VotingFailure
  VotingFailure toVotingFailure() {
    switch (code) {
      case 'permission-denied':
        return VotingFailure.permissionDenied(message ?? 'Permission denied');
      case 'not-found':
        return VotingFailure.notFound(message ?? 'Document not found');
      case 'already-exists':
        return VotingFailure.alreadyExists(message ?? 'Already exists');
      case 'unavailable':
        return VotingFailure.networkError(message ?? 'Network unavailable');
      case 'deadline-exceeded':
        return VotingFailure.timeout(message ?? 'Request timeout');
      default:
        return VotingFailure.unknown(message ?? 'Unknown Firebase error');
    }
  }
}
```

**사용 예시**:
```dart
try {
  await _firestore.collection('posts').doc(postId).get();
} on FirebaseException catch (e) {
  return left(e.toVotingFailure());  // Extension 사용
}
```

**장점**:
- Firebase 에러 코드를 Domain 에러로 자동 매핑
- 에러 처리 로직 중앙화
- 타입 안전한 에러 변환

---

### 4. adapters/ (2개)

#### 📌 핵심 개념: Legacy 호환성 유지

Firestore의 **레거시 필드명**과 **Domain 모델의 새 필드명** 간 변환을 담당합니다.

**왜 Adapter가 필요한가?**
- Firestore에는 오래된 필드명이 저장되어 있음 (`option1`, `option2`)
- Domain 모델은 새 필드명 사용 (`votesA`, `votesB`)
- 기존 데이터 마이그레이션 없이 호환성 유지

---

#### 4.1 votecounts_adapter.dart

**위치**: `lib/features/voting/data/adapters/votecounts_adapter.dart`

**Legacy 필드 매핑**:
```
Firestore (Legacy)  →  Domain (New)
option1             →  votesA
option2             →  votesB
```

**전체 코드**:
```dart
import '/features/voting/domain/entities/vote_counts.dart';

/// Adapter for converting between Firestore data and VoteCounts domain model
///
/// This adapter handles conversion between Firestore Map data and
/// the clean VoteCounts domain model following Clean Architecture principles
///
/// **Legacy Field Mapping**:
/// - Firestore: option1, option2
/// - Domain: votesA, votesB
class VoteCountsAdapter {
  /// Convert VoteCounts domain model to Firestore map (Legacy)
  ///
  /// Maps votesA -> option1 and votesB -> option2 for backward compatibility
  static Map<String, dynamic> toFirestore(VoteCounts domain) {
    return {
      'option1': domain.votesA,
      'option2': domain.votesB,
    };
  }

  /// Convert Firestore map to VoteCounts domain model
  ///
  /// Maps option1 -> votesA and option2 -> votesB with safe type conversion
  static VoteCounts fromMap(Map<String, dynamic> data) {
    return VoteCounts(
      votesA: _safeInt(data['option1']),
      votesB: _safeInt(data['option2']),
    );
  }

  /// Safe integer conversion with fallback to 0
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
```

**사용 예시**:
```dart
// Repository에서 사용
class VotingDialogRepositoryImpl {
  Future<Either<VotingFailure, VoteCounts>> getVoteCounts(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();

    // Adapter로 변환
    final voteCounts = VoteCountsAdapter.fromMap(doc.data()!);

    return right(voteCounts);
  }

  Future<void> updateVoteCounts(String postId, VoteCounts counts) async {
    // Adapter로 변환
    await _firestore
        .collection('posts')
        .doc(postId)
        .update(VoteCountsAdapter.toFirestore(counts));
  }
}
```

**타입 안전성**:
- `_safeInt()` 메서드로 모든 숫자 타입 처리
- Null → 0 변환
- String → int 파싱
- 에러 발생 시 0 반환

---

#### 4.2 box_calculator_adapter.dart

**위치**: `lib/features/voting/data/adapters/box_calculator_adapter.dart`

**책임**: `BoxSizes` 계산 로직의 레거시 호환성 유지

**Legacy 로직**:
- 이전 버전의 박스 크기 계산 알고리즘 유지
- UI 깨짐 방지
- 점진적 마이그레이션 지원

**구조**:
```dart
class BoxCalculatorAdapter {
  /// Calculate box sizes using legacy algorithm
  static BoxSizes calculateLegacy({
    required double containerWidth,
    required bool isHorizontal,
    required double? aspectRatioA,
    required double? aspectRatioB,
  }) {
    // Legacy calculation logic...
  }

  /// Check if should use legacy algorithm
  static bool shouldUseLegacy(String postId) {
    // Posts created before migration date
    return postId.contains('legacy');
  }
}
```

---

### 5. services/ (1개)

#### 5.1 vote_timer_service.dart

**위치**: `lib/features/voting/data/services/vote_timer_service.dart`

#### 📌 핵심 개념: 싱글톤 타이머 동기화

**문제점**:
- 동일한 투표 카드가 여러 곳에 표시 (채팅, 피드, 알림)
- 각 위젯이 독립적인 Timer 생성 → 시간 불일치
- 위젯 재생성 시 Timer 리셋 → 깜빡임

**해결책**: 싱글톤 패턴으로 postId별 단일 Timer 관리

**아키텍처**:
```
VoteCardMessage (Widget 1)  ─┐
VoteCardMessage (Widget 2)  ─┼─→ VoteTimerService (Singleton)
VoteCardMessage (Widget 3)  ─┘         │
                                        ├─ Timer (postId: 'abc')
                                        ├─ Timer (postId: 'def')
                                        └─ Timer (postId: 'ghi')
                                              │
                                              ↓
                                        StreamController
                                              │
                                  ┌───────────┴───────────┐
                                  ↓                       ↓
                            Widget 1-3            Widget 1-3
                            (Subscribe)           (Subscribe)
```

**주요 기능**:

##### 1. postId별 Timer 관리
```dart
class VoteTimerService {
  static final VoteTimerService _instance = VoteTimerService._internal();
  static VoteTimerService get instance => _instance;

  // postId별 Timer 저장
  final Map<String, Timer> _timers = {};

  // postId별 StreamController
  final Map<String, StreamController<Duration>> _controllers = {};

  // 캐시된 남은 시간
  final Map<String, Duration> _cachedRemainingTimes = {};
}
```

##### 2. Timer 시작
```dart
void startTimer({
  required String postId,
  required DateTime voteEndTime,
}) {
  // 이미 실행 중이면 무시
  if (_timers.containsKey(postId)) return;

  // StreamController 생성
  _controllers[postId] = StreamController<Duration>.broadcast();

  // Timer 시작 (1초 간격)
  _timers[postId] = Timer.periodic(Duration(seconds: 1), (timer) {
    final remaining = voteEndTime.difference(_synchronizedNow);

    // 남은 시간 캐싱
    _cachedRemainingTimes[postId] = remaining;

    if (remaining.isNegative) {
      stopTimer(postId);
      _controllers[postId]?.add(Duration.zero);
    } else {
      _controllers[postId]?.add(remaining);
    }
  });

  // 즉시 한 번 실행
  final initial = voteEndTime.difference(_synchronizedNow);
  _cachedRemainingTimes[postId] = initial;
  _controllers[postId]?.add(initial);
}
```

##### 3. Stream 구독
```dart
Stream<Duration> getTimerStream(String postId) {
  // StreamController가 없으면 생성
  if (!_controllers.containsKey(postId)) {
    _controllers[postId] = StreamController<Duration>.broadcast();
  }

  // 캐시된 시간 즉시 반환 (깜빡임 방지)
  if (_cachedRemainingTimes.containsKey(postId)) {
    Future.microtask(() {
      _controllers[postId]?.add(_cachedRemainingTimes[postId]!);
    });
  }

  return _controllers[postId]!.stream;
}
```

##### 4. 서버 시간 동기화
```dart
DateTime? _serverTimeOffset;
DateTime? _lastSyncTime;

/// Get synchronized current time using server offset
DateTime get _synchronizedNow {
  if (_serverTimeOffset != null) {
    return DateTime.now().add(_serverTimeOffset!);
  }
  return DateTime.now();
}

/// Sync server time using Firestore timestamp
Future<void> syncServerTime() async {
  // 5분 이내 동기화했으면 스킵
  if (_lastSyncTime != null &&
      DateTime.now().difference(_lastSyncTime!) < Duration(minutes: 5)) {
    return;
  }

  try {
    final now = DateTime.now();

    // Firestore에 임시 문서 생성
    final doc = await FirebaseFirestore.instance
        .collection('time_sync')
        .add({'timestamp': FieldValue.serverTimestamp()});

    // 서버 시간 조회
    final snapshot = await doc.get();
    final serverTime = (snapshot.data()!['timestamp'] as Timestamp).toDate();

    // 네트워크 지연 보정
    final roundTripTime = DateTime.now().difference(now);
    final estimatedServerTime = serverTime.add(roundTripTime ~/ 2);

    // 오프셋 계산
    _serverTimeOffset = estimatedServerTime.difference(DateTime.now());
    _lastSyncTime = DateTime.now();

    // 임시 문서 삭제
    await doc.delete();
  } catch (e) {
    print('[VoteTimerService] Server time sync failed: $e');
  }
}
```

##### 5. 메모리 정리
```dart
void stopTimer(String postId) {
  _timers[postId]?.cancel();
  _timers.remove(postId);
  _controllers[postId]?.close();
  _controllers.remove(postId);
  _cachedRemainingTimes.remove(postId);
}

void dispose() {
  _timers.forEach((_, timer) => timer.cancel());
  _timers.clear();
  _controllers.forEach((_, controller) => controller.close());
  _controllers.clear();
  _cachedRemainingTimes.clear();
}
```

**사용 예시**:
```dart
// VoteCardMessage에서 사용
class _VoteCardMessageState extends State<VoteCardMessage> {
  Duration? _remainingTime;
  StreamSubscription<Duration>? _timerSubscription;

  @override
  void initState() {
    super.initState();

    // 서버 시간 동기화
    VoteTimerService.instance.syncServerTime();

    // Timer 시작
    VoteTimerService.instance.startTimer(
      postId: widget.postId,
      voteEndTime: widget.voteEndTime,
    );

    // Stream 구독
    _timerSubscription = VoteTimerService.instance
        .getTimerStream(widget.postId)
        .listen((remaining) {
      setState(() => _remainingTime = remaining);
    });
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }
}
```

**장점**:
1. ✅ **시간 동기화**: 모든 투표 카드가 동일한 시간 표시
2. ✅ **메모리 효율**: Timer 인스턴스 N개 → 1개
3. ✅ **캐싱**: 캐시된 시간으로 깜빡임 방지
4. ✅ **서버 동기화**: 네트워크 지연 보정
5. ✅ **자동 정리**: Timer 종료 시 메모리 해제

---

## 🔥 Firebase-Centric Architecture v1.0

### 핵심 설계 원칙

#### 1. Firebase SDK 직접 사용

**Creation Feature (Clean Architecture v4.0)**:
```dart
// ❌ DataSource 추상화
abstract class IPostCreationDataSource {
  Future<PostDto> createPost(PostDto dto);
}

class FirebasePostCreationDataSource implements IPostCreationDataSource {
  final FirebaseFirestore _firestore;

  @override
  Future<PostDto> createPost(PostDto dto) async {
    final doc = await _firestore.collection('posts').add(dto.toJson());
    return dto.copyWith(id: doc.id);
  }
}

// Repository는 DataSource에 의존
class PostCreationRepositoryImpl {
  final IPostCreationDataSource _dataSource;

  Future<Either<Failure, Post>> create(Post post) async {
    final dto = PostMapper.toDto(post);
    final resultDto = await _dataSource.createPost(dto);
    return right(PostMapper.toDomain(resultDto));
  }
}
```

**Voting Feature (Firebase-Centric v1.0)**:
```dart
// ✅ Firebase 직접 사용
class VotingDialogRepositoryImpl {
  final FirebaseFirestore _firestore;  // Direct injection

  Future<Either<VotingFailure, void>> castVote(...) async {
    // Extension으로 변환
    await _firestore.collection('posts').doc(postId).update(
      vote.toFirestore(),  // Extension method
    );
    return right(null);
  }
}
```

**비교**:
| Creation | Voting |
|----------|--------|
| IDataSource → Implementation → Repository | Repository → Firebase |
| 3 레이어 | 1 레이어 |
| Mapper + DTO 필요 | Extension만 필요 |
| 보일러플레이트 많음 | 코드 간결함 |

---

#### 2. Extension Pattern

**Creation Feature (Mapper Pattern)**:
```dart
// Mapper 클래스
class VoteMapper {
  Vote toDomain(VoteDto dto) {
    return Vote(
      userId: dto.userId,
      choice: dto.choice,
      timestamp: dto.timestamp,
    );
  }

  VoteDto toDto(Vote domain) {
    return VoteDto(
      userId: domain.userId,
      choice: domain.choice,
      timestamp: domain.timestamp,
    );
  }
}

// DTO 클래스
class VoteDto {
  final String userId;
  final String choice;
  final DateTime timestamp;

  VoteDto({required this.userId, required this.choice, required this.timestamp});

  factory VoteDto.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}

// 사용
final mapper = VoteMapper();
final vote = mapper.toDomain(dto);
final dto = mapper.toDto(vote);
```

**Voting Feature (Extension Pattern)**:
```dart
// Extension
extension VoteFirestoreX on Vote {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'choice': choice,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

extension VoteFirestoreMapX on Map<String, dynamic> {
  Vote toVote() {
    return Vote(
      userId: this['userId'] as String,
      choice: this['choice'] as String,
      timestamp: (this['timestamp'] as Timestamp).toDate(),
    );
  }
}

// 사용 (훨씬 직관적)
final firestoreData = vote.toFirestore();
final vote = data.toVote();
```

---

#### 3. Local Cache만 추상화

**왜 Remote는 추상화 안 하나요?**

| 레이어 | 추상화 | 이유 |
|--------|-------|------|
| **Remote (Firebase)** | ❌ | • Firebase SDK 안정적<br>• 변경 가능성 매우 낮음<br>• 추상화 시 보일러플레이트 과다<br>• 테스트는 여전히 Mock 필요 |
| **Local (SharedPreferences)** | ✅ | • 캐시 구현체 변경 가능 (Hive 등)<br>• Mock 구현 간단<br>• 테스트 용이성 확보 |

**추상화 예시**:
```dart
// ✅ Local은 추상화
abstract class IVotingLocalDataSource {
  Future<VoteCounts?> getCachedVoteCounts(String postId);
}

class VotingLocalDataSourceImpl implements IVotingLocalDataSource {
  final SharedPreferences _prefs;

  @override
  Future<VoteCounts?> getCachedVoteCounts(String postId) async {
    // SharedPreferences 구체적 구현
  }
}

// ❌ Remote는 추상화 안 함
class VotingDialogRepositoryImpl {
  final FirebaseFirestore _firestore;  // 직접 주입
  final IVotingLocalDataSource _localDataSource;  // 추상화
}
```

---

#### 4. 공유 서비스 통합

**Creation**: 각 Feature가 독립적으로 구현
**Voting**: 공유 서비스 활용 (IdempotencyService, ShardUtils)

```dart
class VotingDialogRepositoryImpl {
  final FirebaseFirestore _firestore;
  final IVotingLocalDataSource _localDataSource;
  final IdempotencyService _idempotencyService;  // ✅ Shared
  final ShardUtils _shardUtils;                  // ✅ Shared

  Future<Either<VotingFailure, void>> castVote(...) async {
    await _idempotencyService.executeIdempotent<void>(
      operation: (transaction) async {
        // Firestore 작업
        _shardUtils.incrementShard(transaction, ...);
      },
    );
  }
}
```

---

## 🔗 공유 서비스 통합 가이드

### IdempotencyService

**위치**: `/lib/core/utils/idempotency_service.dart`

**목적**: UUID 기반 중복 요청 방지

**내부 동작**:
1. `eventId` (UUID) 생성
2. Firestore `idempotency` 컬렉션에 키 저장
3. 중복 요청 시 자동 차단
4. Transaction 보장

**사용 예시**:
```dart
await _idempotencyService.executeIdempotent<void>(
  entityType: 'votes',       // 엔티티 타입
  entityId: postId,          // 엔티티 ID
  userId: userId,            // 사용자 ID
  eventId: eventId,          // UUID (자동 생성 가능)
  operation: (transaction) async {
    // Transaction 내에서 Firestore 작업
    await _firestore.collection('posts').doc(postId).update(...);
  },
);
```

**Idempotency 키 구조**:
```
idempotency/{entityType}_{entityId}_{userId}_{eventId}
```

**TTL**: 24시간 후 자동 삭제

---

### ShardUtils

**위치**: `/lib/core/utils/shard_utils.dart`

**목적**: 분산 카운팅으로 Firestore 쓰기 제한 극복

**문제점**:
- Firestore 문서당 최대 쓰기 속도: **1회/초**
- 투표 수 업데이트가 병목

**해결책**:
- **256개 샤드**로 카운터 분산
- 각 샤드: 1회/초 → 총 **256회/초** 처리 가능
- FNV-1a 해시로 균등 분산

**아키텍처**:
```
User Vote
    ↓
ShardUtils.incrementShard()
    ↓
FNV-1a Hash (userId) → shardId (0-255)
    ↓
counters/vote_{postId}/shards/shard_{0-255}
    ↓
Cloud Function (incrementCounter)
    ↓
posts/{postId} 문서에 집계
```

**사용 예시**:
```dart
_shardUtils.incrementShard(
  transaction,
  counterType: 'vote',      // 카운터 타입
  entityId: postId,         // 엔티티 ID
  userId: userId,           // 사용자 ID (샤드 결정)
  field: 'votesA',          // 증가할 필드
  incrementBy: 1,           // 증가량 (기본 1)
);
```

**내부 동작**:
```dart
// 1. userId → shardId 계산
final shardId = stableShardId(userId);  // FNV-1a 해시

// 2. Firestore 경로
counters/vote_{postId}/shards/shard_{shardId}

// 3. FieldValue.increment()
transaction.set(
  shardRef,
  {
    'votesA': FieldValue.increment(1),
    'lastUpdated': FieldValue.serverTimestamp(),
  },
  SetOptions(merge: true),
);

// 4. Cloud Function이 자동으로 집계
```

**Cloud Function**:
```javascript
// firebase/functions/voting/incrementCounter.js
exports.incrementCounter = functions.firestore
  .document('counters/{counterId}/shards/{shardId}')
  .onWrite(async (change, context) => {
    const counterId = context.params.counterId;

    // 모든 샤드 합계 계산
    const shardsSnapshot = await admin.firestore()
      .collection('counters')
      .doc(counterId)
      .collection('shards')
      .get();

    let total = 0;
    shardsSnapshot.forEach(doc => {
      total += doc.data().votesA || 0;
    });

    // posts 문서에 집계
    await admin.firestore()
      .collection('posts')
      .doc(postId)
      .update({ votesA: total });
  });
```

---

## 📊 의존성 다이어그램

```
┌──────────────────────────────────────────────────────────┐
│  Domain Layer                                             │
│  ├─ entities/ (Vote, VoteCounts, PostVoting, ...)       │
│  ├─ repositories/ (IVotingDialogRepository, ...)        │
│  └─ failures/ (VotingFailure)                           │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  Data Layer                                               │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  VotingDialogRepositoryImpl                      │    │
│  │  ├─ FirebaseFirestore (Direct)                  │    │
│  │  ├─ IVotingLocalDataSource (Abstracted)        │    │
│  │  ├─ IdempotencyService (Shared)                │    │
│  │  └─ ShardUtils (Shared)                        │    │
│  └─────────────────────────────────────────────────┘    │
│            ↓                    ↓                         │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │  Extensions       │  │  Adapters         │            │
│  │  (6 files)       │  │  (2 files)        │            │
│  │                  │  │                  │            │
│  │  Vote            │  │  VoteCounts      │            │
│  │  PostVoting      │  │  BoxCalculator   │            │
│  │  VoteState       │  │                  │            │
│  │  Weight          │  │                  │            │
│  │  VoteExpansion   │  │                  │            │
│  │  FirestoreError  │  │                  │            │
│  └──────────────────┘  └──────────────────┘            │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  IVotingLocalDataSource                         │    │
│  │  ├─ VotingLocalDataSourceImpl                  │    │
│  │  └─ local/                                     │    │
│  │      ├─ services/ (5 cache services)          │    │
│  │      └─ utils/ (CacheKeyBuilder, TTLManager)  │    │
│  └─────────────────────────────────────────────────┘    │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  VoteTimerService (Singleton)                   │    │
│  │  ├─ Timer (postId별)                           │    │
│  │  ├─ StreamController                           │    │
│  │  └─ Server Time Sync                           │    │
│  └─────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  Core Layer (Shared Services)                            │
│  ├─ IdempotencyService                                  │
│  └─ ShardUtils                                          │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│  Firebase (Direct)                                        │
│  ├─ FirebaseFirestore                                   │
│  ├─ SharedPreferences                                   │
│  └─ Cloud Functions                                     │
└──────────────────────────────────────────────────────────┘
```

**의존성 흐름**:
1. **Domain → Data**: Repository Interface → Implementation
2. **Data → Extensions**: Entity → Firestore Map 변환
3. **Data → Adapters**: Legacy 필드 호환
4. **Data → Firebase**: 직접 사용 (추상화 없음)
5. **Data → Shared Services**: IdempotencyService, ShardUtils

---

## 🔧 트러블슈팅

### 1. "User already voted" 에러

**증상**:
- 투표 시도 시 `VotingFailure.alreadyVoted` 에러
- 실제로는 투표하지 않았는데 에러 발생

**원인**:
- Idempotency 키 중복
- 동일한 `eventId`로 재시도

**해결 방법**:

**Option 1: eventId 생략** (권장)
```dart
// ✅ eventId 없이 호출 → 자동 UUID 생성
await repository.castVote(
  postId: postId,
  userId: userId,
  voteOption: 'A',
  // eventId 생략
);
```

**Option 2: 새 eventId 생성**
```dart
// 재시도 시 새 eventId 생성
await repository.castVote(
  postId: postId,
  userId: userId,
  voteOption: 'A',
  eventId: Uuid().v4(),  // 새 UUID
);
```

**Option 3: Idempotency 캐시 삭제**
```dart
// 강제로 재투표 허용 (테스트용)
await FirebaseFirestore.instance
    .collection('idempotency')
    .doc('votes_${postId}_${userId}_${oldEventId}')
    .delete();
```

---

### 2. VoteCounts 불일치

**증상**:
- UI에 표시되는 투표 수가 실제와 다름
- `votesA`와 `votesB`가 샤드 합계와 불일치

**원인**:
- Sharded Counter의 Cloud Function 미실행
- 네트워크 지연으로 집계 지연
- Cloud Function 에러

**확인 방법**:

**1. Cloud Function 로그 확인**
```bash
firebase functions:log --only incrementCounter
```

**2. 샤드 직접 조회**
```dart
final shardUtils = ShardUtils();
final totals = await shardUtils.aggregateShards(
  counterType: 'vote',
  entityId: postId,
);
print('Shard totals: $totals');
```

**3. posts 문서와 비교**
```dart
final doc = await FirebaseFirestore.instance
    .collection('posts')
    .doc(postId)
    .get();
print('Post votesA: ${doc.data()!['votesA']}');
```

**해결 방법**:

**Option 1: flushThrottleQueue 수동 실행**
```bash
# Firebase Console에서 Cloud Function 수동 실행
flushThrottleQueue
```

**Option 2: Cloud Function 재배포**
```bash
cd firebase/functions
npm run deploy
```

**Option 3: 직접 집계 (임시)**
```dart
final totals = await shardUtils.aggregateShards(
  counterType: 'vote',
  entityId: postId,
);

await FirebaseFirestore.instance
    .collection('posts')
    .doc(postId)
    .update({
  'votesA': totals['votesA'],
  'votesB': totals['votesB'],
});
```

---

### 3. 캐시 TTL 만료 후 성능 저하

**증상**:
- 초기 로딩은 빠름
- 5분 후 성능 급격히 저하
- Firestore 읽기 비용 증가

**원인**:
- Local cache TTL 만료 (기본 5분)
- 캐시 미스로 인한 Firestore 직접 호출

**해결 방법**:

**Option 1: TTL 연장**
```dart
final voting = await _localDataSource.getCachedPostVoting(
  postId,
  maxAge: Duration(minutes: 10),  // 기본 5분 → 10분
);
```

**Option 2: Preloading 전략**
```dart
// 앱 시작 시 인기 게시물 프리로드
class PreloadService {
  Future<void> preloadPopularPosts() async {
    final popularPosts = await _getPopularPostIds();

    for (final postId in popularPosts) {
      await _repository.getPostVoting(postId);  // Cache 워밍업
    }
  }
}
```

**Option 3: Background Sync**
```dart
// 주기적으로 캐시 업데이트
Timer.periodic(Duration(minutes: 3), (timer) async {
  final activePosts = _getActivePosts();

  for (final postId in activePosts) {
    await _repository.getPostVoting(postId);
  }
});
```

---

### 4. 투표 타이머 불일치

**증상**:
- 동일 투표 카드가 다른 남은 시간 표시
- 위젯 재생성 시 타이머 리셋

**원인**:
- 각 위젯이 독립적인 Timer 생성
- 로컬 시간 사용 (서버 시간 불일치)

**해결 방법**:

**Option 1: VoteTimerService 사용** (권장)
```dart
// Singleton Timer 사용
VoteTimerService.instance.startTimer(
  postId: widget.postId,
  voteEndTime: widget.voteEndTime,
);

_timerSubscription = VoteTimerService.instance
    .getTimerStream(widget.postId)
    .listen((remaining) {
  setState(() => _remainingTime = remaining);
});
```

**Option 2: 서버 시간 동기화**
```dart
// 앱 시작 시 한 번 동기화
await VoteTimerService.instance.syncServerTime();
```

**Option 3: Timer 재시작 방지**
```dart
@override
void didUpdateWidget(VoteCardMessage oldWidget) {
  super.didUpdateWidget(oldWidget);

  // postId나 voteEndTime이 변경된 경우만 재시작
  if (oldWidget.postId != widget.postId ||
      oldWidget.voteEndTime != widget.voteEndTime) {
    VoteTimerService.instance.stopTimer(oldWidget.postId);
    VoteTimerService.instance.startTimer(
      postId: widget.postId,
      voteEndTime: widget.voteEndTime,
    );
  }
}
```

---

### 5. Extension 메서드 충돌

**증상**:
- `toFirestore()` 메서드 중복 정의 에러
- 여러 Extension이 동일 메서드 제공

**원인**:
- 여러 Extension을 동시에 import
- 동일한 타입에 대한 Extension 중복

**해결 방법**:

**Option 1: show/hide 사용**
```dart
import 'vote_extensions.dart' show VoteFirestoreX;
import 'post_voting_extensions.dart' hide PostVotingFirestoreX;
```

**Option 2: as 별칭 사용**
```dart
import 'vote_extensions.dart' as vote_ext;

// 사용
final data = vote_ext.toFirestore(vote);
```

**Option 3: Extension 이름 명시**
```dart
// Extension에 고유 이름 부여
extension VoteToFirestore on Vote {
  Map<String, dynamic> toFirestoreVote() { ... }
}

extension PostVotingToFirestore on PostVoting {
  Map<String, dynamic> toFirestorePostVoting() { ... }
}
```

---

## 📚 참고 자료

### 관련 문서
- [Voting Feature 개요](/lib/features/voting/README.md)
- [Domain Layer 상세](/lib/features/voting/domain/README.md)
- [Presentation Layer 상세](/lib/features/voting/presentation/README.md)
- [Firebase-Centric Architecture 가이드](/docs/architecture/FIREBASE_CENTRIC.md)
- [Migration History](/docs/migration/VOTING_MIGRATION.md)

### 외부 링크
- [Firebase Firestore 공식 문서](https://firebase.google.com/docs/firestore)
- [Dart Extension Methods](https://dart.dev/guides/language/extension-methods)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Sharded Counter Pattern](https://firebase.google.com/docs/firestore/solutions/counters)

---

## 📝 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| 2025-01-20 | v1.0 | • Initial Firebase-Centric migration<br>• Remove IVotingRemoteDataSource<br>• Implement Extension Pattern<br>• Integrate IdempotencyService & ShardUtils |
| 2025-01-21 | v1.1 | • Add VoteTimerService singleton<br>• Server time sync implementation<br>• Memory leak fixes |
| 2025-01-22 | v1.2 | • Complete README documentation<br>• Add troubleshooting guide<br>• Update dependency diagrams |

---

**Last Updated**: 2025-01-22
**Maintainer**: Voting Feature Team
**Architecture**: Firebase-Centric Architecture v1.0
