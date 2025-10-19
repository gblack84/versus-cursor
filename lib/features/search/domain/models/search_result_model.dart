import 'package:equatable/equatable.dart';

/// Search Result Model
///
/// Unified search result for all types (posts, users, chats)
///
/// **Current Status**: Basic structure (2025-01-20)
/// - Core fields defined
/// - Serialization pending
class SearchResult extends Equatable {
  final String id;
  final String type; // 'post', 'user', 'chat'
  final String title;
  final String? description;
  final String? imageUrl;
  final double relevanceScore;
  final Map<String, dynamic>? metadata; // Type-specific data

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    this.relevanceScore = 0.0,
    this.metadata,
  });

  // TODO: Add JSON serialization
  // Map<String, dynamic> toJson() {}
  // factory SearchResult.fromJson(Map<String, dynamic> json) {}

  SearchResult copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? imageUrl,
    double? relevanceScore,
    Map<String, dynamic>? metadata,
  }) {
    return SearchResult(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, title, description, imageUrl, relevanceScore, metadata];
}
