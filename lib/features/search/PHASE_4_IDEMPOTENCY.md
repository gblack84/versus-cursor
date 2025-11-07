# Search Feature - Phase 4: Idempotency Pattern (Guide Only)

> **마이그레이션 가이드**: Idempotency 패턴 이해 및 적용 가이드 (구현은 선택)
> **난이도**: ⭐⭐☆☆☆ (초중급 - 개념 이해)
> **예상 소요 시간**: 1시간 (문서 읽기)
> **작성일**: 2025-11-07
> **구현 상태**: 📘 **Guide Only** (실제 구현은 updateRankings() TODO 완료 후)

---

## 📋 개요

### Phase 4의 목적

Search Feature에서 Idempotency 패턴의 **개념 이해** 및 **필요성 파악**:

1. **Idempotency 개념**: 동일한 작업을 여러 번 실행해도 결과가 같음을 보장
2. **중복 방지**: 네트워크 재시도로 인한 중복 작업 방지
3. **데이터 일관성**: Rankings 업데이트 시 원자성 보장
4. **구현 가이드**: 실제 구현 시 참고할 패턴 제시

### Search Feature의 Idempotency 필요성

| 작업 | 중복 가능성 | Idempotency 필요 | 구현 상태 |
|------|------------|----------------|----------|
| **updateRankings()** | ⭐⭐⭐ 높음 | ✅ 필요 | ⚠️ TODO |
| **queryRankings()** | ❌ 없음 | ❌ 불필요 | ✅ 읽기 작업 |
| **searchPosts()** | ❌ 없음 | ❌ 불필요 | ⚠️ TODO (Algolia) |
| **searchUsers()** | ❌ 없음 | ❌ 불필요 | ⚠️ TODO (Algolia) |
| **saveSearchHistory()** | ⭐⭐ 중간 | ✅ 권장 | ⚠️ TODO |

**결론**: Search Feature는 주로 **읽기 작업**이라 Idempotency 필요성이 낮음. `updateRankings()`와 `saveSearchHistory()` 구현 시에만 적용하면 충분.

---

## 🎯 Idempotency 개념 이해

### 1. Idempotency란?

> **멱등성 (Idempotency)**: 동일한 작업을 여러 번 실행해도 첫 번째 실행 결과와 동일한 결과를 보장하는 속성

**수학적 정의**:
```
f(f(x)) = f(x)
```

**프로그래밍 예시**:
```dart
/// ✅ Idempotent: 여러 번 실행해도 같은 결과
void setRankingScore(String postId, int score) {
  rankings[postId] = score; // 항상 score로 설정됨
}

/// ❌ Not Idempotent: 실행 횟수에 따라 결과 다름
void incrementRankingScore(String postId, int delta) {
  rankings[postId] += delta; // 매번 증가함
}
```

### 2. 왜 필요한가?

**시나리오: Rankings 업데이트 중복 실행**

```
1. Cloud Function: "Update Rankings" 트리거 발생
2. Rankings 계산 시작... (3초 소요)
3. 네트워크 타임아웃 발생 (응답 없음)
4. Firebase Functions 자동 재시도
5. 동일한 작업이 2번 실행됨 ❌

결과:
- Idempotency 없음: Rankings가 2배로 증가 (버그)
- Idempotency 있음: 동일한 결과 (정상)
```

### 3. Idempotency 구현 방법

#### 방법 1: UUID 기반 Idempotency Key

```dart
/// ✅ Best Practice: UUID로 중복 실행 감지
Future<Either<SearchFailure, void>> updateRankings({
  required String idempotencyKey, // UUID
}) async {
  // 1. 이미 처리된 요청인지 확인
  final processed = await _checkIdempotencyKey(idempotencyKey);

  if (processed) {
    // 이미 처리됨 → 성공 반환 (중복 실행 방지)
    return right(null);
  }

  try {
    // 2. Rankings 업데이트 시작
    await _firestore.runTransaction((transaction) async {
      // 3. Idempotency Key 저장 (중복 방지)
      transaction.set(
        _firestore.collection('idempotency_keys').doc(idempotencyKey),
        {
          'processedAt': FieldValue.serverTimestamp(),
          'operation': 'updateRankings',
        },
      );

      // 4. Rankings 업데이트 로직
      final voteData = await _getVotingData();
      final newRankings = _calculateRankings(voteData);

      for (final ranking in newRankings) {
        transaction.set(
          _firestore.collection('rankings').doc(ranking.rankingId),
          ranking.toFirestore(),
        );
      }
    });

    return right(null);
  } on FirebaseException catch (e) {
    return left(SearchFailure.firestoreWriteFailed(
      collection: 'rankings',
      operation: 'update',
      message: e.message,
    ));
  }
}

/// Idempotency Key 확인
Future<bool> _checkIdempotencyKey(String key) async {
  final doc = await _firestore
      .collection('idempotency_keys')
      .doc(key)
      .get();

  return doc.exists;
}
```

#### 방법 2: Timestamp 기반 (Simple)

```dart
/// ✅ Simple: 마지막 업데이트 시간 체크
Future<Either<SearchFailure, void>> updateRankings() async {
  try {
    // 1. 마지막 업데이트 시간 확인
    final lastUpdate = await _getLastUpdateTimestamp();
    final now = DateTime.now();

    // 2. 5분 이내 업데이트된 경우 스킵 (중복 방지)
    if (lastUpdate != null &&
        now.difference(lastUpdate) < const Duration(minutes: 5)) {
      print('Rankings already updated recently. Skipping...');
      return right(null);
    }

    // 3. Rankings 업데이트
    await _firestore.runTransaction((transaction) async {
      // Update timestamp
      transaction.set(
        _firestore.collection('metadata').doc('rankings_update'),
        {
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update rankings...
    });

    return right(null);
  } catch (e) {
    return left(SearchFailure.unexpected(e.toString()));
  }
}
```

#### 방법 3: Version 기반 (Optimistic Locking)

```dart
/// ✅ Advanced: Version으로 동시 업데이트 감지
Future<Either<SearchFailure, void>> updateRankings({
  required int expectedVersion,
}) async {
  try {
    await _firestore.runTransaction((transaction) async {
      // 1. 현재 Version 확인
      final metadataDoc = await transaction.get(
        _firestore.collection('metadata').doc('rankings_version'),
      );

      final currentVersion = metadataDoc.data()?['version'] as int? ?? 0;

      // 2. Version 불일치 → 다른 작업이 이미 업데이트함
      if (currentVersion != expectedVersion) {
        throw Exception('Version conflict: expected $expectedVersion, got $currentVersion');
      }

      // 3. Rankings 업데이트 + Version 증가
      transaction.update(
        _firestore.collection('metadata').doc('rankings_version'),
        {'version': FieldValue.increment(1)},
      );

      // Update rankings...
    });

    return right(null);
  } catch (e) {
    return left(SearchFailure.conflictError(e.toString()));
  }
}
```

---

## 📊 Search Feature Idempotency 적용 대상

### 1. updateRankings() - ⭐⭐⭐ 높은 우선순위

**현재 상태**:
```dart
/// ❌ 현재: Idempotency 없음
@override
Future<Either<SearchFailure, void>> updateRankings() async {
  try {
    // TODO: Implement ranking update logic from voting data
    return left(SearchFailure.unexpected('updateRankings not implemented'));
  } catch (e) {
    return left(SearchFailure.unexpected(e.toString()));
  }
}
```

**권장 구현** (구현 시 참고):
```dart
/// ✅ 권장: Timestamp 기반 Idempotency
@override
Future<Either<SearchFailure, void>> updateRankings() async {
  try {
    // 1. 마지막 업데이트 시간 확인
    final metadataDoc = await _firestore
        .collection('metadata')
        .doc('rankings_update')
        .get();

    final lastUpdate = (metadataDoc.data()?['lastUpdatedAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    // 2. 5분 이내 업데이트 스킵 (중복 방지)
    if (lastUpdate != null &&
        now.difference(lastUpdate) < const Duration(minutes: 5)) {
      debugPrint('Rankings already updated at $lastUpdate. Skipping...');
      return right(null);
    }

    // 3. Transaction으로 원자성 보장
    await _firestore.runTransaction((transaction) async {
      // 3-1. 투표 데이터 가져오기
      final voteSnapshot = await transaction.get(
        _firestore.collection('votes').orderBy('createdAt', descending: true),
      );

      // 3-2. Rankings 계산
      final rankings = _calculateRankingsFromVotes(voteSnapshot.docs);

      // 3-3. Rankings 업데이트
      for (final ranking in rankings) {
        transaction.set(
          _firestore.collection('rankings').doc(ranking.rankingId),
          ranking.toFirestore(),
          SetOptions(merge: true),
        );
      }

      // 3-4. Timestamp 업데이트
      transaction.set(
        _firestore.collection('metadata').doc('rankings_update'),
        {
          'lastUpdatedAt': FieldValue.serverTimestamp(),
          'rankingsCount': rankings.length,
        },
      );
    });

    // 4. 캐시 무효화
    await _cache.clearTopRankings();

    return right(null);
  } on FirebaseException catch (e) {
    return left(SearchFailure.firestoreWriteFailed(
      collection: 'rankings',
      operation: 'update',
      message: e.message,
    ));
  } catch (e) {
    return left(SearchFailure.unexpected(e.toString()));
  }
}

/// Rankings 계산 로직 (Helper)
List<Ranking> _calculateRankingsFromVotes(List<DocumentSnapshot> votes) {
  // TODO: 투표 데이터 기반 Rankings 계산
  // 예: 최근 7일간 투표수 집계, 인기도 계산 등
  return [];
}
```

### 2. saveSearchHistory() - ⭐⭐ 중간 우선순위

**권장 구현** (향후 추가 시 참고):
```dart
/// ✅ 권장: UUID 기반 Idempotency
Future<Either<SearchFailure, void>> saveSearchHistory({
  required String userId,
  required String query,
  required String idempotencyKey, // UUID
}) async {
  try {
    // 1. Idempotency Key 확인
    final keyDoc = await _firestore
        .collection('idempotency_keys')
        .doc('search_$idempotencyKey')
        .get();

    if (keyDoc.exists) {
      // 이미 저장됨 → 중복 방지
      return right(null);
    }

    // 2. Transaction으로 저장
    await _firestore.runTransaction((transaction) async {
      // 2-1. Idempotency Key 저장
      transaction.set(
        _firestore.collection('idempotency_keys').doc('search_$idempotencyKey'),
        {
          'processedAt': FieldValue.serverTimestamp(),
          'userId': userId,
          'query': query,
        },
      );

      // 2-2. Search History 저장
      transaction.set(
        _firestore.collection('searches').doc(),
        {
          'userId': userId,
          'query': query,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    });

    return right(null);
  } catch (e) {
    return left(SearchFailure.firestoreWriteFailed(
      collection: 'searches',
      operation: 'save',
      message: e.toString(),
    ));
  }
}
```

### 3. 읽기 작업 - ❌ Idempotency 불필요

```dart
/// ❌ 읽기 작업은 Idempotency 불필요 (이미 멱등적)
Future<Either<SearchFailure, List<Ranking>>> getTopRankings({int limit = 10});
Stream<Either<SearchFailure, List<Ranking>>> queryRankings({...});
Stream<Either<SearchFailure, List<SearchesModel>>> querySearches({...});

// 이유: 읽기 작업은 데이터를 변경하지 않으므로
// 여러 번 실행해도 같은 결과 (이미 멱등적)
```

---

## 🎯 구현 시 체크리스트

### ✅ Idempotency 적용 기준

| 작업 타입 | Idempotency 필요 | 구현 방법 |
|----------|----------------|----------|
| **읽기 (GET, Query)** | ❌ 불필요 | 이미 멱등적 |
| **쓰기 (SET, 절대값)** | ✅ 권장 | Timestamp 또는 UUID |
| **증가 (INCREMENT)** | ✅ 필수 | UUID 기반 |
| **삭제 (DELETE)** | ✅ 권장 | UUID 또는 Existence Check |
| **복잡한 트랜잭션** | ✅ 필수 | Version 또는 UUID |

### 🔄 Idempotency Key 관리

#### 1. UUID 생성 (클라이언트)
```dart
import 'package:uuid/uuid.dart';

final uuid = Uuid();
final idempotencyKey = uuid.v4(); // "550e8400-e29b-41d4-a716-446655440000"

// UseCase에서 생성
final result = await updateRankingsUseCase(
  UpdateRankingsParams(idempotencyKey: idempotencyKey),
);
```

#### 2. Idempotency Key 저장 (Firestore)
```dart
// Collection 구조:
// idempotency_keys/
//   └── search_{uuid}/
//       ├── processedAt: Timestamp
//       ├── operation: "updateRankings"
//       └── userId: "user123" (선택)

// TTL 설정 (Firestore Security Rules):
match /idempotency_keys/{keyId} {
  // 7일 후 자동 삭제
  allow read, write: if request.time < resource.data.processedAt + duration.value(7, 'd');
}
```

#### 3. Idempotency Key 정리
```dart
/// 오래된 Idempotency Keys 정리 (Cloud Function)
exports.cleanupIdempotencyKeys = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const cutoff = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7일 전
    );

    const snapshot = await admin.firestore()
      .collection('idempotency_keys')
      .where('processedAt', '<', cutoff)
      .get();

    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));

    await batch.commit();
    console.log(`Cleaned up ${snapshot.size} idempotency keys`);
  });
```

---

## 💡 Best Practices

### 1. Idempotency Key 생성 시점

```dart
/// ✅ Good: UseCase에서 생성 (재시도 시 같은 키 사용)
class UpdateRankingsUseCase {
  Future<Either<SearchFailure, void>> call() async {
    final idempotencyKey = Uuid().v4(); // 여기서 생성

    return repository.updateRankings(
      idempotencyKey: idempotencyKey,
    );
  }
}

/// ❌ Bad: Repository에서 생성 (재시도 시 다른 키 생성됨)
class SearchRepositoryImpl {
  Future<Either<SearchFailure, void>> updateRankings() async {
    final idempotencyKey = Uuid().v4(); // ❌ 매번 다른 키
    // ...
  }
}
```

### 2. Transaction 사용

```dart
/// ✅ Good: Transaction으로 원자성 보장
await _firestore.runTransaction((transaction) async {
  // 1. Idempotency Key 저장
  transaction.set(idempotencyKeyDoc, {...});

  // 2. Rankings 업데이트
  transaction.set(rankingsDoc, {...});

  // 3. Metadata 업데이트
  transaction.update(metadataDoc, {...});
});

/// ❌ Bad: 개별 작업 (중간에 실패 시 일관성 깨짐)
await _firestore.collection('idempotency_keys').doc(key).set({...}); // ✅
await _firestore.collection('rankings').doc(id).set({...}); // ❌ 여기서 실패
await _firestore.collection('metadata').doc('update').update({...}); // ❌ 실행 안 됨
```

### 3. 에러 처리

```dart
/// ✅ Good: Idempotency Key 확인 실패 시 작업 계속
Future<Either<SearchFailure, void>> updateRankings({
  required String idempotencyKey,
}) async {
  try {
    final processed = await _checkIdempotencyKey(idempotencyKey);

    if (processed) {
      return right(null); // 중복 방지
    }
  } catch (e) {
    // Idempotency Key 확인 실패 → 경고만 출력하고 작업 계속
    debugPrint('Idempotency key check failed: $e. Proceeding with update...');
  }

  // Rankings 업데이트 계속 진행
  // ...
}
```

### 4. Cache Invalidation

```dart
/// ✅ Good: Idempotency 작업 후 캐시 무효화
await _firestore.runTransaction((transaction) async {
  // Transaction 작업...
});

// Transaction 성공 후 캐시 무효화
await _cache.clearTopRankings();
```

---

## 📚 참고 자료

### 공식 문서
- [Idempotency (Wikipedia)](https://en.wikipedia.org/wiki/Idempotence)
- [Firestore Transactions](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [UUID Package](https://pub.dev/packages/uuid)

### 프로젝트 내부 문서
- [Chat Feature PHASE_4_IDEMPOTENCY.md](../chat/PHASE_4_IDEMPOTENCY.md)
- [Post Feature PHASE_4_IDEMPOTENCY.md](../post/PHASE_4_IDEMPOTENCY.md)
- [Notifications Feature PHASE_4_IDEMPOTENCY.md](../notifications/PHASE_4_IDEMPOTENCY.md)

### 주요 패턴
1. **UUID 기반**: 가장 안전하고 명시적
2. **Timestamp 기반**: 간단하고 실용적 (5분 윈도우)
3. **Version 기반**: Optimistic Locking (동시성 제어)
4. **Transaction**: 원자성 보장 (All or Nothing)
5. **TTL**: 오래된 Idempotency Keys 자동 정리

---

## 🎓 학습 요약

### Idempotency가 필요한 이유

1. **네트워크 재시도**: 클라이언트가 응답을 못 받아 재시도 시 중복 방지
2. **Cloud Functions 재시도**: Firebase Functions 자동 재시도 시 중복 방지
3. **동시성**: 여러 클라이언트가 동시에 같은 작업 시 충돌 방지
4. **데이터 일관성**: Transaction으로 원자성 보장

### Search Feature 적용 우선순위

1. **⭐⭐⭐ updateRankings()**: 구현 시 Timestamp 기반 Idempotency 적용
2. **⭐⭐ saveSearchHistory()**: 향후 추가 시 UUID 기반 적용 권장
3. **❌ 읽기 작업**: Idempotency 불필요 (이미 멱등적)

### 구현 체크리스트

- [ ] UUID 패키지 추가 (`pubspec.yaml`)
- [ ] UseCase에서 Idempotency Key 생성
- [ ] Repository에서 Idempotency Key 확인
- [ ] Firestore Transaction 사용
- [ ] 캐시 무효화 (성공 시)
- [ ] 에러 처리 (Idempotency Key 확인 실패 시)
- [ ] Cloud Function으로 오래된 Keys 정리 (선택)

---

**완료일**: 2025-11-07
**다음 단계**: Phase 5 - Extension Pattern Documentation

**Note**: Search Feature는 읽기 중심이라 Idempotency 필요성이 낮음. `updateRankings()` 구현 시에만 적용하면 충분하며, 본 문서는 구현 가이드로 활용.
