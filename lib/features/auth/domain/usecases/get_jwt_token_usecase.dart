// Get JWT Token UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// GetJwtTokenUseCase
///
/// Business logic for retrieving JWT tokens for API authentication.
/// Used for backend API calls that require authentication.
class GetJwtTokenUseCase {
  final IAuthRepository _repository;

  GetJwtTokenUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Get JWT Token
  ///
  /// Returns the current user's JWT token or null
  Future<String?> execute({
    bool forceRefresh = false,
  }) async {
    try {
      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user is currently signed in');
        return null;
      }

      // Get current user
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('Current user is null');
        return null;
      }

      // Note: getIdToken method needs to be added to IAuthRepository
      // Firebase Auth provides this functionality
      throw UnimplementedError(
        'getIdToken not yet implemented in repository. '
        'Please add getIdToken method to IAuthRepository for JWT token retrieval.'
      );

      // Future implementation will look like:
      // final token = await _repository.getIdToken(forceRefresh: forceRefresh);
      //
      // if (token == null || token.isEmpty) {
      //   debugPrint('Failed to retrieve JWT token');
      //   return null;
      // }
      //
      // // Log token info (not the token itself for security)
      // debugPrint('JWT token retrieved successfully (length: ${token.length})');
      //
      // return token;

    } on AuthFailure catch (e) {
      debugPrint('Failed to get JWT token with AuthFailure: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Failed to get JWT token with unexpected error: $e');
      return null;
    }
  }

  /// Get custom claims from JWT token
  ///
  /// Returns a map of custom claims or null
  Future<Map<String, dynamic>?> getCustomClaims() async {
    try {
      // Note: This requires decoding the JWT token
      // Implementation would need JWT decoding logic
      throw UnimplementedError(
        'getCustomClaims not yet implemented. '
        'Requires JWT decoding logic to extract custom claims.'
      );

      // Future implementation will decode JWT and extract claims

    } catch (e) {
      debugPrint('Failed to get custom claims: $e');
      return null;
    }
  }
}