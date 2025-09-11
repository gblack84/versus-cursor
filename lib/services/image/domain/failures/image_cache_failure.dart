/// Image cache failure types
abstract class ImageCacheFailure {
  const ImageCacheFailure(this.message);
  final String message;
}

class NetworkFailure extends ImageCacheFailure {
  const NetworkFailure(String message) : super(message);
}

class CacheFailure extends ImageCacheFailure {
  const CacheFailure(String message) : super(message);
}

class StorageFailure extends ImageCacheFailure {
  const StorageFailure(String message) : super(message);
}
