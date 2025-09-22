// Authentication Token Mapper
// Clean Architecture - Data Layer

import '../../domain/models/auth_token.dart';
import '../dto/auth_token_dto.dart';

/// AuthTokenMapper
///
/// Maps between AuthTokenDto (data layer) and AuthToken (domain layer).
/// Handles conversion between external data format and domain model.
class AuthTokenMapper {
  /// Convert DTO to Domain Model
  static AuthToken toDomain(AuthTokenDto dto) {
    return AuthToken(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      idToken: dto.idToken,
      expiresAt: dto.expiresAt,
      tokenType: dto.tokenType,
      customClaims: dto.customClaims,
    );
  }

  /// Convert Domain Model to DTO
  static AuthTokenDto toDto(AuthToken model) {
    return AuthTokenDto(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      idToken: model.idToken,
      expiresAt: model.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      tokenType: model.tokenType,
      customClaims: model.customClaims,
    );
  }

  /// Convert nullable DTO to nullable Domain Model
  static AuthToken? toDomainNullable(AuthTokenDto? dto) {
    if (dto == null) return null;
    return toDomain(dto);
  }

  /// Convert nullable Domain Model to nullable DTO
  static AuthTokenDto? toDtoNullable(AuthToken? model) {
    if (model == null) return null;
    return toDto(model);
  }

  /// Convert list of DTOs to list of Domain Models
  static List<AuthToken> toDomainList(List<AuthTokenDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }

  /// Convert list of Domain Models to list of DTOs
  static List<AuthTokenDto> toDtoList(List<AuthToken> models) {
    return models.map((model) => toDto(model)).toList();
  }
}