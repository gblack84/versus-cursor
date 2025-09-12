/// Cache key constants and generators for voting feature
class CacheKeys {
  // Prefixes for different cache types
  static const String voteStatePrefix = 'vote_state_';
  static const String voteCountsPrefix = 'vote_counts_';
  static const String rankingsPrefix = 'rankings_';
  static const String voteHistoryPrefix = 'vote_history_';
  static const String pendingVotesKey = 'pending_votes';
  static const String cacheTimePrefix = 'cache_time_';
  
  // Key generators
  static String voteStateKey(String userId, String postId) => 
      '$voteStatePrefix${userId}_$postId';
  
  static String voteCountsKey(String postId) => 
      '$voteCountsPrefix$postId';
  
  static String rankingsKey(String cacheKey) => 
      '$rankingsPrefix$cacheKey';
  
  static String voteHistoryKey(String userId) => 
      '$voteHistoryPrefix$userId';
  
  static String cacheTimeKey(String prefix, String id) => 
      '$cacheTimePrefix$prefix$id';
  
  // Check if a key belongs to voting cache
  static bool isVotingCacheKey(String key) {
    return key.startsWith(voteStatePrefix) ||
           key.startsWith(voteCountsPrefix) ||
           key.startsWith(rankingsPrefix) ||
           key.startsWith(voteHistoryPrefix) ||
           key.startsWith(cacheTimePrefix) ||
           key == pendingVotesKey;
  }
}