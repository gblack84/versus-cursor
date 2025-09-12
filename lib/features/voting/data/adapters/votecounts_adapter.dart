import '../../domain/models/vote_counts_model.dart';

/// Adapter for converting between Firestore data and VoteCounts domain model
/// 
/// This adapter handles conversion between Firestore Map data and 
/// the clean VoteCounts domain model following Clean Architecture principles
class VoteCountsAdapter {
  
  
  /// Converts Clean Architecture VoteCounts to Firestore-compatible Map
  /// 
  /// Maps votesA -> option1 and votesB -> option2 for legacy compatibility
  /// Note: totalVotes is not stored as it's calculated from option1 + option2
  static Map<String, dynamic> toFirestore(VoteCounts domain) {
    return {
      'option1': domain.votesA,
      'option2': domain.votesB,
    };
  }
  
  /// Convenience method to convert from Firestore Map directly to VoteCounts
  /// 
  /// Provides type safety for direct Firestore data conversion
  static VoteCounts fromMap(Map<String, dynamic> data) {
    final option1 = _safeInt(data['option1']);
    final option2 = _safeInt(data['option2']);
    
    return VoteCounts(
      votesA: option1,
      votesB: option2,
      totalVotes: option1 + option2,
    );
  }
  
  
  /// Batch conversion from list of VoteCounts to list of Firestore Maps
  static List<Map<String, dynamic>> toFirestoreList(List<VoteCounts> domains) {
    return domains.map(toFirestore).toList();
  }
  
  // ============= HELPER METHODS =============
  
  /// Safely converts dynamic value to int with null safety
  /// 
  /// Handles various input types and provides fallback to 0
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  // ============= VALIDATION METHODS =============
  
  
  /// Creates a VoteCounts with zero values
  /// 
  /// Useful for initializing empty vote counts
  static VoteCounts createEmpty() {
    return const VoteCounts(
      votesA: 0,
      votesB: 0,
      totalVotes: 0,
    );
  }
  
  /// Creates a VotecountsModel Map with zero values
  /// 
  /// Useful for initializing empty Firestore documents
  static Map<String, dynamic> createEmptyFirestore() {
    return {
      'option1': 0,
      'option2': 0,
    };
  }

  // ============= CACHE SUPPORT METHODS =============
  
  /// Converts VoteCounts to JSON for cache storage
  static Map<String, dynamic> toJson(VoteCounts domain) {
    return {
      'votesA': domain.votesA,
      'votesB': domain.votesB,
      'totalVotes': domain.totalVotes,
    };
  }

  /// Creates VoteCounts from cached JSON
  static VoteCounts fromJson(Map<String, dynamic> json) {
    return VoteCounts(
      votesA: _safeInt(json['votesA']),
      votesB: _safeInt(json['votesB']),
      totalVotes: _safeInt(json['totalVotes']),
    );
  }

  /// Batch conversion from list of Maps to list of VoteCounts
  static List<VoteCounts> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map(fromMap).toList();
  }

  // ============= FIRESTORE CONVERSION METHODS =============
  
  /// Convert from dynamic Firestore data
  static VoteCounts fromFirestore(dynamic data) {
    if (data is Map<String, dynamic>) {
      return fromMap(data);
    }
    // If it's already VoteCounts, return as is
    if (data is VoteCounts) {
      return data;
    }
    // Fallback to empty
    return createEmpty();
  }

  /// Batch conversion from dynamic list
  static List<VoteCounts> fromFirestoreList(dynamic dataList) {
    if (dataList is List<Map<String, dynamic>>) {
      return fromMapList(dataList);
    }
    if (dataList is List) {
      return dataList.map((item) => fromFirestore(item)).toList();
    }
    return [];
  }

  /// Updates cached vote counts by applying increment/decrement
  static VoteCounts updateCachedVoteCounts({
    required VoteCounts current,
    required String voteOption,
    required bool increment,
  }) {
    final delta = increment ? 1 : -1;
    
    if (voteOption == 'A') {
      return VoteCounts(
        votesA: current.votesA + delta,
        votesB: current.votesB,
        totalVotes: current.totalVotes + delta,
      );
    } else if (voteOption == 'B') {
      return VoteCounts(
        votesA: current.votesA,
        votesB: current.votesB + delta,
        totalVotes: current.totalVotes + delta,
      );
    }
    
    return current;
  }
}