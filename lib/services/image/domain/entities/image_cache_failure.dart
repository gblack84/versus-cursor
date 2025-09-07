import 'package:equatable/equatable.dart';
import '../types/cache_types.dart';

class ImageCacheFailure extends Equatable {

  const ImageCacheFailure({
    required this.type,
    this.message = '',
  });

  factory ImageCacheFailure.unexpected(String message) => ImageCacheFailure(
        type: FailureType.unknown,
        message: message,
      );

  factory ImageCacheFailure.cacheNotFound() => ImageCacheFailure(
        type: FailureType.storage,
        message: 'Image not found in cache',
      );
  final FailureType type;
  final String message;

  @override
  List<Object?> get props => [type, message];
}
