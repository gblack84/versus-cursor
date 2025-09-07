enum CacheEvictionStrategy {
  lru, // Least Recently Used
  lfu, // Least Frequently Used
  fifo, // First In First Out
  random
}

enum CachePriority {
  high,
  normal,
  low
}

enum CacheEventType {
  added,
  retrieved,
  evicted,
  expired
}

enum FailureType {
  storage,
  network,
  permissions,
  unknown
}
