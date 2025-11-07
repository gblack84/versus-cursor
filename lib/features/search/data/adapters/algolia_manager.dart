import 'dart:async';

import 'package:algolia/algolia.dart';

// Migrated from backend.dart - only need LatLng
import '/app/models/lat_lng.dart';
import '/core_exports.dart';

export 'package:algolia/algolia.dart';

const kAlgoliaApplicationId = '0GAS0MPT9Z';
const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';

/// Algolia Query Parameters
///
/// Encapsulates Algolia search parameters for caching
///
/// **Migration Status**: Equatable removed (2025-11-07)
/// - ✅ Equatable 제거
/// - ✅ Manual equality implementation
class AlgoliaQueryParams {
  const AlgoliaQueryParams(this.index, this.term, this.latLng, this.maxResults,
      this.searchRadiusMeters);
  final String index;
  final String? term;
  final LatLng? latLng;
  final int? maxResults;
  final double? searchRadiusMeters;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlgoliaQueryParams &&
        other.index == index &&
        other.term == term &&
        other.latLng == latLng &&
        other.maxResults == maxResults &&
        other.searchRadiusMeters == searchRadiusMeters;
  }

  @override
  int get hashCode =>
      Object.hash(index, term, latLng, maxResults, searchRadiusMeters);
}

class AppAlgoliaManager {
  AppAlgoliaManager._()
      : algolia = Algolia.init(
          applicationId: kAlgoliaApplicationId,
          apiKey: kAlgoliaApiKey,
          extraUserAgents: ['VersusSpace_1.0.0'],
        );
  final Algolia algolia;

  static AppAlgoliaManager? _instance;
  static AppAlgoliaManager get instance => _instance ??= AppAlgoliaManager._();

  // Cache that will ensure identical queries are not repeatedly made.
  static Map<AlgoliaQueryParams, List<AlgoliaObjectSnapshot>> _algoliaCache =
      {};

  Future<List<AlgoliaObjectSnapshot>> algoliaQuery({
    required String index,
    String? term,
    int? maxResults,
    FutureOr<LatLng>? location,
    double? searchRadiusMeters,
    bool useCache = false,
  }) async {
    // User must specify search term or location.
    if ((term ?? '').isEmpty && location == null) {
      return [];
    }
    LatLng? loc;
    if (location != null) {
      loc = await location;
    }
    final params =
        AlgoliaQueryParams(index, term, loc, maxResults, searchRadiusMeters);

    if (useCache && _algoliaCache.containsKey(params)) {
      return _algoliaCache[params]!;
    }

    AlgoliaQuery query = algolia.index(index);
    if (term != null) {
      query = query.query(term);
    }
    if (maxResults != null) {
      query = query.setHitsPerPage(maxResults);
    }
    if (loc != null) {
      query = query.setAroundLatLng('${loc.latitude},${loc.longitude}');
      query = query.setAroundRadius(searchRadiusMeters?.round() ?? 'all');
    }

    AlgoliaQuerySnapshot? snapshot;
    try {
      snapshot = await query.getObjects();
    } catch (error, stackTrace) {
      print('Algolia error: $error\nStack trace: $stackTrace');
      snapshot = null;
    }
    return _algoliaCache[params] = snapshot?.hits ?? [];
  }
}
