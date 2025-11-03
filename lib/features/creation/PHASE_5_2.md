# Creation Feature - Phase 5: Extension Pattern (Part 2/3)

> **문서 버전**: 1.0.0
> **작성일**: 2025-11-03
> **대상 Feature**: Creation Feature
> **Phase**: 5 - Extension Pattern (Firebase-Centric v2.0)
> **Part**: 2/3 (섹션 4-5: 구현 가이드, Before/After 코드)

---

## 📋 목차 (Part 2)

- [단계별 마이그레이션 가이드](#-단계별-마이그레이션-가이드)
- [Before/After 전체 코드](#-beforeafter-전체-코드)

**이전 문서**: [PHASE_5_1.md](./PHASE_5_1.md) - 개요, 분석, 목표
**다음 문서**: [PHASE_5_3.md](./PHASE_5_3.md) - 테스트, 롤백, 일정

---

## 📝 단계별 마이그레이션 가이드

### 마이그레이션 순서 개요

```
Step 1: Extension 파일 3개 생성 (2-3일)
  ├── post_creation_extensions.dart (~180줄)
  ├── media_info_extensions.dart (~120줄)
  └── target_audience_extensions.dart (~60줄)

Step 2: Repository 순차 전환 (5-7일)
  ├── [독립 Repository] ImageProcessingRepositoryImpl
  ├── [독립 Repository] TargetAudienceRepositoryImpl
  ├── [독립 Repository] ContentModerationRepositoryImpl
  ├── [독립 Repository] ContentVisibilityRepositoryImpl
  ├── [독립 Repository] ContentMetricsRepositoryImpl
  ├── [의존성] MediaRepositoryImpl (MediaInfo Extension 사용)
  ├── [의존성] MediaUploadRepositoryImpl (MediaRepository 사용)
  └── [최종] PostCreationRepositoryV2Impl (모든 것 사용)

Step 3: Storage DataSource 특수 처리 (1일)
Step 4: Legacy 파일 삭제 (1일)
Step 5: DI 모듈 업데이트 (0.5일)
Step 6: 검증 (1일)

Total: 10-12일
```

---

## Step 1: Extension 파일 3개 생성

### 1.1. PostCreation Extension 생성

**파일 생성**: `lib/features/creation/domain/entities/post_creation_extensions.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_creation.dart';
import 'post_option.dart';
import 'vote_configuration.dart';
import '../value_objects/target_audience.dart';

/// PostCreation Entity ↔ Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - Helper 함수로 타입 안전성 확보
/// - Null-safe 기본값 제공
///
/// **Phase 통합**:
/// - Phase 1 (Freezed): toJson() 재활용
/// - Phase 2 (Either): 타입 안전 변환
/// - Phase 3 (Cache): Entity 직접 캐싱
/// - Phase 4 (Idempotency): eventId 자동 처리
///
/// **마이그레이션 정보**:
/// - Phase 5에서 DTO (58줄) + Mapper (294줄) → Extension (~180줄)
/// - 352줄 → 180줄 (49% 감소)
extension PostCreationFirestore on PostCreation {
  /// Firestore DocumentSnapshot → PostCreation Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('posts').doc(postId).get();
  /// final post = PostCreationFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **지원하는 Firestore 필드 형식**:
  /// - `createdAt`: Timestamp, int (milliseconds), String (ISO 8601)
  /// - `optionA/B`: Map<String, dynamic> with text, images, videos
  /// - `voteConfiguration`: Map<String, dynamic> with startTime, endTime
  /// - `targetAudience`: Map<String, dynamic> with gender, ageRange, interests
  static PostCreation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostCreation(
      // Identification
      id: doc.id,
      userId: data['userId'] as String? ?? '',

      // Content
      questionTitle: data['questionTitle'] as String? ?? '',
      description: data['description'] as String?,

      // Options (Nested structures)
      optionA: _parsePostOption(data['optionA']),
      optionB: _parsePostOption(data['optionB']),

      // Vote Configuration (Nested structure)
      voteConfiguration: _parseVoteConfig(data['voteConfiguration']),

      // Target Audience (Nested structure)
      targetAudience: TargetAudienceFirestore.fromMap(data['targetAudience']),

      // Timestamps
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      scheduledAt: _parseDateTime(data['scheduledAt']),
      publishedAt: _parseDateTime(data['publishedAt']),

      // Status
      status: data['status'] as String? ?? 'draft',
      isAnonymous: data['isAnonymous'] as bool? ?? false,

      // Media
      mediaUrls: _parseStringList(data['mediaUrls']),

      // Phase 4: Idempotency
      eventId: data['eventId'] as String?,

      // AI Integration
      aiGeneratedTitle: data['aiGeneratedTitle'] as String?,
      moderationStatus: data['moderationStatus'] as String?,
    );
  }

  /// PostCreation Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final post = PostCreation(...);
  /// await firestore.collection('posts').doc(post.id).set(post.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // Identification
      'userId': userId,

      // Content
      'questionTitle': questionTitle,
      if (description != null) 'description': description,

      // Options (Nested structures)
      'optionA': optionA.toFirestore(),
      'optionB': optionB.toFirestore(),

      // Vote Configuration
      'voteConfiguration': voteConfiguration.toFirestore(),

      // Target Audience
      'targetAudience': targetAudience.toMap(),

      // Timestamps
      'createdAt': Timestamp.fromDate(createdAt),
      if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt!),
      if (publishedAt != null) 'publishedAt': Timestamp.fromDate(publishedAt!),

      // Status
      'status': status,
      'isAnonymous': isAnonymous,

      // Media
      'mediaUrls': mediaUrls,

      // Phase 4: Idempotency
      if (eventId != null) 'eventId': eventId,

      // AI Integration
      if (aiGeneratedTitle != null) 'aiGeneratedTitle': aiGeneratedTitle,
      if (moderationStatus != null) 'moderationStatus': moderationStatus,
    };
  }

  // ========== Helper Functions ==========

  /// PostOption 파싱 (nested structure)
  ///
  /// **예시**:
  /// ```dart
  /// final optionData = {
  ///   'text': 'Option A',
  ///   'images': ['url1', 'url2'],
  ///   'videos': ['url3'],
  ///   'aspectRatios': [1.5, 1.2],
  /// };
  /// final option = _parsePostOption(optionData);
  /// ```
  static PostOption _parsePostOption(dynamic data) {
    if (data == null) return PostOption.empty();

    final map = data as Map<String, dynamic>;

    return PostOption(
      text: map['text'] as String?,
      images: _parseStringList(map['images']),
      videos: _parseStringList(map['videos']),
      aspectRatios: _parseDoubleList(map['aspectRatios']),
    );
  }

  /// VoteConfiguration 파싱
  ///
  /// **기본값**: startTime/endTime이 없으면 즉시 투표 시작
  static VoteConfiguration _parseVoteConfig(dynamic data) {
    if (data == null) return VoteConfiguration.default_();

    final map = data as Map<String, dynamic>;

    return VoteConfiguration(
      startTime: _parseDateTime(map['startTime']),
      endTime: _parseDateTime(map['endTime']),
      maxVotesPerUser: map['maxVotesPerUser'] as int? ?? 1,
      allowRevote: map['allowRevote'] as bool? ?? false,
      voteVisibility: map['voteVisibility'] as String? ?? 'public',
    );
  }

  /// DateTime 안전 파싱 (Timestamp/int/String 지원)
  ///
  /// **지원 형식**:
  /// - `Timestamp` → toDate()
  /// - `int` → fromMillisecondsSinceEpoch()
  /// - `String` → tryParse() (ISO 8601)
  /// - `DateTime` → 그대로 반환
  /// - `null` → null 반환
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// String List 안전 파싱
  ///
  /// **필터링**:
  /// - String 타입만 추출
  /// - 빈 문자열 제거
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Double List 안전 파싱 (aspectRatios용)
  ///
  /// **타입 변환**:
  /// - `double` → 그대로
  /// - `int` → toDouble()
  /// - `String` → tryParse() (실패 시 1.0)
  /// - 기타 → 1.0 (기본값)
  static List<double> _parseDoubleList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) {
        if (e is double) return e;
        if (e is int) return e.toDouble();
        if (e is String) return double.tryParse(e) ?? 1.0;
        return 1.0;
      }).toList();
    }
    return [];
  }
}

/// PostOption → Firestore Extension
extension PostOptionFirestore on PostOption {
  Map<String, dynamic> toFirestore() {
    return {
      if (text != null) 'text': text,
      'images': images,
      'videos': videos,
      'aspectRatios': aspectRatios,
    };
  }
}

/// VoteConfiguration → Firestore Extension
extension VoteConfigurationFirestore on VoteConfiguration {
  Map<String, dynamic> toFirestore() {
    return {
      if (startTime != null) 'startTime': Timestamp.fromDate(startTime!),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
      'maxVotesPerUser': maxVotesPerUser,
      'allowRevote': allowRevote,
      'voteVisibility': voteVisibility,
    };
  }
}
```

**코드 감소**:
- DTO (58줄) + Mapper (294줄) = 352줄
- Extension = 180줄
- **감소: 49% (172줄)**

---

### 1.2. MediaInfo Extension 생성 (Sealed Class 지원)

**파일 생성**: `lib/features/creation/domain/entities/media_info_extensions.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../value_objects/media_info.dart';

/// MediaInfo (Sealed Class) ↔ Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Sealed Class when() 패턴 매칭 활용
/// - ImageInfo | VideoInfo 구분 변환
/// - 모든 필드 보존 (DTO 필드 누락 해결)
///
/// **Phase 1 통합**:
/// - Freezed Sealed Class 직접 변환
/// - when() exhaustive pattern matching
///
/// **마이그레이션 정보**:
/// - Phase 5에서 ImageResultDto (76줄) + VideoResultDto (130줄) → Extension (~120줄)
/// - 206줄 → 120줄 (42% 감소)
extension MediaInfoFirestore on MediaInfo {
  /// Firestore Map → MediaInfo (Sealed Class)
  ///
  /// **Sealed Class 처리**:
  /// - `type: 'image'` → ImageInfo
  /// - `type: 'video'` → VideoInfo
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('media').doc(id).get();
  /// final data = doc.data() as Map<String, dynamic>;
  /// final mediaInfo = MediaInfoFirestore.fromFirestore(data);
  ///
  /// // Pattern matching
  /// mediaInfo.when(
  ///   image: (info) => print('Image: ${info.url}'),
  ///   video: (info) => print('Video: ${info.duration}s'),
  /// );
  /// ```
  static MediaInfo fromFirestore(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'image';

    // Sealed class pattern matching
    if (type == 'image') {
      return ImageInfo(
        id: data['id'] as String? ?? '',
        url: data['url'] as String? ?? '',
        parentId: data['parentId'] as String?,

        // Image-specific fields (DTO에서 누락되었던 필드들)
        width: _parseInt(data['width']),
        height: _parseInt(data['height']),
        aspectRatio: _parseDouble(data['aspectRatio']),

        // Common fields
        size: _parseInt(data['size']),
        uploadedAt: _parseDateTime(data['uploadedAt']) ?? DateTime.now(),
        uploadedBy: data['uploadedBy'] as String? ?? '',
      );
    } else {
      return VideoInfo(
        id: data['id'] as String? ?? '',
        url: data['url'] as String? ?? '',
        parentId: data['parentId'] as String?,

        // Video-specific fields
        duration: _parseInt(data['duration']),
        thumbnailUrl: data['thumbnailUrl'] as String?,

        // Common fields
        width: _parseInt(data['width']),
        height: _parseInt(data['height']),
        aspectRatio: _parseDouble(data['aspectRatio']),
        size: _parseInt(data['size']),
        uploadedAt: _parseDateTime(data['uploadedAt']) ?? DateTime.now(),
        uploadedBy: data['uploadedBy'] as String? ?? '',
      );
    }
  }

  /// MediaInfo (Sealed Class) → Firestore Map
  ///
  /// **when() pattern matching 활용**:
  /// - ImageInfo → {type: 'image', ...}
  /// - VideoInfo → {type: 'video', duration, thumbnailUrl, ...}
  ///
  /// **사용 예시**:
  /// ```dart
  /// final imageInfo = ImageInfo(...);
  /// await firestore.collection('media').doc(id).set(
  ///   imageInfo.toFirestore(),
  /// );
  /// ```
  Map<String, dynamic> toFirestore() {
    return when(
      image: (info) => {
        'type': 'image',
        'id': info.id,
        'url': info.url,
        if (info.parentId != null) 'parentId': info.parentId,

        // Image-specific fields
        if (info.width != null) 'width': info.width,
        if (info.height != null) 'height': info.height,
        if (info.aspectRatio != null) 'aspectRatio': info.aspectRatio,

        // Common fields
        if (info.size != null) 'size': info.size,
        'uploadedAt': Timestamp.fromDate(info.uploadedAt),
        'uploadedBy': info.uploadedBy,
      },
      video: (info) => {
        'type': 'video',
        'id': info.id,
        'url': info.url,
        if (info.parentId != null) 'parentId': info.parentId,

        // Video-specific fields
        if (info.duration != null) 'duration': info.duration,
        if (info.thumbnailUrl != null) 'thumbnailUrl': info.thumbnailUrl,

        // Common fields
        if (info.width != null) 'width': info.width,
        if (info.height != null) 'height': info.height,
        if (info.aspectRatio != null) 'aspectRatio': info.aspectRatio,
        if (info.size != null) 'size': info.size,
        'uploadedAt': Timestamp.fromDate(info.uploadedAt),
        'uploadedBy': info.uploadedBy,
      },
    );
  }

  // ========== Helper Functions ==========

  /// Int 파싱 (nullable)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Double 파싱 (nullable)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// DateTime 파싱
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
```

**핵심 개선사항**:
1. **Sealed Class 완전 지원**: when() 패턴 매칭으로 ImageInfo/VideoInfo 구분
2. **필드 누락 해결**: DTO에서 누락되었던 width, height, aspectRatio 복원
3. **타입 안전성**: 컴파일 타임에 모든 경우 처리 보장

---

### 1.3. TargetAudience Extension 생성

**파일 생성**: `lib/features/creation/domain/value_objects/target_audience_extensions.dart`

```dart
/// TargetAudience ↔ Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Map<String, dynamic> ↔ TargetAudience 변환
/// - criteria Map 완전 보존
///
/// **마이그레이션 정보**:
/// - Phase 5에서 TargetAudienceDto (67줄) + Mapper (96줄) → Extension (~60줄)
/// - 163줄 → 60줄 (63% 감소)
extension TargetAudienceFirestore on TargetAudience {
  /// Firestore Map → TargetAudience
  ///
  /// **사용 예시**:
  /// ```dart
  /// final data = doc.data() as Map<String, dynamic>;
  /// final audience = TargetAudienceFirestore.fromMap(data['targetAudience']);
  /// ```
  static TargetAudience fromMap(Map<String, dynamic>? data) {
    if (data == null) return TargetAudience.empty();

    return TargetAudience(
      gender: _parseStringList(data['gender']),
      ageRange: _parseAgeRange(data['ageRange']),
      interests: _parseStringList(data['interests']),
      expertise: _parseStringList(data['expertise']),
      location: _parseStringList(data['location']),

      // Complex criteria Map (Phase 4에서 손실 방지)
      criteria: data['criteria'] as Map<String, dynamic>? ?? {},
    );
  }

  /// TargetAudience → Firestore Map
  ///
  /// **사용 예시**:
  /// ```dart
  /// final audience = TargetAudience(...);
  /// final map = audience.toMap();
  /// await firestore.collection('posts').doc(id).update({
  ///   'targetAudience': map,
  /// });
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'ageRange': ageRange.toMap(),
      'interests': interests,
      'expertise': expertise,
      'location': location,
      'criteria': criteria,
    };
  }

  // ========== Helper Functions ==========

  /// String List 파싱
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// AgeRange 파싱
  static AgeRange _parseAgeRange(dynamic data) {
    if (data == null) return AgeRange.all();

    final map = data as Map<String, dynamic>;
    return AgeRange(
      min: map['min'] as int? ?? 0,
      max: map['max'] as int? ?? 100,
    );
  }
}

/// AgeRange → Firestore Extension
extension AgeRangeFirestore on AgeRange {
  Map<String, dynamic> toMap() {
    return {
      'min': min,
      'max': max,
    };
  }
}
```

**Step 1 완료 기준**:
- ✅ 3개 Extension 파일 생성 완료
- ✅ 모든 Helper 함수 구현
- ✅ Extension 파일별 단위 테스트 작성 (Part 3에서 다룸)
- ✅ Git commit: `feat: Phase 5 Step 1 - Create 3 Extension files`

---

## Step 2: Repository 순차 전환

### 의존성 순서 (낮음 → 높음)

```
독립 Repository (병렬 전환 가능):
├── ImageProcessingRepositoryImpl
├── TargetAudienceRepositoryImpl
├── ContentModerationRepositoryImpl
├── ContentVisibilityRepositoryImpl
└── ContentMetricsRepositoryImpl

의존성 있는 Repository (순차 전환 필요):
├── MediaRepositoryImpl (MediaInfo Extension 사용)
├── MediaUploadRepositoryImpl (MediaRepository 사용)
└── PostCreationRepositoryV2Impl (위 모든 것 사용)
```

---

### 2.1. ImageProcessingRepositoryImpl 전환

**파일**: `lib/features/creation/data/repositories/image_processing_repository_impl.dart`

**Before (Phase 4)**:
```dart
class ImageProcessingRepositoryImpl implements IImageProcessingRepository {
  final IPostCreationDataSource _dataSource;  // ← 삭제 예정
  final IImageProcessingService _service;

  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  }) async {
    // 1. Service로 이미지 처리
    final processed = await _service.processImages(files, box, onProgress);

    // 2. DataSource로 저장 (불필요)
    await _dataSource.saveProcessedImages(processed);

    return processed;
  }
}
```

**After (Phase 5)**:
```dart
class ImageProcessingRepositoryImpl implements IImageProcessingRepository {
  final FirebaseFirestore _firestore;  // ← DataSource 대신 직접 주입
  final IImageProcessingService _service;

  ImageProcessingRepositoryImpl({
    required FirebaseFirestore firestore,
    required IImageProcessingService service,
  }) : _firestore = firestore,
       _service = service;

  @override
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  }) async {
    // 1. Service로 이미지 처리 (동일)
    final processed = await _service.processImages(files, box, onProgress);

    // 2. Firestore 직접 저장 (Extension 사용)
    for (final imageInfo in processed.images) {
      await _firestore.collection('media').doc(imageInfo.id).set(
        imageInfo.toFirestore(),  // ← Extension!
      );
    }

    return processed;
  }
}
```

**변경 사항**:
- ❌ `IPostCreationDataSource _dataSource` 삭제
- ✅ `FirebaseFirestore _firestore` 직접 주입
- ✅ `MediaInfoFirestore.toFirestore()` 사용

---

### 2.2. MediaRepositoryImpl 전환 (Sealed Class 활용)

**Before (Phase 4)**:
```dart
class MediaRepositoryImpl implements IMediaRepository {
  final IStorageDataSource _storageDataSource;  // ← 삭제 예정
  final FirebaseFirestore _firestore;

  // ❌ Manual DTO → Entity 변환
  ImageInfo _dtoToImageInfo(ImageResultDto dto) {
    return ImageInfo(
      id: dto.id,
      url: dto.url,
      width: null,  // ❌ DTO 필드 누락!
      height: null,
      // ... 15+ fields
    );
  }

  @override
  Stream<List<ImageInfo>> queryImages({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: 'image');

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          // Step 1: Firestore → DTO
          .map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
          // Step 2: DTO → Entity (Manual)
          .map((dto) => _dtoToImageInfo(dto))
          .toList();
    });
  }
}
```

**After (Phase 5)**:
```dart
class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;  // ← DataSource 대신 직접 주입

  MediaRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Stream<List<MediaInfo>> queryImages({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: 'image');

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          // Extension 1단계 변환!
          .map((doc) => MediaInfoFirestore.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          // Sealed Class filter (ImageInfo만)
          .whereType<ImageInfo>()
          .toList();
    });
  }

  @override
  Stream<List<MediaInfo>> queryAllMedia({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MediaInfoFirestore.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();  // ← ImageInfo | VideoInfo 모두 포함
    });
  }
}
```

**변경 사항**:
- ❌ `IStorageDataSource _storageDataSource` 삭제
- ❌ `_dtoToImageInfo()` Manual Mapper 삭제
- ✅ `FirebaseStorage _storage` 직접 주입
- ✅ `MediaInfoFirestore.fromFirestore()` 사용
- ✅ Sealed Class `whereType<ImageInfo>()` 필터링

---

### 2.3. PostCreationRepositoryV2Impl 전환 (최종)

**Before (Phase 4)** - 399줄:
```dart
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;              // ← 삭제
  final ITargetAudienceService? _targetAudienceService;  // ← 유지
  final IImageProcessingService _imageProcessingService;  // ← 유지
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();  // ← 삭제

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance)
           .collection('posts');

  // ❌ Before: 4단계 변환
  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      // Step 1: Entity → Map (Mapper)
      final data = _mapper.toCreateDocument(post);
      data['postCreatedDate'] = post.createdAt;

      // Step 2: Map → Firestore (DataSource)
      final result = await _dataSource.createPost(data);

      // Step 3: Extract ID
      final postId = result['id'] as String;

      return postId;
    } catch (e) {
      throw CreationException('Failed to create post: $e');
    }
  }

  // ❌ Before: 4단계 변환
  @override
  Future<PostCreation?> getPost(String postId) async {
    try {
      // Step 1: Firestore query (DataSource)
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;

      // Step 2: Map extraction
      final data = doc.data() as Map<String, dynamic>;

      // Step 3: Mapper → Entity
      final post = _mapper.extractPostCreation(data, postId);

      return post;
    } catch (e) {
      throw CreationException('Failed to get post: $e');
    }
  }

  // ... 15+ methods (총 399줄)
}
```

**After (Phase 5)** - 180줄:
```dart
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final FirebaseFirestore _firestore;                     // ← 직접 주입
  final ITargetAudienceService? _targetAudienceService;  // ← 유지
  final IImageProcessingService _imageProcessingService;  // ← 유지

  PostCreationRepositoryV2Impl({
    required FirebaseFirestore firestore,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
  }) : _firestore = firestore,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService;

  // ✅ After: 1단계 변환
  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      final docRef = _firestore.collection('posts').doc();

      // Extension 1단계 변환!
      await docRef.set(post.toFirestore());

      return docRef.id;
    } on FirebaseException catch (e) {
      throw CreationException('Failed to create post: ${e.message}');
    }
  }

  // ✅ After: 1단계 변환
  @override
  Future<PostCreation?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) return null;

      // Extension 1단계 변환!
      return PostCreationFirestore.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw CreationException('Failed to get post: ${e.message}');
    }
  }

  // ✅ After: Stream도 1단계 변환
  @override
  Stream<PostCreation> watchPost(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots().map(
      (doc) => PostCreationFirestore.fromFirestore(doc),
    );
  }

  // ✅ After: List도 1단계 변환
  @override
  Stream<List<PostCreation>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  }) {
    var query = _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PostCreationFirestore.fromFirestore(doc))
          .toList();
    });
  }

  // ... 10+ methods (총 180줄, 55% 감소)
}
```

**변경 사항**:
- ❌ `IPostCreationDataSource _dataSource` 삭제
- ❌ `CreationFirestoreMapper _mapper` 삭제
- ❌ `CollectionReference _postsCollection` 삭제 (직접 쿼리)
- ✅ `FirebaseFirestore _firestore` 직접 주입
- ✅ `PostCreationFirestore.fromFirestore()` / `toFirestore()` 사용
- ✅ 코드 55% 감소 (399줄 → 180줄)

**Step 2 완료 기준**:
- ✅ 8개 Repository 모두 전환 완료
- ✅ Extension 사용 확인
- ✅ Repository 테스트 통과
- ✅ Git commit: `feat: Phase 5 Step 2 - Convert 8 repositories to Extension pattern`

---

## Step 3: Storage DataSource 특수 처리

**문제**: Firebase Storage는 파일 업로드 로직이 있어 Extension으로 대체 불가

**해결**: Repository에서 FirebaseStorage 직접 사용

**Before (Phase 4)**:
```dart
class MediaUploadRepositoryImpl {
  final IStorageDataSource _storageDataSource;  // ← 삭제 예정

  Future<String> uploadImage(File file, String path) async {
    // DataSource로 업로드
    return await _storageDataSource.uploadImage(file, path);
  }
}
```

**After (Phase 5)**:
```dart
class MediaUploadRepositoryImpl {
  final FirebaseStorage _storage;  // ← 직접 주입

  Future<String> uploadImage(File file, String path) async {
    // Storage 직접 사용
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
```

**파일 업로드 메타데이터는 Extension 사용**:
```dart
Future<MediaInfo> uploadImageWithMetadata(File file, String postId) async {
  // 1. Storage 업로드
  final url = await uploadImage(file, 'posts/$postId/${file.path}');

  // 2. 메타데이터 생성 (Extension 사용)
  final imageInfo = ImageInfo(
    id: const Uuid().v4(),
    url: url,
    parentId: postId,
    uploadedAt: DateTime.now(),
    uploadedBy: currentUserId,
  );

  // 3. Firestore 저장 (Extension 사용!)
  await _firestore.collection('media').doc(imageInfo.id).set(
    imageInfo.toFirestore(),
  );

  return imageInfo;
}
```

---

## Step 4: Legacy 파일 삭제

**삭제 전 검증**:
```bash
# 1. Extension 사용 확인
grep -r "PostCreationFirestore.fromFirestore" lib/features/creation/data/repositories/
grep -r "MediaInfoFirestore.fromFirestore" lib/features/creation/data/repositories/
grep -r "TargetAudienceFirestore.fromMap" lib/features/creation/data/repositories/

# 2. DataSource/DTO/Mapper 참조 확인 (없어야 함)
grep -r "IPostCreationDataSource" lib/features/creation/
grep -r "PostCreationDto" lib/features/creation/
grep -r "CreationFirestoreMapper" lib/features/creation/

# 3. 테스트 통과 확인
flutter test lib/features/creation/
```

**삭제 실행**:
```bash
# DataSource 삭제 (4 files)
rm lib/features/creation/data/datasources/firebase_post_creation_datasource.dart
rm lib/features/creation/data/datasources/firebase_storage_datasource.dart
rm lib/features/creation/data/datasources/interfaces/i_post_creation_datasource.dart
rm lib/features/creation/data/datasources/interfaces/i_storage_datasource.dart

# DTO 삭제 (6 files)
rm lib/features/creation/data/models/post_creation_dto.dart
rm lib/features/creation/data/models/content_moderation_dto.dart
rm lib/features/creation/data/models/video_result_dto.dart
rm lib/features/creation/data/models/target_audience_dto.dart
rm lib/features/creation/data/models/image_upload_dto.dart
rm lib/features/creation/data/models/image_result_dto.dart

# Mapper 삭제 (3 files)
rm lib/features/creation/data/mappers/creation_firestore_mapper.dart
rm lib/features/creation/data/mappers/post_creation_mapper.dart
rm lib/features/creation/data/mappers/target_audience_mapper.dart

# 빈 디렉토리 삭제
rmdir lib/features/creation/data/datasources/interfaces/
rmdir lib/features/creation/data/datasources/
rmdir lib/features/creation/data/models/
rmdir lib/features/creation/data/mappers/
```

**검증**:
```bash
# Import 에러 확인
flutter analyze lib/features/creation/

# 빌드 확인
flutter build apk --debug

# 테스트 확인
flutter test lib/features/creation/
```

---

## Step 5: DI 모듈 업데이트

**파일**: `lib/features/creation/di/creation_di_module.dart`

**Before (Phase 4)**:
```dart
void registerCreationDependencies(GetIt getIt) {
  // DataSource 등록 (삭제 예정)
  getIt.registerFactory<IPostCreationDataSource>(
    () => FirebasePostCreationDataSource(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerFactory<IStorageDataSource>(
    () => FirebaseStorageDataSource(
      storage: getIt<FirebaseStorage>(),
    ),
  );

  // Mapper 등록 (삭제 예정)
  getIt.registerFactory<CreationFirestoreMapper>(
    () => CreationFirestoreMapper(),
  );

  getIt.registerFactory<TargetAudienceMapper>(
    () => TargetAudienceMapper(),
  );

  // Repository 등록 (수정 필요)
  getIt.registerFactory<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(
      dataSource: getIt<IPostCreationDataSource>(),  // ← 삭제
      targetAudienceService: getIt<ITargetAudienceService>(),
      imageProcessingService: getIt<IImageProcessingService>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // ... 8개 Repository 등록
}
```

**After (Phase 5)**:
```dart
void registerCreationDependencies(GetIt getIt) {
  // DataSource, Mapper 삭제 ✅
  // Extension은 static method라 DI 불필요 ✅

  // Repository 등록 (Firebase SDK 직접 주입)
  getIt.registerFactory<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(
      firestore: getIt<FirebaseFirestore>(),  // ← 직접 주입
      targetAudienceService: getIt<ITargetAudienceService>(),
      imageProcessingService: getIt<IImageProcessingService>(),
    ),
  );

  getIt.registerFactory<IMediaRepository>(
    () => MediaRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),  // ← Storage 직접 주입
    ),
  );

  // ... 나머지 6개 Repository (간결화)
}
```

**변경 사항**:
- ❌ DataSource 4개 등록 삭제
- ❌ Mapper 3개 등록 삭제
- ✅ Repository에 Firebase SDK 직접 주입
- ✅ DI 코드 30% 감소

---

## Step 6: 검증

```bash
# 1. 분석
flutter analyze

# 2. 테스트
flutter test lib/features/creation/

# 3. 빌드
flutter build apk --debug

# 4. Extension 사용 확인
grep -r "fromFirestore" lib/features/creation/data/repositories/ | wc -l
# 기대값: 20+ (8개 Repository × 2-3 methods)

# 5. Legacy 참조 확인 (없어야 함)
grep -r "DataSource\|Dto\|Mapper" lib/features/creation/data/repositories/
# 기대값: 0 results

# 6. 코드 라인 수 확인
find lib/features/creation/data -name "*.dart" | xargs wc -l
# 기대값: ~1,560 lines (Before 3,873 lines)
```

---

## 📊 Before/After 전체 코드

### 예시 1: PostCreation 생성 (createPost)

#### Before (Phase 4) - 40줄

```dart
/// Legacy: 4단계 변환 (Phase 4)
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();
  final CollectionReference<Map<String, dynamic>> _postsCollection;

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _postsCollection = (firestore ?? FirebaseFirestore.instance)
           .collection('posts');

  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      // Step 1: Entity → Map (Mapper 사용)
      final data = _mapper.toCreateDocument(post);

      // Step 2: 추가 필드 설정
      data['postCreatedDate'] = post.createdAt;
      data['status'] = 'draft';

      // Step 3: Map → Firestore (DataSource 사용)
      final result = await _dataSource.createPost(data);

      // Step 4: ID 추출
      final postId = result['id'] as String;

      return postId;
    } catch (e) {
      throw CreationException('Failed to create post: $e');
    }
  }
}

// CreationFirestoreMapper.toCreateDocument() - 294줄 중 일부
Map<String, dynamic> toCreateDocument(PostCreation post) {
  return {
    'userId': post.userId,
    'questionTitle': post.questionTitle,
    'description': post.description,
    'optionA': _optionToMap(post.optionA),  // Helper 함수
    'optionB': _optionToMap(post.optionB),
    'voteConfiguration': _voteConfigToMap(post.voteConfiguration),
    'targetAudience': _audienceToMap(post.targetAudience),
    'createdAt': Timestamp.fromDate(post.createdAt),
    // ... 30+ fields
  };
}

Map<String, dynamic> _optionToMap(PostOption option) {
  return {
    'text': option.text,
    'images': option.images,
    'videos': option.videos,
    'aspectRatios': option.aspectRatios,
  };
}
// ... 10+ helper methods (총 294줄)
```

#### After (Phase 5) - 15줄

```dart
/// Extension Pattern (Phase 5)
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final FirebaseFirestore _firestore;

  PostCreationRepositoryV2Impl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      final docRef = _firestore.collection('posts').doc();

      // Extension 1단계 변환!
      await docRef.set(post.toFirestore());

      return docRef.id;
    } on FirebaseException catch (e) {
      throw CreationException('Failed to create post: ${e.message}');
    }
  }
}

// PostCreationFirestore Extension (PHASE_5_1.md 참조)
// toFirestore() 메서드가 모든 변환 처리 (~180줄에 모든 로직 포함)
```

**코드 감소**: 40줄 → 15줄 (63% 감소)

---

### 예시 2: MediaInfo 조회 (Sealed Class)

#### Before (Phase 4) - 35줄

```dart
/// Legacy: DTO → Entity 수동 변환 (Phase 4)
class MediaRepositoryImpl implements IMediaRepository {
  final IStorageDataSource _storageDataSource;
  final FirebaseFirestore _firestore;

  // ❌ Manual Mapper: DTO → Entity
  ImageInfo _dtoToImageInfo(ImageResultDto dto) {
    return ImageInfo(
      id: dto.id,
      url: dto.url,
      parentId: dto.parentId,
      width: null,  // ❌ DTO에 필드 없음!
      height: null,
      aspectRatio: null,
      size: dto.size,
      uploadedAt: dto.uploadedAt,
      uploadedBy: dto.uploadedBy,
    );
  }

  @override
  Stream<List<ImageInfo>> queryImages({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: 'image')
        .orderBy('uploadedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          // Step 1: Firestore → DTO
          .map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
          // Step 2: DTO → Entity (Manual Mapper)
          .map((dto) => _dtoToImageInfo(dto))
          .toList();
    });
  }
}
```

#### After (Phase 5) - 20줄

```dart
/// Extension Pattern: Sealed Class 직접 변환 (Phase 5)
class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MediaRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  @override
  Stream<List<MediaInfo>> queryImages({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: 'image');

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          // Extension 1단계 변환!
          .map((doc) => MediaInfoFirestore.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          // Sealed Class 타입 필터링
          .whereType<ImageInfo>()
          .toList();
    });
  }
}
```

**코드 감소**: 35줄 → 20줄 (43% 감소)
**필드 누락 해결**: width, height, aspectRatio 모두 보존 ✅

---

### 예시 3: TargetAudience 저장

#### Before (Phase 4) - 30줄

```dart
/// Legacy: 3단계 변환 (Phase 4)
class TargetAudienceRepositoryImpl implements ITargetAudienceRepository {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService _service;
  final TargetAudienceMapper _mapper;

  @override
  Future<void> saveTargetAudience({
    required String postId,
    required TargetAudience audience,
  }) async {
    try {
      // Step 1: Entity → Map (Service)
      final map = _service.convertToStorageFormat(audience);

      // Step 2: Map → DTO
      final dto = TargetAudienceDto.fromMap(map);

      // Step 3: DTO → Firestore (DataSource)
      await _dataSource.updatePost(postId, {
        'targetAudience': dto.toFirestore(),
      });
    } catch (e) {
      throw CreationException('Failed to save target audience: $e');
    }
  }
}
```

#### After (Phase 5) - 15줄

```dart
/// Extension Pattern: 1단계 변환 (Phase 5)
class TargetAudienceRepositoryImpl implements ITargetAudienceRepository {
  final FirebaseFirestore _firestore;

  TargetAudienceRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<void> saveTargetAudience({
    required String postId,
    required TargetAudience audience,
  }) async {
    try {
      // Extension 1단계 변환!
      await _firestore.collection('posts').doc(postId).update({
        'targetAudience': audience.toMap(),
      });
    } on FirebaseException catch (e) {
      throw CreationException('Failed to save target audience: ${e.message}');
    }
  }
}
```

**코드 감소**: 30줄 → 15줄 (50% 감소)
**의존성 감소**: Service + Mapper + DataSource → Firestore만

---

### 예시 4: PostCreation 조회 (getPost)

#### Before (Phase 4) - 25줄

```dart
@override
Future<PostCreation?> getPost(String postId) async {
  try {
    // Step 1: Firestore query (DataSource)
    final doc = await _postsCollection.doc(postId).get();

    if (!doc.exists) return null;

    // Step 2: DocumentSnapshot → Map
    final data = doc.data() as Map<String, dynamic>;

    // Step 3: Map → Entity (Mapper 사용)
    final post = _mapper.extractPostCreation(data, postId);

    return post;
  } catch (e) {
    throw CreationException('Failed to get post: $e');
  }
}

// CreationFirestoreMapper.extractPostCreation() - 294줄 중 일부
PostCreation extractPostCreation(Map<String, dynamic> data, String id) {
  return PostCreation(
    id: id,
    userId: data['userId'] as String? ?? '',
    questionTitle: data['questionTitle'] as String? ?? '',
    optionA: _extractPostOption(data['optionA']),  // Helper 함수
    optionB: _extractPostOption(data['optionB']),
    // ... 30+ fields (총 80줄)
  );
}
```

#### After (Phase 5) - 12줄

```dart
@override
Future<PostCreation?> getPost(String postId) async {
  try {
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) return null;

    // Extension 1단계 변환!
    return PostCreationFirestore.fromFirestore(doc);
  } on FirebaseException catch (e) {
    throw CreationException('Failed to get post: ${e.message}');
  }
}
```

**코드 감소**: 25줄 → 12줄 (52% 감소)

---

### 예시 5: PostCreation Stream (watchPost)

#### Before (Phase 4) - 15줄

```dart
@override
Stream<PostCreation> watchPost(String postId) {
  return _postsCollection.doc(postId).snapshots().map((doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return _mapper.extractPostCreation(data, doc.id);
  });
}
```

#### After (Phase 5) - 5줄

```dart
@override
Stream<PostCreation> watchPost(String postId) {
  return _firestore.collection('posts').doc(postId).snapshots().map(
    (doc) => PostCreationFirestore.fromFirestore(doc),
  );
}
```

**코드 감소**: 15줄 → 5줄 (67% 감소)

---

## 전체 코드 감소 요약

| Repository | Before (Phase 4) | After (Phase 5) | 감소율 |
|------------|------------------|-----------------|--------|
| **PostCreationRepositoryV2Impl** | 399줄 | 180줄 | **55%** |
| **MediaRepositoryImpl** | 404줄 | 200줄 | **50%** |
| **MediaUploadRepositoryImpl** | 252줄 | 120줄 | **52%** |
| **ContentModerationRepositoryImpl** | 298줄 | 150줄 | **50%** |
| **ContentVisibilityRepositoryImpl** | 361줄 | 180줄 | **50%** |
| **ImageProcessingRepositoryImpl** | 219줄 | 110줄 | **50%** |
| **TargetAudienceRepositoryImpl** | 253줄 | 120줄 | **53%** |
| **ContentMetricsRepositoryImpl** | 287줄 | 140줄 | **51%** |
| **합계** | **2,473줄** | **1,200줄** | **51%** |

**Extension 파일 추가**:
- post_creation_extensions.dart: 180줄
- media_info_extensions.dart: 120줄
- target_audience_extensions.dart: 60줄
- **합계**: 360줄

**순 감소**: 2,473 - 1,200 - 360 = **913줄 (Repository만 계산 시)**

**전체 Data Layer 감소** (DataSource + DTO + Mapper 포함):
- Before: 3,873줄 (21 files)
- After: 1,560줄 (11 files)
- **순 감소: 2,313줄 (60%)**

---

## 다음 단계

**Part 3로 계속**: [PHASE_5_3.md](./PHASE_5_3.md)

Part 3에서는 다음 내용을 다룹니다:
- Section 6: 🧪 테스트 전략
  - Extension Tests (3개 파일)
  - Repository Tests (8개 파일)
  - Integration Tests (E2E)

- Section 7: 🔄 롤백 계획
  - 시나리오별 롤백 절차
  - 체크리스트

- Section 8: 📅 마이그레이션 일정
  - 10-12일 상세 일정
  - 4개 Checkpoint

---

**문서 메타데이터**:
- **작성자**: AI Assistant (Claude Code)
- **최종 수정**: 2025-11-03
- **이전 문서**: [PHASE_5_1.md](./PHASE_5_1.md)
- **다음 문서**: [PHASE_5_3.md](./PHASE_5_3.md)
