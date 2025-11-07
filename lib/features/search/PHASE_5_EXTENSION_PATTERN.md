# Search Feature - Phase 5: Extension Pattern (Already Applied)

> **마이그레이션 가이드**: Firebase-Centric v2.0 Extension Pattern
> **난이도**: ⭐⭐⭐☆☆ (중급)
> **예상 소요 시간**: 완료 (Phase 1에서 조기 적용)
> **작성일**: 2025-11-07
> **구현 상태**: ✅ **완료** (Phase 1에서 Ranking Extension 구현 완료)

---

## 📋 개요

### Phase 5의 목적

Search Feature의 **Ranking 모델**에 Extension Pattern을 적용하여 Firebase-Centric v2.0 아키텍처 구현:

1. **DataSource Layer 제거**: Repository가 Firestore 직접 사용
2. **DTO Layer 제거**: Entity에서 직접 Firestore 변환
3. **Mapper Layer 제거**: Extension으로 변환 로직 통합
4. **코드 단순화**: 불필요한 추상화 계층 제거

### Firebase-Centric v2.0 아키텍처

**이전 아키텍처 (Clean Architecture with Abstraction)**:
```
Firestore → DataSource → DTO → Mapper → Entity
         (4단계 변환, 추정 ~300줄)
```

**현재 아키텍처 (Firebase-Centric v2.0)**:
```
Firestore → Extension → Entity
         (1단계 변환, ~30줄)
```

**주요 변경**:
- ❌ **DataSource 제거**: ISearchDataSource, SearchDataSourceImpl 불필요
- ❌ **DTO 제거**: RankingDto 불필요
- ❌ **Mapper 제거**: RankingMapper 불필요
- ✅ **Extension 추가**: RankingFirestore extension으로 직접 변환

### Search Feature의 특징

| 항목 | 상태 | 설명 |
|------|------|------|
| **DataSource** | ❌ 없음 | 처음부터 Repository가 Firestore 직접 사용 |
| **DTO** | ❌ 없음 | 없음 |
| **Mapper** | ❌ 없음 | 없음 |
| **Extension Pattern** | ✅ 적용 | Phase 1에서 ranking_extensions.dart 생성 |
| **SearchesModel** | ⚠️ 레거시 | fromSnapshot() 메서드 사용 (Extension 전환 필요) |

**결론**: Search Feature는 **처음부터 Firebase-Centric 접근**을 사용했으며, Phase 1에서 Ranking Extension Pattern을 완성했습니다.

---

## ✅ 현재 상태 (이미 적용됨)

### 1. Ranking Extension Pattern (Phase 1 완료)

**파일**: `domain/models/ranking_extensions.dart`

```dart
part of 'ranking.dart';

/// Ranking Firestore Extensions
///
/// Firestore DocumentSnapshot ↔ Ranking Entity 변환
///
/// **Phase 5 (2025-11-07)**: Extension Pattern Migration
/// - DTO/Mapper 제거
/// - Extension 메서드로 직접 변환
/// - Firebase-Centric Architecture v2.0
extension RankingFirestore on Ranking {
  /// Firestore DocumentSnapshot → Ranking Entity
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await firestore.collection('rankings').doc(id).get();
  /// final ranking = RankingFirestore.fromFirestore(doc);
  /// ```
  static Ranking fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Ranking(
      rankingId: doc.id,
      type: data['type'] as String? ?? 'daily',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  /// Ranking Entity → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final ranking = Ranking(...);
  /// await firestore.collection('rankings').doc(id).set(ranking.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      if (date != null) 'date': Timestamp.fromDate(date!),
    };
  }
}
```

**주요 특징**:
1. ✅ **fromFirestore()**: DocumentSnapshot → Ranking Entity 직접 변환
2. ✅ **toFirestore()**: Ranking Entity → Firestore Map 직접 변환
3. ✅ **part of 지시자**: ranking.dart와 연결
4. ✅ **Null Safety**: Null 체크 및 기본값 처리
5. ✅ **Timestamp 변환**: Firestore Timestamp ↔ DateTime 자동 변환

### 2. Repository에서 Extension 사용 (Phase 1 완료)

**파일**: `data/repositories/search_repository_impl.dart`

```dart
/// ✅ Extension Pattern 적용 완료
@override
Future<Either<SearchFailure, List<Ranking>>> getTopRankings({
  int limit = 10
}) async {
  try {
    final snapshot = await _firestore
        .collection('rankings')
        .orderBy('rank')
        .limit(limit)
        .get();

    // ✅ Phase 5: Direct extension usage (no DTO/Mapper)
    final rankings = snapshot.docs
        .map((doc) => RankingFirestore.fromFirestore(doc))
        .toList();

    return right(rankings);
  } on FirebaseException catch (e) {
    return left(SearchFailure.firestoreReadFailed(
      collection: 'rankings',
      message: e.message,
    ));
  } catch (e) {
    return left(SearchFailure.unexpected(e.toString()));
  }
}

@override
Stream<Either<SearchFailure, List<Ranking>>> queryRankings({
  dynamic Function(dynamic)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  try {
    Query query = _firestore.collection('rankings');

    // Query builder, limit, singleRecord 처리...

    return query.snapshots().map((snapshot) {
      try {
        // ✅ Phase 5: Direct extension usage (no DTO/Mapper)
        final rankings = snapshot.docs
            .map((doc) => RankingFirestore.fromFirestore(doc))
            .toList();
        return right<SearchFailure, List<Ranking>>(rankings);
      } catch (e) {
        return left<SearchFailure, List<Ranking>>(
          SearchFailure.firestoreReadFailed(
            collection: 'rankings',
            message: e.toString(),
          ),
        );
      }
    });
  } catch (e) {
    return Stream.value(left(SearchFailure.unexpected(e.toString())));
  }
}
```

**주요 개선사항**:
1. ✅ **DataSource 제거**: Repository가 Firestore 직접 사용
2. ✅ **DTO 제거**: Entity로 직접 변환
3. ✅ **Mapper 제거**: Extension 메서드로 변환
4. ✅ **코드 간결화**: 3단계 변환 → 1단계 변환

---

## 🔄 SearchesModel 마이그레이션 (TODO)

### 현재 상태: 레거시 fromSnapshot() 패턴

**파일**: `domain/models/search_history_model.dart`

```dart
/// ⚠️ 현재: fromSnapshot() 메서드 사용 (레거시 패턴)
@freezed
class SearchesModel with _$SearchesModel {
  const factory SearchesModel({
    String? uid,
    String? query,
    DateTime? createdTime,
    DateTime? modifiedTime,
  }) = _SearchesModel;

  /// ❌ 레거시: fromSnapshot() 메서드
  factory SearchesModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return SearchesModel(
      uid: snapshot.id,
      query: data?['query'] as String?,
      createdTime: (data?['created_time'] as Timestamp?)?.toDate(),
      modifiedTime: (data?['modified_time'] as Timestamp?)?.toDate(),
    );
  }

  /// Collection reference
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('searches');

  /// Query helper
  static Query queryRecords({required Query Function(Query) queryBuilder}) {
    return queryBuilder(collection);
  }
}
```

### 권장 마이그레이션: Extension Pattern

**파일**: `domain/models/search_history_extensions.dart` (신규 생성 권장)

```dart
part of 'search_history_model.dart';

/// SearchesModel Firestore Extensions
///
/// **Phase 5 (2025-11-07)**: Extension Pattern Migration
/// - fromSnapshot() → fromFirestore() 전환
/// - Extension 메서드로 통일
extension SearchesModelFirestore on SearchesModel {
  /// Firestore DocumentSnapshot → SearchesModel Entity
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await firestore.collection('searches').doc(id).get();
  /// final search = SearchesModelFirestore.fromFirestore(doc);
  /// ```
  static SearchesModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SearchesModel(
      uid: doc.id,
      query: data['query'] as String?,
      createdTime: (data['created_time'] as Timestamp?)?.toDate(),
      modifiedTime: (data['modified_time'] as Timestamp?)?.toDate(),
    );
  }

  /// SearchesModel Entity → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final search = SearchesModel(...);
  /// await firestore.collection('searches').doc(id).set(search.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      if (query != null) 'query': query,
      if (createdTime != null) 'created_time': Timestamp.fromDate(createdTime!),
      if (modifiedTime != null) 'modified_time': Timestamp.fromDate(modifiedTime!),
    };
  }
}
```

**마이그레이션 단계**:

1. **search_history_extensions.dart 생성**
2. **search_history_model.dart 수정**:
   ```dart
   part 'search_history_model.freezed.dart';
   part 'search_history_model.g.dart';
   part 'search_history_extensions.dart'; // ✅ 추가
   ```

3. **Repository에서 fromSnapshot() → fromFirestore() 전환**:
   ```dart
   // Before:
   final models = snapshot.docs
       .map((doc) => SearchesModel.fromSnapshot(doc))
       .toList();

   // After:
   final models = snapshot.docs
       .map((doc) => SearchesModelFirestore.fromFirestore(doc))
       .toList();
   ```

4. **fromSnapshot() 메서드 제거** (호환성 유지 기간 후)

---

## 📊 Before vs After 비교

### 1. 코드량 비교 (Ranking 기준)

| 레이어 | Before (추정) | After (실제) | 감소율 |
|--------|--------------|-------------|--------|
| **DataSource** | ~150줄 | 0줄 | **100%** |
| **DTO** | ~50줄 | 0줄 | **100%** |
| **Mapper** | ~60줄 | 0줄 | **100%** |
| **Extension** | - | ~30줄 | NEW |
| **합계** | **~260줄** | **~30줄** | **88%** |

### 2. 변환 단계 비교

#### Before: 4단계 변환 (DataSource → DTO → Mapper → Entity)
```dart
/// ❌ Before: 4단계 변환

// Step 1: Firestore → DocumentSnapshot (DataSource)
final doc = await _firestore.collection('rankings').doc(id).get();

// Step 2: DocumentSnapshot → Map (DataSource)
final data = doc.data() as Map<String, dynamic>;

// Step 3: Map → DTO (DTO)
final dto = RankingDto.fromFirestore(data, doc.id);

// Step 4: DTO → Entity (Mapper)
final ranking = RankingMapper.toDomain(dto);
```

#### After: 1단계 변환 (Extension)
```dart
/// ✅ After: 1단계 변환

// Step 1: DocumentSnapshot → Entity (Extension)
final doc = await _firestore.collection('rankings').doc(id).get();
final ranking = RankingFirestore.fromFirestore(doc);
```

### 3. 필드 추가 시 작업량 비교

**시나리오**: Ranking에 `score: int` 필드 추가

#### Before: 4곳 수정 필요
```dart
// 1. Entity 수정
@freezed
class Ranking with _$Ranking {
  const factory Ranking({
    required String rankingId,
    String? type,
    DateTime? date,
    int? score, // ✅ 추가
  }) = _Ranking;
}

// 2. DTO 수정
class RankingDto {
  final String rankingId;
  final String? type;
  final DateTime? date;
  final int? score; // ✅ 추가

  factory RankingDto.fromFirestore(Map<String, dynamic> data, String id) {
    return RankingDto(
      rankingId: id,
      type: data['type'],
      date: (data['date'] as Timestamp?)?.toDate(),
      score: data['score'], // ✅ 추가
    );
  }
}

// 3. Mapper 수정 (toDomain)
static Ranking toDomain(RankingDto dto) {
  return Ranking(
    rankingId: dto.rankingId,
    type: dto.type,
    date: dto.date,
    score: dto.score, // ✅ 추가
  );
}

// 4. Mapper 수정 (toFirestore)
static Map<String, dynamic> toFirestore(Ranking entity) {
  return {
    'type': entity.type,
    if (entity.date != null) 'date': Timestamp.fromDate(entity.date!),
    if (entity.score != null) 'score': entity.score, // ✅ 추가
  };
}
```

#### After: 2곳만 수정
```dart
// 1. Entity 수정
@freezed
class Ranking with _$Ranking {
  const factory Ranking({
    required String rankingId,
    String? type,
    DateTime? date,
    int? score, // ✅ 추가
  }) = _Ranking;
}

// 2. Extension 수정 (fromFirestore + toFirestore)
extension RankingFirestore on Ranking {
  static Ranking fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Ranking(
      rankingId: doc.id,
      type: data['type'] as String? ?? 'daily',
      date: (data['date'] as Timestamp?)?.toDate(),
      score: data['score'] as int?, // ✅ 추가
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      if (date != null) 'date': Timestamp.fromDate(date!),
      if (score != null) 'score': score, // ✅ 추가
    };
  }
}
```

**작업량**: 4곳 → 2곳 (**50% 감소**)

---

## 💡 Best Practices

### 1. Extension 네이밍 규칙

```dart
/// ✅ Good: {ModelName}Firestore
extension RankingFirestore on Ranking { ... }
extension SearchesModelFirestore on SearchesModel { ... }

/// ❌ Bad: 모호한 이름
extension RankingExt on Ranking { ... }
extension RankingHelper on Ranking { ... }
```

### 2. fromFirestore() 패턴

```dart
/// ✅ Good: Static 메서드, doc.id 사용
static Ranking fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};

  return Ranking(
    rankingId: doc.id, // ✅ doc.id 사용
    type: data['type'] as String? ?? 'daily', // ✅ 기본값 제공
    date: (data['date'] as Timestamp?)?.toDate(), // ✅ Timestamp 변환
  );
}

/// ❌ Bad: Instance 메서드
Ranking fromFirestore(DocumentSnapshot doc) { ... }
```

### 3. toFirestore() 패턴

```dart
/// ✅ Good: Null 체크, if 조건문
Map<String, dynamic> toFirestore() {
  return {
    'type': type, // required 필드
    if (date != null) 'date': Timestamp.fromDate(date!), // optional 필드
  };
}

/// ❌ Bad: Null 무시
Map<String, dynamic> toFirestore() {
  return {
    'type': type,
    'date': Timestamp.fromDate(date!), // ❌ Null 시 에러
  };
}
```

### 4. part/part-of 지시자

```dart
// ranking.dart
part 'ranking.freezed.dart';
part 'ranking.g.dart';
part 'ranking_extensions.dart'; // ✅ part 선언

// ranking_extensions.dart
part of 'ranking.dart'; // ✅ part of 선언

extension RankingFirestore on Ranking { ... }
```

### 5. Timestamp 변환 헬퍼 (선택)

```dart
/// ✅ Advanced: Timestamp 변환 헬퍼 메서드
extension RankingFirestore on Ranking {
  static Ranking fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Ranking(
      rankingId: doc.id,
      type: data['type'] as String? ?? 'daily',
      date: _timestampToDateTime(data['date']), // ✅ 헬퍼 사용
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      if (date != null) 'date': _dateTimeToTimestamp(date!), // ✅ 헬퍼 사용
    };
  }

  // Timestamp 변환 헬퍼
  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static Timestamp _dateTimeToTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }
}
```

---

## 🎯 검증 체크리스트

### ✅ Phase 5 완료 기준 (Ranking)

- [x] **ranking_extensions.dart 생성**: RankingFirestore extension 구현 완료
- [x] **fromFirestore() 메서드**: DocumentSnapshot → Ranking 변환
- [x] **toFirestore() 메서드**: Ranking → Firestore Map 변환
- [x] **part/part-of 지시자**: ranking.dart와 연결 완료
- [x] **Repository 통합**: Extension 메서드 사용으로 전환 완료
- [x] **빌드 성공**: 0 errors, 0 warnings
- [x] **Phase 1 문서화**: PHASE_1_EITHER_PATTERN.md에 Extension 패턴 기록

### 🔄 TODO: SearchesModel 마이그레이션 (권장)

- [ ] **search_history_extensions.dart 생성**: SearchesModelFirestore extension
- [ ] **fromSnapshot() → fromFirestore() 전환**: Repository 수정
- [ ] **toFirestore() 메서드 추가**: 쓰기 작업 지원
- [ ] **fromSnapshot() 메서드 제거**: 레거시 메서드 정리
- [ ] **빌드 및 분석**: flutter analyze 통과

---

## 📚 참고 자료

### 프로젝트 내부 문서
- [Auth Feature PHASE_4_EXTENSION_PATTERN.md](../auth/PHASE_4_EXTENSION_PATTERN.md)
- [Profile Feature PHASE_4_EXTENSION_PATTERN.md](../profile/PHASE_4_EXTENSION_PATTERN.md)
- [Chat Feature PHASE_5_EXTENSION_PATTERN.md](../chat/PHASE_5_EXTENSION_PATTERN.md)
- [Post Feature PHASE_5_EXTENSION_PATTERN.md](../post/PHASE_5_EXTENSION_PATTERN.md)
- [Notifications Feature PHASE_5_EXTENSION_PATTERN.md](../notifications/PHASE_5_EXTENSION_PATTERN.md)

### 주요 개념
1. **Extension Methods**: Dart extension으로 기존 클래스 확장
2. **part/part-of**: 파일 분리 및 private 멤버 공유
3. **Firebase-Centric**: Firebase를 핵심 인프라로 인정하는 실용적 접근
4. **fromFirestore/toFirestore**: 명명 규칙 통일로 프로젝트 일관성 확보

---

## 🎓 학습 요약

### Extension Pattern의 핵심 원칙

1. **단순화**: DataSource → DTO → Mapper 제거, 1단계 변환
2. **직접성**: Repository가 Firestore 직접 사용
3. **일관성**: 프로젝트 전체에 동일한 패턴 적용
4. **실용성**: Firebase 장기 사용 전제, 불필요한 추상화 제거

### Search Feature 적용 상태

1. **✅ Ranking**: Phase 1에서 Extension Pattern 완료
2. **⚠️ SearchesModel**: fromSnapshot() 레거시 패턴 (전환 권장)
3. **❌ DataSource**: 처음부터 없음 (Firebase-Centric 접근)
4. **❌ DTO/Mapper**: 처음부터 없음

### 프로젝트 전체 일관성

| Feature | Extension Pattern | 상태 |
|---------|------------------|------|
| **Auth** | UserProfileFirestore | ✅ 완료 |
| **Profile** | UserProfileFirestore, UserSettingsFirestore | ✅ 완료 |
| **Chat** | MessageFirestore, ChatFirestore | ✅ 완료 |
| **Notifications** | NotificationFirestore | ✅ 완료 |
| **Post** | PostDisplayFirestore | ⚠️ 마이그레이션 중 |
| **Search** | RankingFirestore | ✅ 완료 |

---

**완료일**: 2025-11-07 (Phase 1에서 조기 적용)
**다음 단계**: Final Verification and Documentation Update

**Note**: Search Feature는 Phase 1에서 Extension Pattern을 조기 적용하여 Phase 5 작업이 거의 완료된 상태입니다. SearchesModel의 fromSnapshot() → fromFirestore() 전환은 선택적 개선사항입니다.
