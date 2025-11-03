import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_display.dart';

/// PostDisplay Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - Helper 함수로 타입 안전성 확보
/// - Null-safe 기본값 제공
///
/// **마이그레이션 정보**:
/// - Phase 5에서 DTO (87줄) + Mapper (96줄) → Extension (~130줄)
/// - 183줄 → 130줄 (29% 감소)
extension PostDisplayFirestore on PostDisplay {
  /// Firestore DocumentSnapshot → PostDisplay Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('posts').doc(postId).get();
  /// final post = PostDisplayFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **지원하는 Firestore 필드 형식**:
  /// - `createdAt`: Timestamp, int (milliseconds), String (ISO 8601), DateTime
  /// - `optionA/B`: Map<String, dynamic> with text, images, aspectRatios
  /// - `userid` or `uid`: 사용자 ID (둘 다 지원)
  /// - `username` or `userName`: 사용자 이름 (둘 다 지원)
  static PostDisplay fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Extract option A data
    final optionA = _parseOptionData(data, 'optionA');
    final optionAText = optionA['text'] as String?;
    final optionAImages = _parseOptionImages(data, 'optionA');
    final optionAAspectRatios = _parseOptionAspectRatios(data, 'optionA');

    // Extract option B data
    final optionB = _parseOptionData(data, 'optionB');
    final optionBText = optionB['text'] as String?;
    final optionBImages = _parseOptionImages(data, 'optionB');
    final optionBAspectRatios = _parseOptionAspectRatios(data, 'optionB');

    // Parse createdAt - support multiple formats
    final parsedDate = _parseDateTime(data['createdAt']) ??
                       _parseDateTime(data['postCreatedDate']);
    final createdAt = parsedDate ?? DateTime.now();

    // Parse voteStartTime and voteEndTime
    final voteStartTime = _parseDateTime(data['voteStartTime']);
    final voteEndTime = _parseDateTime(data['voteEndTime']);

    return PostDisplay(
      // Identification
      id: doc.id,
      userId: data['userid'] as String? ?? data['uid'] as String? ?? '',
      displayName: data['username'] as String? ?? data['userName'] as String? ?? '',
      photoUrl: data['userPhotoUrl'] as String? ?? '',

      // Content
      questionTitle: data['questionTitle'] as String? ?? '',
      description: data['description'] as String?,
      optionAText: optionAText,
      optionBText: optionBText,

      // Legacy single image URLs (for backward compatibility)
      optionAImageUrl: data['optionAImageUrl'] as String?,
      optionBImageUrl: data['optionBImageUrl'] as String?,

      // Multiple images support
      optionAImages: optionAImages.isEmpty ? null : optionAImages,
      optionAAspectRatios: optionAAspectRatios.isEmpty ? null : optionAAspectRatios,
      optionBImages: optionBImages.isEmpty ? null : optionBImages,
      optionBAspectRatios: optionBAspectRatios.isEmpty ? null : optionBAspectRatios,

      // Layout
      layoutType: data['layoutType'] as String? ?? 'vertical',

      // Voting
      votesA: _parseInt(data['votesA']),
      votesB: _parseInt(data['votesB']),
      voteStatus: data['voteStatus'] as String? ?? 'pending',
      voteCompleted: _parseBool(data['voteCompleted']),
      voteStartTime: voteStartTime?.millisecondsSinceEpoch,
      voteEndTime: voteEndTime?.millisecondsSinceEpoch,

      // Metrics
      commentCount: _parseInt(data['commentcount']),
      likeCount: _parseInt(data['likecount']),
      shareCount: _parseInt(data['sharecount']),

      // Metadata
      createdAt: createdAt.millisecondsSinceEpoch,
      isAnonymous: _parseBool(data['isAnonymous']),
      status: data['status'] as String? ?? 'published',
      targetAudience: _parseMap(data['targetAudience']),
    );
  }

  /// PostDisplay Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final post = PostDisplay(...);
  /// await firestore.collection('posts').doc(post.id).set(post.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // Identification
      'userid': userId,
      'username': displayName,
      'userPhotoUrl': photoUrl,

      // Content
      'questionTitle': questionTitle,
      if (description != null) 'description': description,

      // Legacy single image URLs (backward compatibility)
      if (optionAImageUrl != null) 'optionAImageUrl': optionAImageUrl,
      if (optionBImageUrl != null) 'optionBImageUrl': optionBImageUrl,

      // Option A
      'optionA': {
        if (optionAText != null) 'text': optionAText,
        if (optionAImages != null && optionAImages!.isNotEmpty)
          'images': optionAImages,
        if (optionAAspectRatios != null && optionAAspectRatios!.isNotEmpty)
          'aspectRatios': optionAAspectRatios,
      },

      // Option B
      'optionB': {
        if (optionBText != null) 'text': optionBText,
        if (optionBImages != null && optionBImages!.isNotEmpty)
          'images': optionBImages,
        if (optionBAspectRatios != null && optionBAspectRatios!.isNotEmpty)
          'aspectRatios': optionBAspectRatios,
      },

      // Layout
      'layoutType': layoutType,

      // Voting
      'votesA': votesA,
      'votesB': votesB,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      if (voteStartTime != null)
        'voteStartTime': Timestamp.fromMillisecondsSinceEpoch(voteStartTime!),
      if (voteEndTime != null)
        'voteEndTime': Timestamp.fromMillisecondsSinceEpoch(voteEndTime!),

      // Metrics
      'commentcount': commentCount,
      'likecount': likeCount,
      'sharecount': shareCount,

      // Metadata
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAt),
      'isAnonymous': isAnonymous,
      'status': status,
      if (targetAudience != null) 'targetAudience': targetAudience,
    };
  }

  // ========== Helper Functions ==========

  /// DateTime 안전 파싱 (Timestamp/int/String/DateTime 지원)
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

  /// Generic Map 안전 파싱
  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Option 데이터 추출 (optionA 또는 optionB)
  ///
  /// **반환 형식**:
  /// ```dart
  /// {
  ///   'text': 'Option A',
  ///   'images': ['url1', 'url2'],
  ///   'aspectRatios': [1.5, 1.2],
  /// }
  /// ```
  static Map<String, dynamic> _parseOptionData(
    Map<String, dynamic> data,
    String optionKey,
  ) {
    return data[optionKey] as Map<String, dynamic>? ?? {};
  }

  /// Option에서 image URLs 추출
  ///
  /// **예시**:
  /// ```dart
  /// final images = _parseOptionImages(data, 'optionA');
  /// // ['url1', 'url2', 'url3']
  /// ```
  static List<String> _parseOptionImages(
    Map<String, dynamic> data,
    String optionKey,
  ) {
    final option = _parseOptionData(data, optionKey);
    return _parseStringList(option['images']);
  }

  /// Option에서 aspect ratios 추출
  ///
  /// **예시**:
  /// ```dart
  /// final ratios = _parseOptionAspectRatios(data, 'optionA');
  /// // [1.5, 1.2, 0.8]
  /// ```
  static List<double> _parseOptionAspectRatios(
    Map<String, dynamic> data,
    String optionKey,
  ) {
    final option = _parseOptionData(data, optionKey);
    return _parseDoubleList(option['aspectRatios']);
  }

  /// Int 파싱 (기본값 0)
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Bool 파싱 (기본값 false)
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }
}
