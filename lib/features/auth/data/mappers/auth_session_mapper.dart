// Authentication Session Mapper
// Clean Architecture - Data Layer

import '../../domain/models/auth_session.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/models/auth_token.dart';
import '../dto/auth_session_dto.dart';
import 'auth_token_mapper.dart';
import 'auth_user_mapper.dart';

/// AuthSessionMapper
///
/// Maps between AuthSessionDto (data layer) and AuthSession (domain layer).
/// Handles conversion of complete session data including user and token.
class AuthSessionMapper {
  /// Convert DTO to Domain Model
  static AuthSession toDomain(AuthSessionDto dto) {
    return AuthSession(
      sessionId: dto.sessionId,
      user: AuthUserMapper.fromDto(dto.user, profile: null),
      token: dto.token != null
        ? AuthTokenMapper.toDomain(dto.token!)
        : null,
      createdAt: dto.createdAt,
      lastActivityAt: dto.lastActivityAt,
      deviceId: dto.deviceId,
      deviceName: dto.deviceName,
      ipAddress: dto.ipAddress,
      userAgent: dto.userAgent,
      metadata: dto.metadata,
      isActive: dto.isActive,
    );
  }

  /// Convert Domain Model to DTO
  static AuthSessionDto toDto(AuthSession model) {
    return AuthSessionDto(
      sessionId: model.sessionId,
      user: AuthUserMapper.toAuthDto(model.user),
      token: model.token != null
        ? AuthTokenMapper.toDto(model.token!)
        : null,
      createdAt: model.createdAt,
      lastActivityAt: model.lastActivityAt,
      deviceId: model.deviceId,
      deviceName: model.deviceName,
      ipAddress: model.ipAddress,
      userAgent: model.userAgent,
      metadata: model.metadata,
      isActive: model.isActive,
    );
  }

  /// Convert nullable DTO to nullable Domain Model
  static AuthSession? toDomainNullable(AuthSessionDto? dto) {
    if (dto == null) return null;
    return toDomain(dto);
  }

  /// Convert nullable Domain Model to nullable DTO
  static AuthSessionDto? toDtoNullable(AuthSession? model) {
    if (model == null) return null;
    return toDto(model);
  }

  /// Create session from user and token
  static AuthSession createSession({
    required AuthUser user,
    AuthToken? token,
    String? deviceId,
    String? deviceName,
  }) {
    final now = DateTime.now();
    return AuthSession(
      sessionId: 'session_${user.uid}_${now.millisecondsSinceEpoch}',
      user: user,
      token: token,
      createdAt: now,
      lastActivityAt: now,
      deviceId: deviceId,
      deviceName: deviceName,
      isActive: true,
      metadata: {
        'authProvider': user.providerId,
        'createdWith': 'clean_architecture',
      },
    );
  }

  /// Convert list of DTOs to list of Domain Models
  static List<AuthSession> toDomainList(List<AuthSessionDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  /// Convert list of Domain Models to list of DTOs
  static List<AuthSessionDto> toDtoList(List<AuthSession> models) {
    return models.map((model) => toDto(model)).toList();
  }
}