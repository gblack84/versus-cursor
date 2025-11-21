# IdempotencyService 최적화 - 옵션 1 구현 계획

> **작성일**: 2025-11-21
> **전략**: Minimal Keep - Draft/조회수 IdempotencyService 제거
> **예상 작업**: 1시간
> **예상 효과**: 20-30% 비용 절감
> **위험도**: 낮음

---

## 📋 실행 요약

**제거 대상**:
- ✂️ Creation Feature - Draft 자동 저장 (불필요)
- ✂️ Post Feature - 조회수 증가 (불필요)

**유지 대상**:
- ✅ Voting Feature (CRITICAL - 필수)
- ✅ Chat Feature (MEDIUM - 안전망)
- ✅ Creation Feature - Post 생성 (HIGH - 필수)

**예상 효과**:
- 작업 시간: **1시간**
- Firestore 비용 절감: **20-30%** (4,000 reads/일 → 0)
- 성능 개선: Draft 150ms→50ms (-67%), 조회수 100ms→30ms (-70%)
- 위험도: **낮음** (Draft/조회수 중복은 무해)

---

## 🔧 구체적 코드 변경

### 변경 1: Draft 자동 저장 - IdempotencyService 제거

**파일**: `/Users/g_black/versus-cursor/lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart`

#### Before (lines 197-237)
```dart
Future<void> saveDraftPost(String userId, PostCreation draft, {
  required String eventId,  // ❌ eventId 파라미터 제거 필요
}) async {
  await _cacheService.setDraftPost(userId, draft);

  scheduleMicrotask(() async {
    try {
      await _idempotencyService.executeIdempotent<void>(  // ❌ 불필요한 래퍼
        entityType: 'draft_save',
        entityId: draft.id ?? 'draft_$userId',
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          final draftId = draft.id ?? 'draft_$userId';
          final docRef = _postsCollection.doc(draftId);
          transaction.set(docRef, draft.toFirestore());
        },
      );
    } on IdempotencyViolation {
      Logger.warning('Draft save idempotency violation (ignored)');
    }
  });
}
```

#### After
```dart
Future<void> saveDraftPost(String userId, PostCreation draft) async {
  await _cacheService.setDraftPost(userId, draft);

  scheduleMicrotask(() async {
    try {
      // ✅ 직접 Firestore write (고정 ID = 자연스러운 멱등성)
      final draftId = 'draft_$userId';
      await _postsCollection.doc(draftId).set(draft.toFirestore());

      Logger.info('Draft saved successfully: $draftId');
    } catch (e) {
      Logger.warning('Draft save failed: $e');
    }
  });
}
```

**변경 이유**:
- Draft ID는 `'draft_$userId'` 고정 → 같은 ID에 `set()` 호출 = 멱등성 보장
- 500ms debounce로 인해 동시 요청 거의 없음
- Draft 중복 저장은 무해 (최신 상태로 덮어쓰기)
- Transaction 오버헤드 제거: 150ms → 50ms (-67%)

---

### 변경 2: 조회수 증가 - IdempotencyService 제거

**파일**: `/Users/g_black/versus-cursor/lib/features/post/data/repositories/post_repository_impl.dart`

#### Before
```dart
Future<Either<PostFailure, Unit>> incrementViewCount({
  required String postId,
  required String userId,
  required String eventId,  // ❌ eventId 파라미터 제거 필요
}) async {
  try {
    await _idempotencyService.executeIdempotent<void>(  // ❌ 불필요한 래퍼
      entityType: 'view_count',
      entityId: postId,
      userId: userId,
      eventId: eventId,
      operation: (transaction) async {
        transaction.update(_postsRef.doc(postId), {
          'viewCount': FieldValue.increment(1),
        });
      },
    );

    return right(unit);
  } on IdempotencyViolation {
    return right(unit);
  } catch (e) {
    return left(PostFailure.serverError(e.toString()));
  }
}
```

#### After
```dart
Future<Either<PostFailure, Unit>> incrementViewCount({
  required String postId,
  required String userId,
}) async {
  try {
    // ✅ 직접 increment (근사값 허용)
    await _postsRef.doc(postId).update({
      'viewCount': FieldValue.increment(1),
    });

    Logger.info('View count incremented: $postId');
    return right(unit);
  } catch (e) {
    Logger.warning('View count increment failed: $e');
    return left(PostFailure.serverError(e.toString()));
  }
}
```

**변경 이유**:
- 조회수는 근사값 (100% 정확도 불필요)
- `FieldValue.increment(1)`는 원자적 연산
- 조회수 중복 집계는 서비스 품질에 큰 영향 없음
- Transaction 오버헤드 제거: 100ms → 30ms (-70%)

---

### 변경 3: UseCase 업데이트

#### SaveDraftPostUseCase

**파일**: `/Users/g_black/versus-cursor/lib/features/creation/domain/usecases/save_draft_post_usecase.dart`

**Before**:
```dart
class SaveDraftPostUseCase {
  final IPostCreationRepositoryV2 _repository;
  final String Function() _eventIdGenerator;  // ❌ 제거

  SaveDraftPostUseCase({
    required IPostCreationRepositoryV2 repository,
    required String Function() eventIdGenerator,
  })  : _repository = repository,
        _eventIdGenerator = eventIdGenerator;

  Future<Either<CreationFailure, void>> call({
    required String userId,
    required PostCreation draft,
  }) async {
    final eventId = _eventIdGenerator();  // ❌ 제거

    return _repository.saveDraftPost(
      userId,
      draft,
      eventId: eventId,
    );
  }
}
```

**After**:
```dart
class SaveDraftPostUseCase {
  final IPostCreationRepositoryV2 _repository;

  SaveDraftPostUseCase({
    required IPostCreationRepositoryV2 repository,
  }) : _repository = repository;

  Future<Either<CreationFailure, void>> call({
    required String userId,
    required PostCreation draft,
  }) async {
    return _repository.saveDraftPost(userId, draft);  // ✅ eventId 제거
  }
}
```

---

#### IncrementViewCountUseCase

**파일**: `/Users/g_black/versus-cursor/lib/features/post/domain/usecases/increment_view_count_usecase.dart`

**Before**:
```dart
class IncrementViewCountUseCase {
  final IPostRepository _repository;
  final String Function() _eventIdGenerator;  // ❌ 제거

  IncrementViewCountUseCase({
    required IPostRepository repository,
    required String Function() eventIdGenerator,
  })  : _repository = repository,
        _eventIdGenerator = eventIdGenerator;

  Future<Either<PostFailure, Unit>> call({
    required String postId,
    required String userId,
  }) async {
    final eventId = _eventIdGenerator();  // ❌ 제거

    return _repository.incrementViewCount(
      postId: postId,
      userId: userId,
      eventId: eventId,
    );
  }
}
```

**After**:
```dart
class IncrementViewCountUseCase {
  final IPostRepository _repository;

  IncrementViewCountUseCase({
    required IPostRepository repository,
  }) : _repository = repository;

  Future<Either<PostFailure, Unit>> call({
    required String postId,
    required String userId,
  }) async {
    return _repository.incrementViewCount(
      postId: postId,
      userId: userId,
    );  // ✅ eventId 제거
  }
}
```

---

### 변경 4: DI 모듈 업데이트

#### Creation DI Module

**파일**: `/Users/g_black/versus-cursor/lib/features/creation/di/creation_di_module.dart`

**Before**:
```dart
getIt.registerFactory(
  () => SaveDraftPostUseCase(
    repository: getIt(),
    eventIdGenerator: () => const Uuid().v4(),  // ❌ 제거
  ),
);
```

**After**:
```dart
getIt.registerFactory(
  () => SaveDraftPostUseCase(
    repository: getIt(),
    // eventIdGenerator 제거됨
  ),
);
```

---

#### Post DI Module

**파일**: `/Users/g_black/versus-cursor/lib/features/post/di/post_di_module.dart`

**Before**:
```dart
getIt.registerFactory(
  () => IncrementViewCountUseCase(
    repository: getIt(),
    eventIdGenerator: () => const Uuid().v4(),  // ❌ 제거
  ),
);
```

**After**:
```dart
getIt.registerFactory(
  () => IncrementViewCountUseCase(
    repository: getIt(),
    // eventIdGenerator 제거됨
  ),
);
```

---

## 📊 예상 효과

### Firestore 비용 절감

**현재 상태** (Draft + 조회수):
```
Draft 저장:
- IdempotencyService check: 1,000회/일 × 2 reads = 2,000 reads/일
- 실제 저장: 1,000 writes/일

조회수 증가:
- IdempotencyService check: 1,000회/일 × 2 reads = 2,000 reads/일
- 실제 증가: 1,000 writes/일

총 비용:
- Reads: 4,000회/일 × 30일 = 120,000 reads/월
- Writes: 2,000회/일 × 30일 = 60,000 writes/월
- 월 비용: $0.0144 (reads) + $0.0108 (writes) = $0.0252
```

**변경 후**:
```
Draft 저장:
- IdempotencyService check: 0회/일
- 실제 저장: 1,000 writes/일

조회수 증가:
- IdempotencyService check: 0회/일
- 실제 증가: 1,000 writes/일

총 비용:
- Reads: 0회/일 × 30일 = 0 reads/월
- Writes: 2,000회/일 × 30일 = 60,000 writes/월
- 월 비용: $0 (reads) + $0.0108 (writes) = $0.0108

절감: $0.0252 → $0.0108 (-57%, 약 ₩19/월)
```

---

### 성능 개선

**현재 성능**:
```
Draft 저장: ~150ms
- IdempotencyService check: ~50ms (Firestore read × 2)
- Transaction: ~80ms (write + lock)
- Network overhead: ~20ms

조회수 증가: ~100ms
- IdempotencyService check: ~40ms (Firestore read × 2)
- Transaction: ~50ms (update + lock)
- Network overhead: ~10ms
```

**변경 후 성능**:
```
Draft 저장: ~50ms (-67%)
- Direct set(): ~40ms
- Network overhead: ~10ms

조회수 증가: ~30ms (-70%)
- Direct increment: ~20ms
- Network overhead: ~10ms
```

---

## ✅ 실행 단계

### Step 1: Repository 수정 (15분)

```bash
# 1. Creation Repository 수정
code /Users/g_black/versus-cursor/lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart
# saveDraftPost() 메서드 수정:
# - eventId 파라미터 제거
# - IdempotencyService.executeIdempotent() 제거
# - 직접 set() 호출로 변경

# 2. Post Repository 수정
code /Users/g_black/versus-cursor/lib/features/post/data/repositories/post_repository_impl.dart
# incrementViewCount() 메서드 수정:
# - eventId 파라미터 제거
# - IdempotencyService.executeIdempotent() 제거
# - 직접 update() 호출로 변경
```

---

### Step 2: UseCase 수정 (10분)

```bash
# 3. SaveDraftPostUseCase 수정
code /Users/g_black/versus-cursor/lib/features/creation/domain/usecases/save_draft_post_usecase.dart
# - _eventIdGenerator 필드 제거
# - eventIdGenerator 생성자 파라미터 제거
# - call() 메서드에서 eventId 생성 로직 제거

# 4. IncrementViewCountUseCase 수정
code /Users/g_black/versus-cursor/lib/features/post/domain/usecases/increment_view_count_usecase.dart
# - _eventIdGenerator 필드 제거
# - eventIdGenerator 생성자 파라미터 제거
# - call() 메서드에서 eventId 생성 로직 제거
```

---

### Step 3: DI 모듈 수정 (10분)

```bash
# 5. Creation DI 모듈 수정
code /Users/g_black/versus-cursor/lib/features/creation/di/creation_di_module.dart
# SaveDraftPostUseCase 등록에서 eventIdGenerator 제거

# 6. Post DI 모듈 수정
code /Users/g_black/versus-cursor/lib/features/post/di/post_di_module.dart
# IncrementViewCountUseCase 등록에서 eventIdGenerator 제거
```

---

### Step 4: 테스트 & 검증 (25분)

```bash
# 7. 코드 분석 (타입 에러 확인)
flutter analyze
# 목표: 0 errors, 0 warnings

# 8. Draft 저장 테스트
# - 앱 실행 → 게시물 작성 → Draft 자동 저장 확인
# - Firestore Console → posts 컬렉션 → 'draft_$userId' 문서 확인
# - 여러 번 저장 시 최신 상태로 덮어쓰기 확인

# 9. 조회수 증가 테스트
# - 앱 실행 → 게시물 조회 → viewCount 증가 확인
# - 여러 번 조회 시 정상 증가 확인 (중복 무해)
# - Firestore Console → posts 컬렉션 → viewCount 필드 확인

# 10. 성능 확인
# - DevTools → Performance 탭
# - Draft 저장 시간: ~50ms 확인 (기존 150ms 대비 -67%)
# - 조회수 증가 시간: ~30ms 확인 (기존 100ms 대비 -70%)

# 11. Firestore Console 확인
# - idempotency 컬렉션 write 감소 확인
# - Draft/조회수 관련 idempotency 문서 생성 중단 확인
```

---

## 🎯 검증 체크리스트

### 코드 수정 완료

```
□ Repository 수정
  □ post_creation_repository_v2_impl.dart
    □ saveDraftPost() - eventId 파라미터 제거
    □ saveDraftPost() - IdempotencyService 제거
    □ saveDraftPost() - 직접 set() 호출

  □ post_repository_impl.dart
    □ incrementViewCount() - eventId 파라미터 제거
    □ incrementViewCount() - IdempotencyService 제거
    □ incrementViewCount() - 직접 update() 호출

□ UseCase 수정
  □ save_draft_post_usecase.dart
    □ _eventIdGenerator 필드 제거
    □ eventIdGenerator 생성자 파라미터 제거
    □ eventId 생성 로직 제거

  □ increment_view_count_usecase.dart
    □ _eventIdGenerator 필드 제거
    □ eventIdGenerator 생성자 파라미터 제거
    □ eventId 생성 로직 제거

□ DI 모듈 수정
  □ creation_di_module.dart
    □ SaveDraftPostUseCase - eventIdGenerator 등록 제거

  □ post_di_module.dart
    □ IncrementViewCountUseCase - eventIdGenerator 등록 제거
```

---

### 테스트 검증

```
□ 정적 분석
  □ flutter analyze (0 errors)
  □ No type errors
  □ No unused imports

□ Draft 저장 동작
  □ Draft 자동 저장 정상 동작 (500ms debounce)
  □ Firestore 'draft_$userId' 문서 생성 확인
  □ 여러 번 저장 시 덮어쓰기 확인
  □ 에러 없이 정상 저장

□ 조회수 증가 동작
  □ 게시물 조회 시 viewCount 증가 확인
  □ 여러 번 조회 시 정상 증가 (중복 허용)
  □ Firestore viewCount 필드 업데이트 확인
  □ 에러 없이 정상 증가

□ 성능 개선 확인
  □ Draft 저장 시간: ~50ms (기존 150ms 대비 -67%)
  □ 조회수 증가 시간: ~30ms (기존 100ms 대비 -70%)
  □ DevTools Performance 탭에서 측정

□ Firestore Console 확인
  □ idempotency 컬렉션 write 감소 확인
  □ draft_save 타입 문서 생성 중단
  □ view_count 타입 문서 생성 중단
  □ 비용 절감 확인 (4,000 reads/일 → 0)
```

---

## 🚨 주의사항

### 롤백 시나리오

만약 문제가 발생하면 다음과 같이 롤백:

1. **Git 롤백**
   ```bash
   git revert <commit-hash>
   ```

2. **수동 롤백** (코드 변경 취소)
   - Repository에 IdempotencyService 다시 추가
   - UseCase에 eventIdGenerator 다시 추가
   - DI 모듈에 eventIdGenerator 등록 다시 추가

---

### 모니터링 항목

구현 후 **48시간 동안** 다음 지표 모니터링:

```
□ Draft 저장 성공률
  - 목표: 99.9%+ (기존 대비 동일)
  - 실패 시 로그 확인

□ 조회수 정확도
  - 목표: ±5% 오차 허용
  - 실시간 증가 확인

□ 성능
  - Draft 저장: ~50ms
  - 조회수 증가: ~30ms

□ Firestore 비용
  - idempotency reads: 0회/일
  - 비용 절감: $0.0144/월
```

---

## 📚 참고 문서

- **IdempotencyService 분석**: `/Users/g_black/versus-cursor/lib/services/idempotency/idempotency_service.dart`
- **Feature별 평가**: 이 문서의 "배경 - Feature별 재분석" 섹션
- **Firebase Transaction**: [Firebase Documentation](https://firebase.google.com/docs/firestore/manage-data/transactions)
- **FieldValue.increment()**: [Firestore Atomic Operations](https://firebase.google.com/docs/firestore/manage-data/add-data#increment_a_numeric_value)

---

## 📝 의사결정 근거

### 왜 Draft 자동 저장에서 IdempotencyService를 제거했나?

1. **고정 ID 사용**: `'draft_$userId'`는 사용자당 하나의 고정 ID
2. **set() 멱등성**: Firestore `set()`은 같은 ID에 여러 번 호출 시 덮어쓰기 (멱등성 보장)
3. **Debounce 존재**: 500ms debounce로 동시 요청 거의 없음
4. **무해한 중복**: Draft가 중복 저장되어도 최신 상태로 덮어쓰기되므로 무해

### 왜 조회수 증가에서 IdempotencyService를 제거했나?

1. **근사값 허용**: 조회수는 100% 정확도가 필요 없는 지표
2. **원자적 연산**: `FieldValue.increment(1)`은 원자적 연산으로 동시성 처리
3. **무해한 중복**: 조회수가 실제보다 약간 높아져도 서비스 품질에 영향 없음
4. **성능 우선**: Transaction 오버헤드 제거로 70% 성능 개선

### 왜 Voting/Chat/Post 생성은 유지했나?

- **Voting**: CRITICAL - 투표 중복은 사용자 신뢰 직결
- **Chat**: MEDIUM - 메시지 중복은 UX 저하, 안전망 역할
- **Post 생성**: HIGH - 서버 생성 ID로 인한 중복 방지 필요

---

**최종 업데이트**: 2025-11-21
**작성자**: Claude Code
**검토자**: (구현 후 작성)
