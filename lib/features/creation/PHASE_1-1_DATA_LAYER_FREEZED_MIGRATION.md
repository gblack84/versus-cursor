# PHASE_1-1: Data Layer Freezed Migration

> **마이그레이션 단계**: Phase 1-1 (Data Layer DTO → Freezed)
> **선행 완료**: Phase 0 (Domain Layer Freezed Migration)
> **다음 단계**: Phase 2 (Either Pattern Migration)
> **예상 기간**: 2-3주
> **난이도**: Low-Medium

---

## 📋 목차

- [개요](#-개요)
- [현재 상태 분석](#-현재-상태-분석)
- [마이그레이션 통계](#-마이그레이션-통계)
- [DTO별 상세 가이드](#-dto별-상세-가이드)
- [Legacy Cleanup 계획](#-legacy-cleanup-계획)
- [실행 체크리스트](#-실행-체크리스트)
- [롤백 전략](#-롤백-전략)

---

## 🎯 개요

### Phase 1-1 목표

**Phase 0에서 완료한 Domain Layer에 이어, Data Layer의 모든 DTO를 Freezed로 마이그레이션**합니다.

**핵심 목표**:
1. ✅ Data Layer 6개 DTO를 Freezed로 전환
2. ✅ 수동 boilerplate 270 lines 제거 (45% 코드 감소)
3. ✅ Domain + Data Layer 일관된 패턴 적용
4. ✅ Type safety 및 immutability 보장
5. ✅ 의존성 파일 모두 업데이트 및 검증

---

### 현재 상태 vs 목표 상태

#### 현재 상태 (Phase 0 완료 후)

```
✅ Domain Layer: 100% Freezed
   - post_creation.dart (aggregates)
   - media_info.dart (entities)
   - media_content.dart (value_objects)
   - target_audience.dart (value_objects)

❌ Data Layer: 0% Freezed
   - video_result_dto.dart (131 lines, manual boilerplate 66 lines)
   - content_moderation_dto.dart (88 lines, manual boilerplate 6 lines)
   - image_result_dto.dart (77 lines, manual boilerplate 36 lines)
   - target_audience_dto.dart (68 lines, manual boilerplate 6 lines)
   - post_creation_dto.dart (59 lines, manual boilerplate 9 lines)
   - image_upload_dto.dart (30 lines, manual boilerplate 6 lines)
```

#### 목표 상태 (Phase 1-1 완료 후)

```
✅ Domain Layer: 100% Freezed (유지)
✅ Data Layer: 100% Freezed
   - video_result.dart (~55 lines, 58% 감소)
   - content_moderation.dart (~50 lines, 43% 감소) or REMOVED
   - image_result.dart (~35 lines, 55% 감소)
   - target_audience_dto.dart (~45 lines, 34% 감소)
   - post_creation_dto.dart (~40 lines, 32% 감소)
   - image_upload_dto.dart (~25 lines, 17% 감소)
```

---

### 예상 효과

**코드 메트릭스**:
```
- 총 코드 감소: 453 → 250 lines (45% 감소)
- 제거되는 boilerplate: ~270 lines
  - copyWith: ~37 lines (video + image result)
  - operator ==: ~25 lines (video + image result)
  - hashCode: ~15 lines (video + image result)
  - toString: ~30 lines (all DTOs)
  - Other manual code: ~163 lines
```

**품질 개선**:
- ✅ Type-safe immutability (Freezed 보장)
- ✅ Automatic equality (==, hashCode)
- ✅ Pattern matching support (sealed unions)
- ✅ IDE support (auto-completion, refactoring)
- ✅ Consistent patterns (Domain + Data unified)

**개발자 경험**:
- ✅ No more manual copyWith updates
- ✅ No more manual equality implementations
- ✅ Better debugging (auto-generated toString)
- ✅ JSON serialization ready (future-proof)

---

## 📊 현재 상태 분석

### Data Layer DTO 인벤토리

| DTO 파일 | 현재 라인 | Boilerplate | 사용처 수 | 상태 |
|---------|----------|-------------|-----------|------|
| **video_result_dto.dart** | 131 | 66 (50%) | 1 | ❌ Manual |
| **content_moderation_dto.dart** | 88 | 6 (7%) | 0 | ⚠️ UNUSED |
| **image_result_dto.dart** | 77 | 36 (47%) | 1 | ❌ Manual |
| **target_audience_dto.dart** | 68 | 6 (9%) | 2 | ❌ Manual |
| **post_creation_dto.dart** | 59 | 9 (15%) | 3 | ❌ Manual |
| **image_upload_dto.dart** | 30 | 6 (20%) | 1 | ❌ Manual |
| **TOTAL** | **453** | **129 (28%)** | **8** | **0% Freezed** |

### 의존성 맵

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  • create_post_provider_v2.dart                         │
└──────────────────┬──────────────────────────────────────┘
                   │ uses PostCreationDto
                   ▼
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  • create_post_usecase.dart (uses PostCreationDto,      │
│    TargetAudienceDto)                                   │
│  • upload_images_usecase.dart (uses ImageUploadDto)     │
│  • manage_target_audience_usecase.dart                  │
│    (uses TargetAudienceDto)                             │
└──────────────────┬──────────────────────────────────────┘
                   │ uses DTOs
                   ▼
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│  • media_repository_impl.dart                           │
│    (uses VideoResultDto, ImageResultDto)                │
│  • post_creation_mapper.dart                            │
│    (uses PostCreationDto)                               │
└─────────────────────────────────────────────────────────┘
```

---

## 📈 마이그레이션 통계

### 전체 통계

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| **총 라인 수** | 453 | 250 | -45% |
| **Manual boilerplate** | 129 | 0 | -100% |
| **DTO 파일 수** | 6 | 5-6* | 0-16%** |
| **의존성 파일 수** | 8 | 8 | 0% |
| **테스트 필요** | 0 | 30 | +∞ |

\* content_moderation_dto.dart 제거 여부에 따라 5-6개
\*\* content_moderation 제거 시 16% 감소

### DTO별 상세 통계

#### 1. image_upload_dto.dart (우선순위 1 - 가장 쉬움)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 30 |
| **Freezed 후 라인 수** | 25 |
| **코드 감소** | 17% |
| **Boilerplate 라인** | 6 (toString) |
| **필드 수** | 3 |
| **의존성** | 1 (upload_images_usecase.dart) |
| **복잡도** | Low |
| **Breaking Changes** | Import update only |
| **예상 소요 시간** | 1-2 hours |

#### 2. image_result_dto.dart (우선순위 2 - 중간 복잡도)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 77 |
| **Freezed 후 라인 수** | 35 |
| **코드 감소** | 55% |
| **Boilerplate 라인** | 36 (copyWith, ==, hashCode, toString) |
| **필드 수** | 4 |
| **의존성** | 1 (media_repository_impl.dart) |
| **복잡도** | Low |
| **Breaking Changes** | Rename class, update imports |
| **예상 소요 시간** | 2-3 hours |

#### 3. target_audience_dto.dart (우선순위 3 - 중간 복잡도)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 68 |
| **Freezed 후 라인 수** | 45 |
| **코드 감소** | 34% |
| **Boilerplate 라인** | 6 (toString) |
| **필드 수** | 7 |
| **의존성** | 2 (manage_target_audience_usecase, create_post_usecase) |
| **복잡도** | Low |
| **Breaking Changes** | Import updates in 2 files |
| **예상 소요 시간** | 2-3 hours |

#### 4. post_creation_dto.dart (우선순위 4 - 중간 복잡도)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 59 |
| **Freezed 후 라인 수** | 40 |
| **코드 감소** | 32% |
| **Boilerplate 라인** | 9 (toString) |
| **필드 수** | 7 (+ TargetAudience reference) |
| **의존성** | 3 (usecase, mapper, provider) |
| **복잡도** | Low-Medium |
| **Breaking Changes** | Mapper refactoring 필요 |
| **예상 소요 시간** | 3-4 hours |

#### 5. video_result_dto.dart (우선순위 5 - 가장 복잡함)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 131 |
| **Freezed 후 라인 수** | 55 |
| **코드 감소** | 58% |
| **Boilerplate 라인** | 66 (copyWith 24, == 15, hashCode 11, toString 4, other 12) |
| **필드 수** | 10 |
| **의존성** | 1 (media_repository_impl.dart) |
| **복잡도** | Medium |
| **Breaking Changes** | Rename class, update imports |
| **예상 소요 시간** | 3-4 hours |

#### 6. content_moderation_dto.dart (우선순위 6 - 특수 케이스)

| 항목 | 값 |
|------|-----|
| **현재 라인 수** | 88 |
| **Freezed 후 라인 수** | 50 (sealed union) |
| **코드 감소** | 43% |
| **Boilerplate 라인** | 6 (toString) |
| **필드 수** | 5 |
| **의존성** | 0 (⚠️ UNUSED) |
| **복잡도** | Medium (sealed union pattern) |
| **Breaking Changes** | Potentially REMOVE entirely |
| **예상 소요 시간** | 1 hour (removal) or 4-5 hours (sealed union) |
| **⚠️ 권장 사항** | **REMOVE if truly unused** |

---

## 🔧 DTO별 상세 가이드

### 1. image_upload_dto.dart

#### 난이도: ★☆☆☆☆ (Low)
#### 우선순위: 1 (Start here - 가장 쉬움)

---

#### 현재 코드 (30 lines)

```dart
import 'dart:io';

/// DTO for uploading images to Firebase Storage
class ImageUploadDto {
  final List<File> images;
  final String box; // 'A' or 'B'
  final String userId;

  const ImageUploadDto({
    required this.images,
    required this.box,
    required this.userId,
  });

  // Business logic
  bool get isValidBox => box == 'A' || box == 'B';

  // Getter
  int get imageCount => images.length;

  @override
  String toString() {
    return 'ImageUploadDto('
        'images: ${images.length}, '
        'box: $box, '
        'userId: $userId)';
  }
}
```

---

#### Freezed 변환 후 (25 lines)

```dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_upload_dto.freezed.dart';

/// DTO for uploading images to Firebase Storage
@freezed
class ImageUploadDto with _$ImageUploadDto {
  const ImageUploadDto._(); // Private constructor for custom methods

  const factory ImageUploadDto({
    required List<File> images,
    required String box, // 'A' or 'B'
    required String userId,
  }) = _ImageUploadDto;

  // Business logic (preserved from original)
  bool get isValidBox => box == 'A' || box == 'B';

  // Getter (preserved from original)
  int get imageCount => images.length;
}
```

---

#### 변경 사항

**추가**:
- ✅ `@freezed` annotation
- ✅ `part 'image_upload_dto.freezed.dart';`
- ✅ `const ImageUploadDto._();` for custom methods
- ✅ `with _$ImageUploadDto` mixin

**제거**:
- ❌ Manual `toString` override (auto-generated)
- ❌ Manual constructor (Freezed factory)

**유지**:
- ✅ Custom getters: `isValidBox`, `imageCount`
- ✅ Business logic 동일
- ✅ Field types 동일

---

#### Breaking Changes

**Import 업데이트 필요**:
```dart
// Before
import '../data/models/image_upload_dto.dart';

// After (동일 - breaking change 없음)
import '../data/models/image_upload_dto.dart';
```

**사용 방법 변경 없음**:
```dart
// Before & After 동일
final dto = ImageUploadDto(
  images: [file1, file2],
  box: 'A',
  userId: 'user123',
);

print(dto.isValidBox); // true
print(dto.imageCount); // 2
```

---

#### 의존성 파일 업데이트

**1. upload_images_usecase.dart** (lib/features/creation/domain/usecases/media/)

```dart
// ✅ Import는 변경 없음
import '../../../data/models/image_upload_dto.dart';

// ✅ 사용 방법도 동일
final dto = ImageUploadDto(
  images: images,
  box: box,
  userId: userId,
);
```

**✅ No changes required** - API 호환성 유지

---

#### 마이그레이션 체크리스트

- [ ] 1. 백업: `git stash` or `git tag phase1-1-imageupload-start`
- [ ] 2. `image_upload_dto.dart` 파일 수정 (Freezed 적용)
- [ ] 3. `part` directive 추가
- [ ] 4. Code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 5. `image_upload_dto.freezed.dart` 생성 확인
- [ ] 6. `upload_images_usecase.dart` 동작 확인 (import 변경 불필요)
- [ ] 7. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 8. Unit test 작성 (5 tests):
  - [ ] Constructor creates instance correctly
  - [ ] isValidBox returns true for 'A' and 'B'
  - [ ] isValidBox returns false for invalid values
  - [ ] imageCount returns correct count
  - [ ] copyWith works correctly (Freezed auto-generated)
- [ ] 9. Integration test: Upload images flow
- [ ] 10. Git commit: `refactor(creation): Migrate image_upload_dto to Freezed`

---

#### 테스트 예시

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/creation/data/models/image_upload_dto.dart';

void main() {
  group('ImageUploadDto', () {
    test('should create instance with required fields', () {
      final dto = ImageUploadDto(
        images: [File('/path/to/image.jpg')],
        box: 'A',
        userId: 'user123',
      );

      expect(dto.images, hasLength(1));
      expect(dto.box, 'A');
      expect(dto.userId, 'user123');
    });

    test('isValidBox should return true for A and B', () {
      final dtoA = ImageUploadDto(
        images: [],
        box: 'A',
        userId: 'user123',
      );
      final dtoB = ImageUploadDto(
        images: [],
        box: 'B',
        userId: 'user123',
      );

      expect(dtoA.isValidBox, true);
      expect(dtoB.isValidBox, true);
    });

    test('isValidBox should return false for invalid box', () {
      final dto = ImageUploadDto(
        images: [],
        box: 'C',
        userId: 'user123',
      );

      expect(dto.isValidBox, false);
    });

    test('imageCount should return correct count', () {
      final dto = ImageUploadDto(
        images: [File('/path/1.jpg'), File('/path/2.jpg')],
        box: 'A',
        userId: 'user123',
      );

      expect(dto.imageCount, 2);
    });

    test('copyWith should work correctly', () {
      final original = ImageUploadDto(
        images: [File('/path/1.jpg')],
        box: 'A',
        userId: 'user123',
      );

      final copied = original.copyWith(box: 'B');

      expect(copied.box, 'B');
      expect(copied.userId, 'user123');
      expect(copied.images, original.images);
    });
  });
}
```

---

### 2. image_result_dto.dart

#### 난이도: ★★☆☆☆ (Low)
#### 우선순위: 2

---

#### 현재 코드 (77 lines)

```dart
/// DTO for image query results from Firestore
class ImageResultDto {
  final String id;
  final String url;
  final int option;
  final String? parentId;

  const ImageResultDto({
    required this.id,
    required this.url,
    required this.option,
    this.parentId,
  });

  /// Factory constructor for Firestore deserialization
  factory ImageResultDto.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ImageResultDto(
      id: id,
      url: data['url'] as String? ?? '',
      option: data['option'] as int? ?? 0,
      parentId: data['parentId'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'option': option,
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// Create a copy with modified fields
  ImageResultDto copyWith({
    String? id,
    String? url,
    int? option,
    String? parentId,
  }) {
    return ImageResultDto(
      id: id ?? this.id,
      url: url ?? this.url,
      option: option ?? this.option,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  String toString() {
    return 'ImageResultDto(id: $id, url: $url, option: $option, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageResultDto &&
        other.id == id &&
        other.url == url &&
        other.option == option &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode ^ option.hashCode ^ parentId.hashCode;
  }
}
```

---

#### Freezed 변환 후 (35 lines)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_result.freezed.dart';

/// DTO for image query results from Firestore
@freezed
class ImageResult with _$ImageResult {
  const factory ImageResult({
    required String id,
    required String url,
    required int option,
    String? parentId,
  }) = _ImageResult;

  /// Factory constructor for Firestore deserialization
  factory ImageResult.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) =>
      ImageResult(
        id: id,
        url: data['url'] as String? ?? '',
        option: data['option'] as int? ?? 0,
        parentId: data['parentId'] as String?,
      );
}

/// Extension for Firestore serialization
extension ImageResultFirestore on ImageResult {
  Map<String, dynamic> toFirestore() => {
        'url': url,
        'option': option,
        if (parentId != null) 'parentId': parentId,
      };
}
```

---

#### 변경 사항

**추가**:
- ✅ `@freezed` annotation
- ✅ `part 'image_result.freezed.dart';`
- ✅ Extension for `toFirestore()`

**제거** (자동 생성됨):
- ❌ Manual `copyWith` (13 lines → Freezed auto-generates)
- ❌ Manual `toString` (3 lines → Freezed auto-generates)
- ❌ Manual `operator ==` (10 lines → Freezed auto-generates)
- ❌ Manual `hashCode` (4 lines → Freezed auto-generates)

**유지**:
- ✅ `fromFirestore()` factory (custom logic)
- ✅ `toFirestore()` method (moved to extension)
- ✅ Field types 동일

**파일명 변경**:
- Before: `image_result_dto.dart`
- After: `image_result.dart` (DTO suffix 제거)

---

#### Breaking Changes

**Import 업데이트 필요**:
```dart
// Before
import '../data/models/image_result_dto.dart';

// After
import '../data/models/image_result.dart';
```

**클래스명 변경**:
```dart
// Before
ImageResultDto dto = ImageResultDto.fromFirestore(data, id);

// After
ImageResult result = ImageResult.fromFirestore(data, id);
```

---

#### 의존성 파일 업데이트

**1. media_repository_impl.dart** (lib/features/creation/data/repositories/)

```dart
// Before
import '../models/image_result_dto.dart';

ImageInfo _dtoToImageInfo(ImageResultDto dto) {
  return MediaInfo.image(
    id: dto.id,
    url: dto.url,
    parentId: dto.parentId,
    metadata: {
      'option': dto.option,
    },
  );
}

return snapshot.docs
    .map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
    .map((dto) => _dtoToImageInfo(dto))
    .toList();
```

```dart
// After
import '../models/image_result.dart';

ImageInfo _resultToImageInfo(ImageResult result) {
  return MediaInfo.image(
    id: result.id,
    url: result.url,
    parentId: result.parentId,
    metadata: {
      'option': result.option,
    },
  );
}

return snapshot.docs
    .map((doc) => ImageResult.fromFirestore(doc.data(), doc.id))
    .map((result) => _resultToImageInfo(result))
    .toList();
```

**변경 사항**:
- Import path 업데이트
- `ImageResultDto` → `ImageResult` (모든 참조)
- 메서드명 `_dtoToImageInfo` → `_resultToImageInfo` (optional, clarity)

---

#### 마이그레이션 체크리스트

- [ ] 1. 백업: `git stash` or `git tag phase1-1-imageresult-start`
- [ ] 2. 파일명 변경: `image_result_dto.dart` → `image_result.dart`
- [ ] 3. 파일 내용 수정 (Freezed 적용, extension 추가)
- [ ] 4. `media_repository_impl.dart` 업데이트:
  - [ ] Import path 수정
  - [ ] `ImageResultDto` → `ImageResult` 전역 치환
  - [ ] Helper 메서드명 변경 (optional)
- [ ] 5. Code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 6. `image_result.freezed.dart` 생성 확인
- [ ] 7. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 8. Unit test 작성 (5 tests):
  - [ ] fromFirestore deserializes correctly
  - [ ] toFirestore serializes correctly
  - [ ] copyWith works correctly
  - [ ] Equality works correctly
  - [ ] toString includes all fields
- [ ] 9. Integration test: Image query flow
- [ ] 10. Git commit: `refactor(creation): Migrate image_result_dto to Freezed`

---

### 3. target_audience_dto.dart

#### 난이도: ★★☆☆☆ (Low)
#### 우선순위: 3

---

#### 현재 코드 (68 lines)

```dart
/// DTO for target audience data transfer
class TargetAudienceDto {
  final String collectionType;
  final int targetCount;
  final bool isPremium;
  final List<String> selectedInterests;
  final String selectedAgeGroup;
  final String selectedGender;
  final bool activeUserOnly;

  const TargetAudienceDto({
    required this.collectionType,
    required this.targetCount,
    required this.isPremium,
    required this.selectedInterests,
    required this.selectedAgeGroup,
    required this.selectedGender,
    required this.activeUserOnly,
  });

  /// Convert from provider map format
  factory TargetAudienceDto.fromProviderMap(Map<String, dynamic> map) {
    return TargetAudienceDto(
      collectionType: map['type'] as String,
      targetCount: map['targetCount'] as int? ?? 100,
      isPremium: map['isPremium'] as bool? ?? false,
      selectedInterests: map['criteria'] != null
          ? List<String>.from(map['criteria']['interests'] ?? [])
          : const [],
      selectedAgeGroup: map['criteria'] != null
          ? _convertAgeGroupFromMap(map['criteria']['ageGroup'])
          : '전체',
      selectedGender: map['criteria'] != null
          ? map['criteria']['gender'] as String? ?? 'all'
          : 'all',
      activeUserOnly: map['criteria'] != null
          ? map['criteria']['activeUserOnly'] as bool? ?? true
          : true,
    );
  }

  /// Helper method to convert age group from Firebase format
  static String _convertAgeGroupFromMap(String? ageGroup) {
    if (ageGroup == null) return '전체';

    // Inline conversion logic (Clean Architecture compliant)
    const ageMapping = {
      'all': '전체',
      '10s': '10대',
      '20s': '20대',
      '30s': '30대',
      '40s': '40대',
      '50s+': '50대 이상',
    };

    return ageMapping[ageGroup] ?? '전체';
  }

  @override
  String toString() {
    return 'TargetAudienceDto('
        'collectionType: $collectionType, '
        'targetCount: $targetCount, '
        'isPremium: $isPremium, '
        'selectedInterests: $selectedInterests, '
        'selectedAgeGroup: $selectedAgeGroup, '
        'selectedGender: $selectedGender, '
        'activeUserOnly: $activeUserOnly)';
  }
}
```

---

#### Freezed 변환 후 (45 lines)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'target_audience_dto.freezed.dart';

/// DTO for target audience data transfer
@freezed
class TargetAudienceDto with _$TargetAudienceDto {
  const TargetAudienceDto._(); // Private constructor for custom methods

  const factory TargetAudienceDto({
    required String collectionType,
    required int targetCount,
    required bool isPremium,
    required List<String> selectedInterests,
    required String selectedAgeGroup,
    required String selectedGender,
    required bool activeUserOnly,
  }) = _TargetAudienceDto;

  /// Convert from provider map format
  factory TargetAudienceDto.fromProviderMap(Map<String, dynamic> map) =>
      TargetAudienceDto(
        collectionType: map['type'] as String,
        targetCount: map['targetCount'] as int? ?? 100,
        isPremium: map['isPremium'] as bool? ?? false,
        selectedInterests: map['criteria'] != null
            ? List<String>.from(map['criteria']['interests'] ?? [])
            : const [],
        selectedAgeGroup: map['criteria'] != null
            ? _convertAgeGroupFromMap(map['criteria']['ageGroup'])
            : '전체',
        selectedGender: map['criteria'] != null
            ? map['criteria']['gender'] as String? ?? 'all'
            : 'all',
        activeUserOnly: map['criteria'] != null
            ? map['criteria']['activeUserOnly'] as bool? ?? true
            : true,
      );

  /// Helper method to convert age group from Firebase format
  static String _convertAgeGroupFromMap(String? ageGroup) {
    if (ageGroup == null) return '전체';
    const ageMapping = {
      'all': '전체', '10s': '10대', '20s': '20대',
      '30s': '30대', '40s': '40대', '50s+': '50대 이상',
    };
    return ageMapping[ageGroup] ?? '전체';
  }
}
```

---

#### 변경 사항

**추가**:
- ✅ `@freezed` annotation
- ✅ `part 'target_audience_dto.freezed.dart';`
- ✅ `const TargetAudienceDto._();` for static methods

**제거** (자동 생성됨):
- ❌ Manual `toString` (6 lines → Freezed auto-generates)

**유지**:
- ✅ `fromProviderMap()` custom factory
- ✅ `_convertAgeGroupFromMap()` static helper
- ✅ All business logic identical

---

#### Breaking Changes

**Import 업데이트 필요** (2 files):
```dart
// No changes to import path or class name
import '../../../data/models/target_audience_dto.dart';
```

**사용 방법 변경 없음**:
```dart
// Before & After 동일
final dto = TargetAudienceDto.fromProviderMap(providerData);
```

---

#### 의존성 파일 업데이트

**1. manage_target_audience_usecase.dart**
```dart
// ✅ Import 변경 없음
import '../../../data/models/target_audience_dto.dart';

// ✅ 사용 방법 동일
final dto = TargetAudienceDto.fromProviderMap(providerMap);
```

**2. create_post_usecase.dart**
```dart
// ✅ Import 변경 없음
import '../../../data/models/target_audience_dto.dart';

// ✅ 사용 방법 동일 (타입만 체크)
if (targetAudience != null) {
  final dto = TargetAudienceDto(
    collectionType: targetAudience.collectionType,
    // ...
  );
}
```

**✅ 두 파일 모두 변경 불필요** - API 호환성 유지

---

#### 마이그레이션 체크리스트

- [ ] 1. 백업: `git stash` or `git tag phase1-1-targetaudience-start`
- [ ] 2. `target_audience_dto.dart` 파일 수정 (Freezed 적용)
- [ ] 3. Code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 4. `target_audience_dto.freezed.dart` 생성 확인
- [ ] 5. `manage_target_audience_usecase.dart` 동작 확인
- [ ] 6. `create_post_usecase.dart` 동작 확인
- [ ] 7. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 8. Unit test 작성 (5 tests):
  - [ ] fromProviderMap deserializes correctly
  - [ ] Age group conversion works correctly
  - [ ] copyWith works correctly
  - [ ] Equality works correctly
  - [ ] Default values applied correctly
- [ ] 9. Integration test: Target audience selection flow
- [ ] 10. Git commit: `refactor(creation): Migrate target_audience_dto to Freezed`

---

### 4. post_creation_dto.dart

#### 난이도: ★★★☆☆ (Low-Medium)
#### 우선순위: 4

---

#### 현재 코드 (59 lines)

```dart
import 'dart:io';
import '../../domain/models/value_objects/target_audience.dart';

/// DTO for post creation data transfer
class PostCreationDto {
  final String userId;
  final String title;
  final String description;
  final List<File> imagesA;
  final List<File> imagesB;
  final TargetAudience? targetAudience;
  final bool isAnonymous;

  const PostCreationDto({
    required this.userId,
    required this.title,
    required this.description,
    required this.imagesA,
    required this.imagesB,
    this.targetAudience,
    this.isAnonymous = false,
  });

  /// Create from form data
  factory PostCreationDto.fromFormData({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
  }) {
    return PostCreationDto(
      userId: userId,
      title: title,
      description: description,
      imagesA: imagesA,
      imagesB: imagesB,
      targetAudience: targetAudience,
      isAnonymous: isAnonymous,
    );
  }

  @override
  String toString() {
    return 'PostCreationDto('
        'userId: $userId, '
        'title: $title, '
        'description: $description, '
        'imagesA: ${imagesA.length}, '
        'imagesB: ${imagesB.length}, '
        'targetAudience: $targetAudience, '
        'isAnonymous: $isAnonymous)';
  }
}
```

---

#### Freezed 변환 후 (40 lines)

```dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/value_objects/target_audience.dart';

part 'post_creation_dto.freezed.dart';

/// DTO for post creation data transfer
@freezed
class PostCreationDto with _$PostCreationDto {
  const factory PostCreationDto({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    @Default(false) bool isAnonymous,
  }) = _PostCreationDto;

  /// Create from form data
  factory PostCreationDto.fromFormData({
    required String userId,
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
    bool isAnonymous = false,
  }) =>
      PostCreationDto(
        userId: userId,
        title: title,
        description: description,
        imagesA: imagesA,
        imagesB: imagesB,
        targetAudience: targetAudience,
        isAnonymous: isAnonymous,
      );
}
```

---

#### 변경 사항

**추가**:
- ✅ `@freezed` annotation
- ✅ `part 'post_creation_dto.freezed.dart';`
- ✅ `@Default(false)` for isAnonymous

**제거** (자동 생성됨):
- ❌ Manual `toString` (9 lines → Freezed auto-generates)

**유지**:
- ✅ `fromFormData()` custom factory
- ✅ Domain reference: `TargetAudience`
- ✅ `dart:io` File type support

---

#### Breaking Changes

**Import 업데이트 필요** (3 files):
```dart
// No changes to import path or class name
import '../../../data/models/post_creation_dto.dart';
```

**사용 방법 변경 없음**:
```dart
// Before & After 동일
final dto = PostCreationDto.fromFormData(
  userId: userId,
  title: title,
  description: description,
  imagesA: imagesA,
  imagesB: imagesB,
  targetAudience: targetAudience,
  isAnonymous: false,
);
```

---

#### 의존성 파일 업데이트

**1. create_post_provider_v2.dart** (presentation layer)
```dart
// ✅ Import 변경 없음
import '../../../data/models/post_creation_dto.dart';

// ✅ 사용 방법 동일
final dto = PostCreationDto.fromFormData(/* ... */);
```

**2. create_post_usecase.dart** (domain layer)
```dart
// ✅ Import 변경 없음
import '../../../data/models/post_creation_dto.dart';

// ✅ 타입 체크 동일
if (dto.imagesA.isEmpty || dto.imagesB.isEmpty) { /* ... */ }
```

**3. post_creation_mapper.dart** (data layer)
```dart
// ⚠️ Mapper 리팩토링 권장 (optional)
// Before
class PostCreationMapper {
  static PostCreation toDomain(PostCreationDto dto) { /* ... */ }
}

// After (Extension 패턴 권장)
extension PostCreationDtoMapper on PostCreationDto {
  PostCreation toDomain() { /* ... */ }
}
```

**✅ 3개 파일 모두 import/usage 변경 불필요**
**⚠️ Mapper refactoring은 optional** (Phase 5 Extension Pattern에서 처리)

---

#### 마이그레이션 체크리스트

- [ ] 1. 백업: `git stash` or `git tag phase1-1-postcreation-start`
- [ ] 2. `post_creation_dto.dart` 파일 수정 (Freezed 적용)
- [ ] 3. Code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 4. `post_creation_dto.freezed.dart` 생성 확인
- [ ] 5. `create_post_provider_v2.dart` 동작 확인
- [ ] 6. `create_post_usecase.dart` 동작 확인
- [ ] 7. `post_creation_mapper.dart` 동작 확인
- [ ] 8. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 9. Unit test 작성 (5 tests):
  - [ ] fromFormData creates instance correctly
  - [ ] copyWith works correctly
  - [ ] Equality works correctly
  - [ ] Default isAnonymous is false
  - [ ] Domain reference (TargetAudience) works
- [ ] 10. Integration test: Post creation flow (end-to-end)
- [ ] 11. (Optional) Mapper refactoring to extension pattern
- [ ] 12. Git commit: `refactor(creation): Migrate post_creation_dto to Freezed`

---

### 5. video_result_dto.dart

#### 난이도: ★★★☆☆ (Medium)
#### 우선순위: 5

---

#### 현재 코드 (131 lines)

```dart
/// DTO for video query results from Firestore
class VideoResultDto {
  final String id;
  final String url;
  final int duration;
  final String params;
  final String? sourceVideoUrl;
  final String? thumbUrl;
  final String? ownerUid;
  final String? status;
  final DateTime? createdAt;
  final String? parentId;

  const VideoResultDto({
    required this.id,
    required this.url,
    required this.duration,
    required this.params,
    this.sourceVideoUrl,
    this.thumbUrl,
    this.ownerUid,
    this.status,
    this.createdAt,
    this.parentId,
  });

  /// Factory constructor for Firestore deserialization
  factory VideoResultDto.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return VideoResultDto(
      id: id,
      url: data['url'] as String? ?? '',
      duration: data['duration'] as int? ?? 0,
      params: data['params'] as String? ?? '',
      sourceVideoUrl: data['sourceVideoUrl'] as String?,
      thumbUrl: data['thumbUrl'] as String?,
      ownerUid: data['ownerUid'] as String?,
      status: data['status'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      parentId: data['parentId'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'duration': duration,
      'params': params,
      if (sourceVideoUrl != null) 'sourceVideoUrl': sourceVideoUrl,
      if (thumbUrl != null) 'thumbUrl': thumbUrl,
      if (ownerUid != null) 'ownerUid': ownerUid,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// Create a copy with modified fields
  VideoResultDto copyWith({
    String? id,
    String? url,
    int? duration,
    String? params,
    String? sourceVideoUrl,
    String? thumbUrl,
    String? ownerUid,
    String? status,
    DateTime? createdAt,
    String? parentId,
  }) {
    return VideoResultDto(
      id: id ?? this.id,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      params: params ?? this.params,
      sourceVideoUrl: sourceVideoUrl ?? this.sourceVideoUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      ownerUid: ownerUid ?? this.ownerUid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  String toString() {
    return 'VideoResultDto(id: $id, url: $url, duration: $duration, params: $params, '
        'sourceVideoUrl: $sourceVideoUrl, thumbUrl: $thumbUrl, '
        'ownerUid: $ownerUid, status: $status, createdAt: $createdAt, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoResultDto &&
        other.id == id &&
        other.url == url &&
        other.duration == duration &&
        other.params == params &&
        other.sourceVideoUrl == sourceVideoUrl &&
        other.thumbUrl == thumbUrl &&
        other.ownerUid == ownerUid &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        duration.hashCode ^
        params.hashCode ^
        sourceVideoUrl.hashCode ^
        thumbUrl.hashCode ^
        ownerUid.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        parentId.hashCode;
  }
}
```

---

#### Freezed 변환 후 (55 lines)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_result.freezed.dart';

/// DTO for video query results from Firestore
@freezed
class VideoResult with _$VideoResult {
  const factory VideoResult({
    required String id,
    required String url,
    required int duration,
    required String params,
    String? sourceVideoUrl,
    String? thumbUrl,
    String? ownerUid,
    String? status,
    DateTime? createdAt,
    String? parentId,
  }) = _VideoResult;

  /// Factory constructor for Firestore deserialization
  factory VideoResult.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) =>
      VideoResult(
        id: id,
        url: data['url'] as String? ?? '',
        duration: data['duration'] as int? ?? 0,
        params: data['params'] as String? ?? '',
        sourceVideoUrl: data['sourceVideoUrl'] as String?,
        thumbUrl: data['thumbUrl'] as String?,
        ownerUid: data['ownerUid'] as String?,
        status: data['status'] as String?,
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : null,
        parentId: data['parentId'] as String?,
      );
}

/// Extension for Firestore serialization
extension VideoResultFirestore on VideoResult {
  Map<String, dynamic> toFirestore() => {
        'url': url,
        'duration': duration,
        'params': params,
        if (sourceVideoUrl != null) 'sourceVideoUrl': sourceVideoUrl,
        if (thumbUrl != null) 'thumbUrl': thumbUrl,
        if (ownerUid != null) 'ownerUid': ownerUid,
        if (status != null) 'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (parentId != null) 'parentId': parentId,
      };
}
```

---

#### 변경 사항

**추가**:
- ✅ `@freezed` annotation
- ✅ `part 'video_result.freezed.dart';`
- ✅ Extension for `toFirestore()`

**제거** (자동 생성됨):
- ❌ Manual `copyWith` (24 lines → Freezed auto-generates)
- ❌ Manual `toString` (4 lines → Freezed auto-generates)
- ❌ Manual `operator ==` (15 lines → Freezed auto-generates)
- ❌ Manual `hashCode` (11 lines → Freezed auto-generates)

**유지**:
- ✅ `fromFirestore()` custom factory
- ✅ `toFirestore()` method (moved to extension)
- ✅ DateTime parsing logic

**파일명 변경**:
- Before: `video_result_dto.dart`
- After: `video_result.dart` (DTO suffix 제거)

---

#### Breaking Changes

**Import 업데이트 필요**:
```dart
// Before
import '../data/models/video_result_dto.dart';

// After
import '../data/models/video_result.dart';
```

**클래스명 변경**:
```dart
// Before
VideoResultDto dto = VideoResultDto.fromFirestore(data, id);

// After
VideoResult result = VideoResult.fromFirestore(data, id);
```

---

#### 의존성 파일 업데이트

**1. media_repository_impl.dart** (lib/features/creation/data/repositories/)

```dart
// Before
import '../models/video_result_dto.dart';

VideoInfo _dtoToVideoInfo(VideoResultDto dto) {
  return MediaInfo.video(
    id: dto.id,
    url: dto.url,
    parentId: dto.parentId,
    duration: dto.duration.toDouble(),
    createdAt: dto.createdAt,
    thumbnailUrl: dto.thumbUrl?.isNotEmpty == true ? dto.thumbUrl : null,
    metadata: {
      'params': dto.params,
      'sourceVideoUrl': dto.sourceVideoUrl,
      'ownerUid': dto.ownerUid,
      'status': dto.status,
    },
  );
}

return snapshot.docs
    .map((doc) => VideoResultDto.fromFirestore(doc.data(), doc.id))
    .map((dto) => _dtoToVideoInfo(dto))
    .toList();
```

```dart
// After
import '../models/video_result.dart';

VideoInfo _resultToVideoInfo(VideoResult result) {
  return MediaInfo.video(
    id: result.id,
    url: result.url,
    parentId: result.parentId,
    duration: result.duration.toDouble(),
    createdAt: result.createdAt,
    thumbnailUrl: result.thumbUrl?.isNotEmpty == true ? result.thumbUrl : null,
    metadata: {
      'params': result.params,
      'sourceVideoUrl': result.sourceVideoUrl,
      'ownerUid': result.ownerUid,
      'status': result.status,
    },
  );
}

return snapshot.docs
    .map((doc) => VideoResult.fromFirestore(doc.data(), doc.id))
    .map((result) => _resultToVideoInfo(result))
    .toList();
```

**변경 사항**:
- Import path 업데이트
- `VideoResultDto` → `VideoResult` (모든 참조)
- 메서드명 `_dtoToVideoInfo` → `_resultToVideoInfo` (optional)

---

#### 마이그레이션 체크리스트

- [ ] 1. 백업: `git stash` or `git tag phase1-1-videoresult-start`
- [ ] 2. 파일명 변경: `video_result_dto.dart` → `video_result.dart`
- [ ] 3. 파일 내용 수정 (Freezed 적용, extension 추가)
- [ ] 4. `media_repository_impl.dart` 업데이트:
  - [ ] Import path 수정
  - [ ] `VideoResultDto` → `VideoResult` 전역 치환
  - [ ] Helper 메서드명 변경 (optional)
- [ ] 5. Code generation: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 6. `video_result.freezed.dart` 생성 확인
- [ ] 7. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 8. Unit test 작성 (5 tests):
  - [ ] fromFirestore deserializes correctly (all 10 fields)
  - [ ] toFirestore serializes correctly (null handling)
  - [ ] copyWith works correctly (10 fields)
  - [ ] Equality works correctly
  - [ ] DateTime parsing works correctly
- [ ] 9. Integration test: Video query flow
- [ ] 10. Git commit: `refactor(creation): Migrate video_result_dto to Freezed`

---

### 6. content_moderation_dto.dart

#### 난이도: ★★★★☆ (Medium-High)
#### 우선순위: 6 (Special Case)
#### ⚠️ **STATUS: POTENTIALLY UNUSED - REMOVAL RECOMMENDED**

---

#### 현재 코드 (88 lines)

```dart
import 'dart:io';

/// Context enum for content moderation
enum ModerationContext { text, images, fullContent }

/// DTO for content moderation data
class ContentModerationDto {
  final String? title;
  final String? description;
  final List<File>? imagesA;
  final List<File>? imagesB;
  final ModerationContext context;

  const ContentModerationDto({
    this.title,
    this.description,
    this.imagesA,
    this.imagesB,
    required this.context,
  });

  /// Create for text-only content
  factory ContentModerationDto.text({
    required String title,
    required String description,
  }) {
    return ContentModerationDto(
      title: title,
      description: description,
      context: ModerationContext.text,
    );
  }

  /// Create for images-only content
  factory ContentModerationDto.images({
    required List<File> imagesA,
    List<File>? imagesB,
  }) {
    return ContentModerationDto(
      imagesA: imagesA,
      imagesB: imagesB,
      context: ModerationContext.images,
    );
  }

  /// Create for full content (text + images)
  factory ContentModerationDto.fullContent({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) {
    return ContentModerationDto(
      title: title,
      description: description,
      imagesA: imagesA,
      imagesB: imagesB,
      context: ModerationContext.fullContent,
    );
  }

  // Business logic getters
  bool get hasTextContent => title != null && description != null;

  bool get hasImageContent =>
      imagesA != null && imagesA!.isNotEmpty ||
      imagesB != null && imagesB!.isNotEmpty;

  @override
  String toString() {
    return 'ContentModerationDto('
        'title: $title, '
        'description: $description, '
        'imagesA: ${imagesA?.length}, '
        'imagesB: ${imagesB?.length}, '
        'context: $context)';
  }
}
```

---

#### ⚠️ 사용처 분석 결과

**검색 결과**: content_moderation_dto.dart를 import하거나 사용하는 파일이 **0개**

```bash
# 검색 명령어
grep -r "content_moderation" lib/ --include="*.dart" | grep -v "content_moderation_dto.dart"

# 결과: No matches found
```

**결론**: 이 DTO는 **현재 사용되지 않는 코드 (Dead Code)**입니다.

---

#### 권장 사항: 제거 (REMOVE)

**Option 1: 제거 (권장)**
- ✅ Dead code 제거로 유지보수 부담 감소
- ✅ 코드베이스 간소화
- ✅ 불필요한 Freezed 마이그레이션 작업 회피
- ✅ 88 lines 완전 제거

**Option 2: Freezed 마이그레이션 (비권장)**
- ❌ 사용되지 않는 코드에 작업 투자
- ❌ 향후 제거 시 Freezed 마이그레이션 작업 낭비
- ❌ 테스트 작성 불필요한 코드에 대한 투자

---

#### Option 1: 제거 계획 (권장)

**Step 1: 안전성 검증**
```bash
# 1. 전체 코드베이스에서 재검색
grep -r "ContentModeration" lib/ --include="*.dart"
grep -r "ModerationContext" lib/ --include="*.dart"

# 2. 테스트 파일 검색
grep -r "content_moderation" test/ --include="*.dart"

# 3. 문서 검색
grep -r "content_moderation" lib/ --include="*.md"
```

**Step 2: 백업 및 제거**
```bash
# 1. Git 백업
git tag phase1-1-contentmod-removal-backup

# 2. 파일 삭제
rm lib/features/creation/data/models/content_moderation_dto.dart

# 3. 커밋
git commit -m "refactor(creation): Remove unused content_moderation_dto

This DTO was not used anywhere in the codebase.
Removed to reduce maintenance burden and dead code.

- Removed: content_moderation_dto.dart (88 lines)
- Verified: No imports or usages found in codebase
- Impact: None (dead code removal)"
```

---

#### Option 2: Freezed 마이그레이션 (비권장, 참고용)

**사용 여부가 확인되면 다음과 같이 마이그레이션 가능**:

```dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_moderation.freezed.dart';

/// DTO for content moderation data (Freezed sealed union)
@freezed
sealed class ContentModeration with _$ContentModeration {
  const ContentModeration._();

  /// Text-only content
  const factory ContentModeration.text({
    required String title,
    required String description,
  }) = TextModeration;

  /// Images-only content
  const factory ContentModeration.images({
    required List<File> imagesA,
    List<File>? imagesB,
  }) = ImageModeration;

  /// Full content (text + images)
  const factory ContentModeration.fullContent({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) = FullContentModeration;

  /// Check if has text content
  bool get hasTextContent => when(
        text: (_, __) => true,
        images: (_, __) => false,
        fullContent: (_, __, ___, ____) => true,
      );

  /// Check if has image content
  bool get hasImageContent => when(
        text: (_, __) => false,
        images: (imagesA, imagesB) =>
            imagesA.isNotEmpty || (imagesB?.isNotEmpty ?? false),
        fullContent: (_, __, imagesA, imagesB) =>
            imagesA.isNotEmpty || imagesB.isNotEmpty,
      );
}
```

**변경 사항**:
- Enum `ModerationContext` 제거 → Sealed union으로 대체
- Factory constructors 유지 → Freezed factory patterns
- Business logic getters → Pattern matching으로 구현

---

#### 마이그레이션 체크리스트 (제거 권장)

- [ ] 1. 전체 코드베이스 검색으로 사용처 재확인
- [ ] 2. 사용처 **0개 확인 완료**
- [ ] 3. Git 백업: `git tag phase1-1-contentmod-removal-backup`
- [ ] 4. 파일 삭제: `rm lib/features/creation/data/models/content_moderation_dto.dart`
- [ ] 5. `flutter analyze lib/features/creation/` 실행 (에러 0개 확인)
- [ ] 6. Git commit with detailed message
- [ ] 7. Phase 1-1 통계 업데이트 (5 DTOs migrated, 1 removed)

---

## 🔧 Legacy Cleanup 계획

### Phase A: 의존성 파일 업데이트

**완료 후 업데이트 필요한 파일**:

| DTO | 업데이트 필요 파일 | 변경 사항 |
|-----|-------------------|-----------|
| **image_upload_dto** | upload_images_usecase.dart (1) | ✅ No changes |
| **image_result** | media_repository_impl.dart (1) | Import + class rename |
| **target_audience_dto** | manage_target_audience_usecase.dart (1)<br>create_post_usecase.dart (1) | ✅ No changes |
| **post_creation_dto** | create_post_provider_v2.dart (1)<br>create_post_usecase.dart (1)<br>post_creation_mapper.dart (1) | ✅ No changes (mapper optional) |
| **video_result** | media_repository_impl.dart (1) | Import + class rename |
| **content_moderation** | ❌ NONE (UNUSED) | Remove file |

**총 업데이트 필요**: 8개 파일 (실제 변경은 2개만)

---

### Phase B: 파일별 상세 업데이트 가이드

#### 1. media_repository_impl.dart

**현재 위치**: `lib/features/creation/data/repositories/media_repository_impl.dart`

**업데이트 내용**:
```dart
// Before
import '../models/image_result_dto.dart';
import '../models/video_result_dto.dart';

ImageInfo _dtoToImageInfo(ImageResultDto dto) { /* ... */ }
VideoInfo _dtoToVideoInfo(VideoResultDto dto) { /* ... */ }

.map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
.map((doc) => VideoResultDto.fromFirestore(doc.data(), doc.id))
```

```dart
// After
import '../models/image_result.dart';
import '../models/video_result.dart';

ImageInfo _resultToImageInfo(ImageResult result) { /* ... */ }
VideoInfo _resultToVideoInfo(VideoResult result) { /* ... */ }

.map((doc) => ImageResult.fromFirestore(doc.data(), doc.id))
.map((doc) => VideoResult.fromFirestore(doc.data(), doc.id))
```

**자동 치환 스크립트**:
```bash
# Import 업데이트
sed -i '' 's/image_result_dto\.dart/image_result.dart/g' lib/features/creation/data/repositories/media_repository_impl.dart
sed -i '' 's/video_result_dto\.dart/video_result.dart/g' lib/features/creation/data/repositories/media_repository_impl.dart

# Class 이름 치환
sed -i '' 's/ImageResultDto/ImageResult/g' lib/features/creation/data/repositories/media_repository_impl.dart
sed -i '' 's/VideoResultDto/VideoResult/g' lib/features/creation/data/repositories/media_repository_impl.dart

# 메서드명 치환 (optional)
sed -i '' 's/_dtoToImageInfo/_resultToImageInfo/g' lib/features/creation/data/repositories/media_repository_impl.dart
sed -i '' 's/_dtoToVideoInfo/_resultToVideoInfo/g' lib/features/creation/data/repositories/media_repository_impl.dart
```

---

#### 2. post_creation_mapper.dart (Optional Refactoring)

**현재 위치**: `lib/features/creation/data/mappers/post_creation_mapper.dart`

**Option 1: 변경 없음 (Phase 1-1)**
- Mapper class 그대로 유지
- Import만 확인: `import '../models/post_creation_dto.dart';`
- ✅ API 호환성 유지되므로 동작 보장

**Option 2: Extension 패턴 리팩토링 (Phase 5에서 권장)**
```dart
// Before (Mapper class)
class PostCreationMapper {
  static PostCreation toDomain(PostCreationDto dto) {
    return PostCreation(
      userId: dto.userId,
      title: dto.title,
      description: dto.description,
      // ...
    );
  }
}

// After (Extension pattern)
extension PostCreationDtoMapper on PostCreationDto {
  PostCreation toDomain() {
    return PostCreation(
      userId: userId,
      title: title,
      description: description,
      // ...
    );
  }
}

// Usage change
// Before: PostCreationMapper.toDomain(dto)
// After: dto.toDomain()
```

**Phase 1-1 권장 사항**: Option 1 (변경 없음), Phase 5에서 Extension 패턴으로 전환

---

### Phase C: 검증 및 테스트

#### Unit Test 작성 계획 (총 30 tests)

**DTO별 테스트 수**:
| DTO | Test 수 | 주요 테스트 |
|-----|---------|-------------|
| image_upload_dto | 5 | Constructor, validation, copyWith, equality |
| image_result | 5 | Firestore serialization, copyWith, equality |
| target_audience_dto | 5 | fromProviderMap, age conversion, equality |
| post_creation_dto | 5 | fromFormData, domain reference, equality |
| video_result | 5 | Firestore serialization (complex), equality |
| content_moderation | 5 | Sealed union, pattern matching, getters |

**테스트 템플릿** (각 DTO 공통):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/creation/data/models/[dto_name].dart';

void main() {
  group('[DtoName]', () {
    test('should create instance with required fields', () {
      // Arrange & Act
      final dto = [DtoName](/* ... */);

      // Assert
      expect(dto.field1, expectedValue1);
      expect(dto.field2, expectedValue2);
    });

    test('fromFirestore should deserialize correctly', () {
      // Arrange
      final firestoreData = {'field1': 'value1', 'field2': 'value2'};

      // Act
      final dto = [DtoName].fromFirestore(firestoreData, 'id123');

      // Assert
      expect(dto.id, 'id123');
      expect(dto.field1, 'value1');
    });

    test('toFirestore should serialize correctly', () {
      // Arrange
      final dto = [DtoName](/* ... */);

      // Act
      final firestoreData = dto.toFirestore();

      // Assert
      expect(firestoreData['field1'], dto.field1);
      expect(firestoreData['field2'], dto.field2);
    });

    test('copyWith should work correctly', () {
      // Arrange
      final original = [DtoName](/* ... */);

      // Act
      final copied = original.copyWith(field1: 'newValue');

      // Assert
      expect(copied.field1, 'newValue');
      expect(copied.field2, original.field2);
    });

    test('equality should work correctly', () {
      // Arrange
      final dto1 = [DtoName](/* same values */);
      final dto2 = [DtoName](/* same values */);
      final dto3 = [DtoName](/* different values */);

      // Assert
      expect(dto1, dto2); // Equal
      expect(dto1, isNot(dto3)); // Not equal
      expect(dto1.hashCode, dto2.hashCode); // Same hash
    });
  });
}
```

---

#### Integration Test 계획

**Test 1: Image Upload Flow**
```dart
testWidgets('should upload images successfully', (tester) async {
  // 1. Create ImageUploadDto
  final dto = ImageUploadDto(
    images: [testFile1, testFile2],
    box: 'A',
    userId: 'testUser',
  );

  // 2. Call UseCase
  final result = await uploadImagesUseCase(dto);

  // 3. Verify success
  expect(result.isRight(), true);
});
```

**Test 2: Post Creation Flow (End-to-End)**
```dart
testWidgets('should create post with target audience', (tester) async {
  // 1. Create PostCreationDto
  final dto = PostCreationDto.fromFormData(
    userId: 'testUser',
    title: 'Test Post',
    description: 'Test Description',
    imagesA: [fileA1, fileA2],
    imagesB: [fileB1, fileB2],
    targetAudience: targetAudienceFixture,
  );

  // 2. Call UseCase
  final result = await createPostUseCase(dto);

  // 3. Verify Firestore
  expect(result.isRight(), true);
  final postId = result.getOrElse(() => '');
  final firestoreDoc = await firestore.collection('posts').doc(postId).get();
  expect(firestoreDoc.exists, true);
});
```

---

### Phase D: 문서 업데이트

**업데이트 필요 문서**:
1. `lib/features/creation/README.md` - Data Layer 섹션 업데이트
2. `lib/features/creation/data/README.md` - DTO 목록 업데이트
3. `CLAUDE.md` - Creation Feature 상태 업데이트

**예시 업데이트**:
```markdown
## Data Layer (100% Freezed ✅)

### DTOs
- ✅ **image_upload_dto.dart** - Freezed (Phase 1-1)
- ✅ **image_result.dart** - Freezed (Phase 1-1, renamed)
- ✅ **target_audience_dto.dart** - Freezed (Phase 1-1)
- ✅ **post_creation_dto.dart** - Freezed (Phase 1-1)
- ✅ **video_result.dart** - Freezed (Phase 1-1, renamed)
- ❌ **content_moderation_dto.dart** - REMOVED (unused)

**Total**: 5 DTOs (453 → 250 lines, 45% reduction)
```

---

## ✅ 실행 체크리스트

### 전체 Phase 1-1 마이그레이션 체크리스트

#### Week 1: Simple DTOs
- [ ] **Day 1-2: image_upload_dto.dart**
  - [ ] Freezed 변환
  - [ ] Code generation
  - [ ] Unit tests (5)
  - [ ] Integration test
  - [ ] Git commit

- [ ] **Day 3-4: image_result_dto.dart**
  - [ ] Rename file
  - [ ] Freezed 변환
  - [ ] Update media_repository_impl.dart
  - [ ] Code generation
  - [ ] Unit tests (5)
  - [ ] Git commit

- [ ] **Day 5: target_audience_dto.dart**
  - [ ] Freezed 변환
  - [ ] Code generation
  - [ ] Verify 2 usecases
  - [ ] Unit tests (5)
  - [ ] Git commit

#### Week 2: Complex DTOs
- [ ] **Day 1-2: post_creation_dto.dart**
  - [ ] Freezed 변환
  - [ ] Code generation
  - [ ] Verify 3 dependencies
  - [ ] Unit tests (5)
  - [ ] Integration test (end-to-end)
  - [ ] Git commit

- [ ] **Day 3-4: video_result_dto.dart**
  - [ ] Rename file
  - [ ] Freezed 변환
  - [ ] Update media_repository_impl.dart
  - [ ] Code generation
  - [ ] Unit tests (5)
  - [ ] Git commit

#### Week 3: Cleanup & Testing
- [ ] **Day 1: content_moderation_dto.dart**
  - [ ] Verify unused status
  - [ ] Remove file
  - [ ] Git commit

- [ ] **Day 2-3: Integration Testing**
  - [ ] Image upload flow
  - [ ] Video query flow
  - [ ] Post creation flow (end-to-end)
  - [ ] Target audience selection flow

- [ ] **Day 4: Documentation**
  - [ ] Update Creation Feature README
  - [ ] Update Data Layer README
  - [ ] Update CLAUDE.md

- [ ] **Day 5: Final Verification**
  - [ ] `flutter analyze` (0 errors)
  - [ ] All unit tests passing (30 tests)
  - [ ] All integration tests passing (4 tests)
  - [ ] Code coverage report
  - [ ] Final commit and tag

---

### Daily Checklist Template

**매일 작업 시작 전**:
- [ ] `git pull origin [branch]` (최신 코드 동기화)
- [ ] `flutter clean && flutter pub get` (의존성 정리)
- [ ] `flutter analyze` (baseline 에러 확인)
- [ ] Git backup tag: `git tag phase1-1-day[N]-backup`

**DTO 마이그레이션 작업 중**:
- [ ] Read 도구로 현재 DTO 파일 확인
- [ ] Freezed 패턴 적용
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] .freezed.dart 파일 생성 확인
- [ ] 의존성 파일 업데이트 (필요 시)
- [ ] `flutter analyze lib/features/creation/` (에러 0개)

**매일 작업 종료 전**:
- [ ] Unit test 작성 및 실행
- [ ] Git commit with detailed message
- [ ] Push to remote (optional, 팀 정책에 따라)
- [ ] Todo 리스트 업데이트

---

## 🚨 롤백 전략

### Rollback Plan

**Level 1: 단일 DTO 롤백** (작업 중 문제 발생)
```bash
# 1. 현재 변경사항 확인
git status

# 2. 특정 파일만 롤백
git checkout HEAD -- lib/features/creation/data/models/[dto_name].dart

# 3. 생성된 Freezed 파일 삭제
rm lib/features/creation/data/models/[dto_name].freezed.dart

# 4. 의존성 파일 롤백 (필요 시)
git checkout HEAD -- [dependency_file].dart
```

**Level 2: Daily Rollback** (하루 작업 전체 롤백)
```bash
# 1. Daily backup tag로 복원
git reset --hard phase1-1-day[N]-backup

# 2. 생성된 파일 정리
flutter clean
dart run build_runner clean

# 3. 재시작
flutter pub get
```

**Level 3: Phase 1-1 전체 롤백** (Phase 0으로 복귀)
```bash
# 1. Phase 0 완료 지점으로 복원
git reset --hard phase0-freezed-migration-complete

# 2. 전체 정리
flutter clean
dart run build_runner clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

### Backup 전략

**Git Tag 생성 규칙**:
```bash
# Phase 시작
git tag phase1-1-data-layer-migration-start

# 각 DTO 마이그레이션 전
git tag phase1-1-[dto_name]-start

# 각 DTO 마이그레이션 완료
git tag phase1-1-[dto_name]-complete

# 일일 백업
git tag phase1-1-day[N]-backup

# Phase 완료
git tag phase1-1-data-layer-migration-complete
```

**파일 백업 (중요 파일만)**:
```bash
# Repository impl 백업 (가장 많이 수정되는 파일)
cp lib/features/creation/data/repositories/media_repository_impl.dart \
   lib/features/creation/data/repositories/media_repository_impl.dart.backup
```

---

## 📊 완료 검증 체크리스트

### Phase 1-1 완료 기준

**Code Metrics** (모두 충족 필요):
- [ ] Total DTO count: 5-6 (content_moderation 제거 시 5)
- [ ] Total lines: ~250 (453 → 250, 45% reduction)
- [ ] Manual boilerplate: 0 lines (129 → 0, 100% elimination)
- [ ] Freezed adoption: 100% (all DTOs)

**Quality Gates**:
- [ ] `flutter analyze lib/features/creation/`: 0 errors
- [ ] Unit tests: 30 tests passing (or 25 if content_moderation removed)
- [ ] Integration tests: 4 tests passing
- [ ] Code coverage: ≥80% for DTOs

**Documentation**:
- [ ] Creation Feature README updated
- [ ] Data Layer README updated
- [ ] CLAUDE.md updated
- [ ] Phase 1-1 document marked complete

**Git**:
- [ ] All changes committed with clear messages
- [ ] Git tags created (start, complete)
- [ ] No uncommitted changes
- [ ] Ready for Phase 2 (Either Pattern)

---

## 🎯 다음 단계 (Phase 2)

**Phase 1-1 완료 후 진행**:
- **Phase 2: Either Pattern Migration**
  - Repository interfaces → `Either<Failure, Success>` 전환
  - UseCase error handling 통일
  - Failure sealed classes 정의

**예상 기간**: 2-3주
**난이도**: Medium-High
**Prerequisites**: Phase 1-1 완료 (100% Freezed)

---

## 📚 참고 문서

- **PHASE_0_FREEZED_MIGRATION.md** - Domain Layer Freezed 마이그레이션 (선행 완료)
- **Freezed Documentation**: https://pub.dev/packages/freezed
- **Clean Architecture Guide**: lib/features/auth/README.md (참고 구현)
- **Git Tag Strategy**: CLAUDE.md - Migration History

---

**문서 생성**: 2025-11-03
**Phase**: 1-1 (Data Layer Freezed Migration)
**예상 완료**: 2025-11-24 (3주)
**Status**: Ready to Execute

---

## 📝 작성자 노트

이 문서는 Creation Feature의 Data Layer DTO 6개를 Freezed로 마이그레이션하기 위한 **상세 실행 가이드**입니다.

**핵심 포인트**:
1. **순차 실행**: image_upload → image_result → target_audience → post_creation → video_result → content_moderation (removal)
2. **매일 백업**: Git tag로 롤백 포인트 확보
3. **테스트 필수**: 각 DTO당 5개 unit test 작성
4. **점진적 검증**: 각 DTO 완료 후 `flutter analyze` 실행

**성공 기준**:
- ✅ 45% 코드 감소 (453 → 250 lines)
- ✅ 100% Freezed 적용 (all DTOs)
- ✅ 0 breaking changes (API compatibility)
- ✅ 30 tests passing

**예상 효과**:
- 🚀 개발 속도 향상 (auto-generated boilerplate)
- 🛡️ Type safety 강화 (immutability, equality)
- 📖 가독성 개선 (consistent patterns)
- 🧹 유지보수 간소화 (less manual code)
