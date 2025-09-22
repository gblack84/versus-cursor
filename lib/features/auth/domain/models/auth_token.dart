/// Domain model for authentication tokens
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? expiresAt;
  final String tokenType;
  final Map<String, dynamic>? customClaims;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
    this.customClaims,
  });

  /// Check if the token is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if the token needs refresh (expires in less than 5 minutes)
  bool get needsRefresh {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!.subtract(const Duration(minutes: 5)));
  }

  /// Check if the token is valid
  bool get isValid => accessToken.isNotEmpty && !isExpired;

  /// Create a copy with updated values
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    String? tokenType,
    Map<String, dynamic>? customClaims,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      customClaims: customClaims ?? this.customClaims,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthToken &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.idToken == idToken &&
        other.expiresAt == expiresAt &&
        other.tokenType == tokenType &&
        other.customClaims == customClaims;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        idToken.hashCode ^
        expiresAt.hashCode ^
        tokenType.hashCode ^
        customClaims.hashCode;
  }
}