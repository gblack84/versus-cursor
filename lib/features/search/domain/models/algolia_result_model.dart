import 'package:equatable/equatable.dart';

/// Algolia Search Result Model
///
/// Wrapper for Algolia API response
///
/// **Current Status**: Basic structure (2025-01-20)
/// - Core fields defined
/// - Serialization pending
class AlgoliaResult extends Equatable {
  final List<dynamic> hits;
  final int totalHits;
  final int page;
  final int nbPages;
  final int hitsPerPage;

  const AlgoliaResult({
    required this.hits,
    required this.totalHits,
    required this.page,
    required this.nbPages,
    this.hitsPerPage = 20,
  });

  // TODO: Add JSON serialization from Algolia response
  // factory AlgoliaResult.fromJson(Map<String, dynamic> json) {
  //   return AlgoliaResult(
  //     hits: json['hits'] as List<dynamic>,
  //     totalHits: json['nbHits'] as int,
  //     page: json['page'] as int,
  //     nbPages: json['nbPages'] as int,
  //     hitsPerPage: json['hitsPerPage'] as int,
  //   );
  // }

  bool get hasMore => page < nbPages - 1;
  bool get isEmpty => hits.isEmpty;

  @override
  List<Object?> get props => [hits, totalHits, page, nbPages, hitsPerPage];
}
