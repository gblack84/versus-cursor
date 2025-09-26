import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Location
  final GeoPoint? location;

  /// Create PostCore from Firestore document
  factory PostCore.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostCore(
      id: doc.id,
      questionTitle: data['questionTitle'] ?? '',
      description: data['description'],
      content: data['content'],
      userId: data['userId'] ?? data['uid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      visibility: data['visibility'] ?? 'public',
      isAnonymous: data['isAnonymous'] ?? false,
      premiumRequired: data['premiumRequired'] ?? false,
      location: data['location'] as GeoPoint?,
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
      location: json['location'] != null
          ? GeoPoint(
              json['location']['latitude'], json['location']['longitude'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'questionTitle': questionTitle,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
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
        'location': {
          'latitude': location!.latitude,
          'longitude': location!.longitude,
        },
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
    GeoPoint? location,
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
