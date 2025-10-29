import 'package:json_annotation/json_annotation.dart';
import '../enums/user_role.dart';

/// UserRole <-> String JSON Converter for Freezed
///
/// **Purpose**:
/// - Freezed-compatible JSON serialization for UserRole enum
/// - Replaces @JsonKey pattern with @JsonConverter
/// - Reusable converter class
///
/// **Usage**:
/// ```dart
/// @freezed
/// class AuthUser with _$AuthUser {
///   const factory AuthUser({
///     @UserRoleConverter()  // ← Use this
///     @Default(UserRole.user)
///     UserRole role,
///   }) = _AuthUser;
/// }
/// ```
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  /// Convert JSON string to UserRole enum
  @override
  UserRole fromJson(String json) {
    return UserRole.fromValue(json);
  }

  /// Convert UserRole enum to JSON string
  @override
  String toJson(UserRole role) {
    return role.toValue();
  }
}
