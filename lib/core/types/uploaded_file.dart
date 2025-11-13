import 'dart:convert';
import 'dart:typed_data' show Uint8List;

/// Uploaded File Model
///
/// **Clean Architecture v4.0 - Manual Class**:
/// - Uint8List 호환성을 위해 Manual 클래스 유지
/// - copyWith, ==, hashCode 수동 구현
/// - serialize/deserialize는 Extension + Top-level 함수로 분리
///
/// **Migration (2025-11-10)**:
/// - Phase 9: Freezed 시도 → Manual 클래스로 복귀
/// - Extension static 메서드 → Top-level 함수 전환
class AppUploadedFile {
  const AppUploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  @override
  String toString() =>
      'AppUploadedFile(name: $name, bytes: ${bytes?.length ?? 0}, height: $height, width: $width, blurHash: $blurHash,)';

  @override
  int get hashCode => Object.hash(
        name,
        bytes,
        height,
        width,
        blurHash,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUploadedFile &&
        other.name == name &&
        other.bytes == bytes &&
        other.height == height &&
        other.width == width &&
        other.blurHash == blurHash;
  }
}

/// Extension for backward compatibility with router/serialization_util.dart
extension AppUploadedFileSerializationX on AppUploadedFile {
  /// Legacy serialize method (backward compatibility)
  /// Used by: lib/app/router/navigation/serialization_util.dart
  String serialize() => jsonEncode(
        {
          'name': name,
          'bytes': bytes,
          'height': height,
          'width': width,
          'blurHash': blurHash,
        },
      );
}

/// Top-level deserialize function (backward compatibility)
/// Used by: lib/app/router/navigation/serialization_util.dart
///
/// Note: Extension static methods cannot be called via type name,
/// so this is implemented as a top-level function instead.
AppUploadedFile deserializeAppUploadedFile(String val) {
  final serializedData = jsonDecode(val) as Map<String, dynamic>;
  final data = {
    'name': serializedData['name'] ?? '',
    'bytes': serializedData['bytes'] ?? Uint8List.fromList([]),
    'height': serializedData['height'],
    'width': serializedData['width'],
    'blurHash': serializedData['blurHash'],
  };
  return AppUploadedFile(
    name: data['name'] as String,
    bytes: Uint8List.fromList(data['bytes'].cast<int>().toList()),
    height: data['height'] as double?,
    width: data['width'] as double?,
    blurHash: data['blurHash'] as String?,
  );
}
