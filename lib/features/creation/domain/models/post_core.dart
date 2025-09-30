// Removed Firebase dependency - Clean Architecture

/// PostCore Domain Model
/// Clean Architecture - Domain Layer Entity
///
/// Core post entity containing essential fields only.
/// Separated from voting, media, and analytics concerns
/// for better separation of concerns and maintainability.
class PostCore {
  const PostCore({
    required this.id,
    required this.questionTitle,
    this.description,
    this.content,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.tags = const [],
    this.visibility = 'public',
    this.isAnonymous = false,
    this.premiumRequired = false,
    this.location,
  });

  // Core Identity
  final String id;
  final String questionTitle;
  final String? description;
  final String? content;

  // Ownership
  final String userId; // Foreign key to AuthUser.uid

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Classification
  final String? category;
  final List<String> tags;

  // Access Control
  final String visibility; // public, private, friends
  final bool isAnonymous;
  final bool premiumRequired;

  // Location - Using domain representation instead of Firebase GeoPoint
  final Map<String, double>? location; // {latitude: double, longitude: double}

  /// Create PostCore from data map (DataSource will handle Firebase conversion)
  factory PostCore.fromMap(Map<String, dynamic> data, {String? id}) {
    return PostCore(
      id: id ?? data['id'] ?? '',
      questionTitle: data['questionTitle'] ?? '',
      description: data['description'],
      content: data['content'],
      userId: data['userId'] ?? data['uid'] ?? '',
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : DateTime.now(),
      updatedAt: data['updatedAt'] as DateTime?,
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      visibility: data['visibility'] ?? 'public',
      isAnonymous: data['isAnonymous'] ?? false,
      premiumRequired: data['premiumRequired'] ?? false,
      location: data['location'] != null && data['location'] is Map
          ? {
              'latitude': data['location']['latitude'] as double,
              'longitude': data['location']['longitude'] as double,
            }
          : null,
    );
  }

  /// Create PostCore from JSON (for caching)
  factory PostCore.fromJson(Map<String, dynamic> json) {
    return PostCore(
      id: json['id'] ?? '',
      questionTitle: json['questionTitle'] ?? '',
      description: json['description'],
      content: json['content'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      visibility: json['visibility'] ?? 'public',
      isAnonymous: json['isAnonymous'] ?? false,
      premiumRequired: json['premiumRequired'] ?? false,
      location: json['location'] != null && json['location'] is Map
          ? {
              'latitude': json['location']['latitude'] as double,
              'longitude': json['location']['longitude'] as double,
            }
          : null,
    );
  }

  /// Convert to Map (DataSource will handle Firebase-specific conversion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionTitle': questionTitle,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      'userId': userId,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (category != null) 'category': category,
      'tags': tags,
      'visibility': visibility,
      'isAnonymous': isAnonymous,
      'premiumRequired': premiumRequired,
      if (location != null) 'location': location,
    };
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionTitle': questionTitle,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (category != null) 'category': category,
      'tags': tags,
      'visibility': visibility,
      'isAnonymous': isAnonymous,
      'premiumRequired': premiumRequired,
      if (location != null)
        'location': location,
    };
  }

  /// Create a copy with updated fields
  PostCore copyWith({
    String? id,
    String? questionTitle,
    String? description,
    String? content,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    List<String>? tags,
    String? visibility,
    bool? isAnonymous,
    bool? premiumRequired,
    Map<String, double>? location,
  }) {
    return PostCore(
      id: id ?? this.id,
      questionTitle: questionTitle ?? this.questionTitle,
      description: description ?? this.description,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      premiumRequired: premiumRequired ?? this.premiumRequired,
      location: location ?? this.location,
    );
  }

  /// Check if post is editable by user
  bool isEditableBy(String currentUserId) {
    return userId == currentUserId && !isAnonymous;
  }

  /// Check if post is viewable based on visibility
  bool isViewableBy(String? currentUserId, bool isPremium) {
    if (premiumRequired && !isPremium) return false;
    if (visibility == 'public') return true;
    if (visibility == 'private') return userId == currentUserId;
    // Add friend check logic here if needed
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostCore && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostCore(id: $id, title: $questionTitle, user: $userId, anonymous: $isAnonymous)';
  }
}
