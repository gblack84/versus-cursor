// Authentication Session Model
// Clean Architecture - Domain Layer

import 'auth_token.dart';
import 'auth_user.dart';

/// AuthSession
///
/// Domain model representing a complete authentication session.
/// Combines user information, tokens, and session metadata.
class AuthSession {
  final String sessionId;
  final AuthUser user;
  final AuthToken? token;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final String? deviceId;
  final String? deviceName;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
  final bool isActive;

  AuthSession({
    required this.sessionId,
    required this.user,
    this.token,
    required this.createdAt,
    required this.lastActivityAt,
    this.deviceId,
    this.deviceName,
    this.ipAddress,
    this.userAgent,
    this.metadata,
    this.isActive = true,
  });

  /// Check if session is expired (24 hours of inactivity)
  bool get isExpired {
    final twentyFourHoursAgo = DateTime.now().subtract(
      const Duration(hours: 24),
    );
    return lastActivityAt.isBefore(twentyFourHoursAgo);
  }

  /// Check if session needs token refresh
  bool get needsTokenRefresh {
    if (token == null) return false;
    return token!.needsRefresh;
  }

  /// Get session duration
  Duration get sessionDuration {
    return lastActivityAt.difference(createdAt);
  }

  /// Get idle time since last activity
  Duration get idleTime {
    return DateTime.now().difference(lastActivityAt);
  }

  /// Check if this is a new session (less than 5 minutes old)
  bool get isNewSession {
    final fiveMinutesAgo = DateTime.now().subtract(
      const Duration(minutes: 5),
    );
    return createdAt.isAfter(fiveMinutesAgo);
  }

  /// Update last activity timestamp
  AuthSession updateActivity() {
    return copyWith(
      lastActivityAt: DateTime.now(),
    );
  }

  /// Update session token
  AuthSession updateToken(AuthToken newToken) {
    return copyWith(
      token: newToken,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Deactivate session
  AuthSession deactivate() {
    return copyWith(
      isActive: false,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Copy with new values
  AuthSession copyWith({
    String? sessionId,
    AuthUser? user,
    AuthToken? token,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? deviceId,
    String? deviceName,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return AuthSession(
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthSession &&
      other.sessionId == sessionId &&
      other.user == user &&
      other.token == token &&
      other.createdAt == createdAt &&
      other.lastActivityAt == lastActivityAt &&
      other.isActive == isActive;
  }

  @override
  int get hashCode {
    return sessionId.hashCode ^
      user.hashCode ^
      token.hashCode ^
      createdAt.hashCode ^
      lastActivityAt.hashCode ^
      isActive.hashCode;
  }

  @override
  String toString() {
    return 'AuthSession(sessionId: $sessionId, user: ${user.uid}, isActive: $isActive, idleTime: ${idleTime.inMinutes}min)';
  }
}