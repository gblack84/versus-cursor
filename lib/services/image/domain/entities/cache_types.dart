/// Cache eviction strategies
enum CacheEvictionStrategy {
  lru, // Least Recently Used
  fifo, // First In First Out
  lfu, // Least Frequently Used
}

/// Cache priority levels
enum CachePriority {
  low,
  normal,
  high,
  critical,
}

/// Image format types
enum ImageFormat {
  jpeg,
  png,
  webp,
  gif,
  bmp,
}
