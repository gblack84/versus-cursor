// Create Test Account UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// CreateTestAccountUseCase
///
/// Business logic for creating and managing test accounts.
/// Used for development and testing purposes.
class CreateTestAccountUseCase {
  final IAuthRepository _repository;

  CreateTestAccountUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Test Account Creation
  ///
  /// Creates a test account or signs in if it already exists
  Future<TestAccountResult> execute({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? platform,
  }) async {
    try {
      debugPrint('Creating or accessing test account: $displayName');

      // Validate input parameters
      if (!_isValidEmail(email)) {
        return TestAccountResult(
          success: false,
          message: 'Invalid email format',
        );
      }

      if (password.length < 6) {
        return TestAccountResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }

      if (displayName.isEmpty) {
        return TestAccountResult(
          success: false,
          message: 'Display name is required',
        );
      }

      // Validate role
      if (!_isValidRole(role)) {
        return TestAccountResult(
          success: false,
          message: 'Invalid role: $role',
        );
      }

      // First, try to sign in with existing account
      debugPrint('Attempting to sign in with existing test account...');
      var user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      bool isNewAccount = false;

      // If sign in fails, create new account
      if (user == null) {
        debugPrint('Account does not exist, creating new test account...');

        user = await _repository.createUserWithEmailAndPassword(
          email,
          password,
        );

        if (user == null) {
          return TestAccountResult(
            success: false,
            message: '$displayName account creation failed',
          );
        }

        isNewAccount = true;

        // Update profile with display name
        await _repository.updateUserProfile(
          displayName: displayName,
          photoURL: null,
        );

        debugPrint('Test account created successfully: $displayName');
      } else {
        debugPrint('Signed in to existing test account: $displayName');
      }

      // Note: Additional user profile setup (role, platform, etc.)
      // should be handled by a separate UserProfileUseCase or
      // through the repository layer if needed

      return TestAccountResult(
        success: true,
        user: user,
        isNewAccount: isNewAccount,
        message: isNewAccount
          ? 'Test account created: $displayName'
          : 'Signed in to existing test account: $displayName',
        metadata: TestAccountMetadata(
          role: role,
          platform: platform ?? _detectPlatform(),
          createdAt: DateTime.now(),
        ),
      );

    } on AuthFailure catch (e) {
      String message = 'Authentication failed';

      if (e is EmailAlreadyInUse) {
        // This shouldn't happen as we try to sign in first
        message = 'Email already in use with different password';
      } else if (e is WeakPassword) {
        message = 'Password is too weak';
      } else if (e is InvalidEmail) {
        message = 'Invalid email format';
      } else {
        message = 'Failed to create test account: ${e.message}';
      }

      debugPrint('Test account creation failed: $message');
      return TestAccountResult(
        success: false,
        message: message,
      );

    } catch (e) {
      debugPrint('Unexpected error creating test account: $e');
      return TestAccountResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate role
  bool _isValidRole(String role) {
    const validRoles = ['admin', 'tester', 'user', 'developer'];
    return validRoles.contains(role.toLowerCase());
  }

  /// Detect platform
  String _detectPlatform() {
    if (kIsWeb) return 'Web';

    // In a real implementation, you would use Platform.isIOS, etc.
    // For now, return a default
    return 'Unknown';
  }
}

/// Result class for test account creation
class TestAccountResult {
  final bool success;
  final AuthUser? user;
  final String? message;
  final bool isNewAccount;
  final TestAccountMetadata? metadata;

  TestAccountResult({
    required this.success,
    this.user,
    this.message,
    this.isNewAccount = false,
    this.metadata,
  });
}

/// Metadata for test accounts
class TestAccountMetadata {
  final String role;
  final String platform;
  final DateTime createdAt;

  TestAccountMetadata({
    required this.role,
    required this.platform,
    required this.createdAt,
  });
}