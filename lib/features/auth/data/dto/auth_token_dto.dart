// Authentication Token DTO
// Clean Architecture - Data Layer

/// AuthTokenDto
///
/// Data Transfer Object for authentication tokens.
/// Used for serializing/deserializing token data from Firebase Auth.
class AuthTokenDto {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime expiresAt;
  final String tokenType;
  final Map<String, dynamic>? customClaims;

  AuthTokenDto({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
    this.customClaims,
  });

  /// Create from Firebase Auth ID Token result
  factory AuthTokenDto.fromIdTokenResult(Map<String, dynamic> tokenResult) {
    return AuthTokenDto(
      accessToken: tokenResult['token'] ?? '',
      idToken: tokenResult['token'],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        tokenResult['expirationTime'] ?? 0,
      ),
      customClaims: tokenResult['claims'] as Map<String, dynamic>?,
    );
  }

  /// Create from Firebase Auth credential
  factory AuthTokenDto.fromCredential(Map<String, dynamic> credential) {
    return AuthTokenDto(
      accessToken: credential['accessToken'] ?? '',
      idToken: credential['idToken'],
      refreshToken: credential['refreshToken'],
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      customClaims: credential['additionalUserInfo'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'idToken': idToken,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'tokenType': tokenType,
      'customClaims': customClaims,
    };
  }

  /// Create from JSON (local storage)
  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      idToken: json['idToken'],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        json['expiresAt'] ?? 0,
      ),
      tokenType: json['tokenType'] ?? 'Bearer',
      customClaims: json['customClaims'] as Map<String, dynamic>?,
    );
  }

  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if token needs refresh (expires in less than 5 minutes)
  bool get needsRefresh {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Get remaining time until expiration
  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Copy with new values
  AuthTokenDto copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    String? tokenType,
    Map<String, dynamic>? customClaims,
  }) {
    return AuthTokenDto(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      customClaims: customClaims ?? this.customClaims,
    );
  }

  @override
  String toString() {
    return 'AuthTokenDto(tokenType: $tokenType, expiresAt: $expiresAt, hasRefreshToken: ${refreshToken != null})';
  }
}