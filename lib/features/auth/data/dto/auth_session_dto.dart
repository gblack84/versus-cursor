// Authentication Session DTO
// Clean Architecture - Data Layer

import 'auth_token_dto.dart';
import 'auth_user_dto.dart';

/// AuthSessionDto
///
/// Data Transfer Object for complete authentication session.
/// Combines user information, tokens, and session metadata.
class AuthSessionDto {
  final String sessionId;
  final AuthUserDto user;
  final AuthTokenDto? token;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final String? deviceId;
  final String? deviceName;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
  final bool isActive;

  AuthSessionDto({
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

  /// Create a new session from Firebase Auth
  factory AuthSessionDto.fromFirebaseAuth({
    required AuthUserDto user,
    AuthTokenDto? token,
    String? deviceId,
    String? deviceName,
  }) {
    final now = DateTime.now();
    return AuthSessionDto(
      sessionId: _generateSessionId(user.uid),
      user: user,
      token: token,
      createdAt: now,
      lastActivityAt: now,
      deviceId: deviceId,
      deviceName: deviceName,
      metadata: {
        'authProvider': user.providerId,
        'createdWith': 'firebase_auth',
      },
    );
  }

  /// Generate unique session ID
  static String _generateSessionId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'session_${userId}_$timestamp';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'user': user.toJson(),
      'token': token?.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActivityAt': lastActivityAt.millisecondsSinceEpoch,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      sessionId: json['sessionId'] ?? '',
      user: AuthUserDto.fromJson(json['user'] ?? {}),
      token: json['token'] != null
        ? AuthTokenDto.fromJson(json['token'])
        : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? 0,
      ),
      lastActivityAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastActivityAt'] ?? 0,
      ),
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] ?? false,
    );
  }

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

  /// Update last activity timestamp
  AuthSessionDto updateActivity() {
    return copyWith(
      lastActivityAt: DateTime.now(),
    );
  }

  /// Update session token
  AuthSessionDto updateToken(AuthTokenDto newToken) {
    return copyWith(
      token: newToken,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Deactivate session
  AuthSessionDto deactivate() {
    return copyWith(
      isActive: false,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Copy with new values
  AuthSessionDto copyWith({
    String? sessionId,
    AuthUserDto? user,
    AuthTokenDto? token,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? deviceId,
    String? deviceName,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return AuthSessionDto(
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

  /// Get session info for display
  Map<String, String> get displayInfo {
    return {
      'Session ID': sessionId.substring(0, 16) + '...',
      'User': user.email ?? user.phoneNumber ?? 'Anonymous',
      'Device': deviceName ?? 'Unknown Device',
      'Created': createdAt.toLocal().toString(),
      'Last Active': lastActivityAt.toLocal().toString(),
      'Status': isActive ? 'Active' : 'Inactive',
    };
  }

  @override
  String toString() {
    return 'AuthSessionDto(sessionId: $sessionId, user: ${user.uid}, isActive: $isActive, idleTime: ${idleTime.inMinutes}min)';
  }
}