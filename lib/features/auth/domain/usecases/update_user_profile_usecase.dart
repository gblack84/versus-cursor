// Update User Profile UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// UpdateUserProfileUseCase
///
/// Business logic for updating user profile information.
/// Handles validation and profile update operations.
class UpdateUserProfileUseCase {
  final IAuthRepository _repository;

  UpdateUserProfileUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Update user display name and photo URL
  ///
  /// Returns true on success, false on failure
  Future<bool> execute({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      debugPrint('Updating user profile...');

      // At least one field must be provided
      if (displayName == null && photoURL == null) {
        debugPrint('No profile data to update');
        return false;
      }

      // Validate display name if provided
      if (displayName != null) {
        if (!_isValidDisplayName(displayName)) {
          debugPrint('Invalid display name: $displayName');
          return false;
        }
      }

      // Validate photo URL if provided
      if (photoURL != null) {
        if (!_isValidPhotoURL(photoURL)) {
          debugPrint('Invalid photo URL: $photoURL');
          return false;
        }
      }

      // Call repository method
      await _repository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      debugPrint('Profile updated successfully');
      return true;

    } catch (e) {
      if (e is AuthFailure) {
        debugPrint('Profile update failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Profile update failed with unexpected error: $e');
      }
      return false;
    }
  }

  /// Validate display name
  bool _isValidDisplayName(String displayName) {
    // Display name validation rules:
    // - Not empty
    // - Between 3 and 30 characters
    // - No special characters except space, dash, apostrophe
    // - No consecutive spaces

    if (displayName.isEmpty) {
      return false;
    }

    if (displayName.length < 3 || displayName.length > 30) {
      return false;
    }

    // Check for valid characters
    final validNameRegex = RegExp(r"^[a-zA-Z0-9\s\-']+$");
    if (!validNameRegex.hasMatch(displayName)) {
      return false;
    }

    // Check for consecutive spaces
    if (displayName.contains('  ')) {
      return false;
    }

    return true;
  }

  /// Validate photo URL
  bool _isValidPhotoURL(String photoURL) {
    // Photo URL validation rules:
    // - Must be a valid URL
    // - Should be HTTPS (for security)
    // - Should point to an image file or known image hosting service

    if (photoURL.isEmpty) {
      return false;
    }

    // Check if it's a valid URL
    try {
      final uri = Uri.parse(photoURL);

      // Must be HTTP or HTTPS
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Prefer HTTPS for security
      if (uri.scheme != 'https') {
        debugPrint('Warning: Photo URL is not using HTTPS');
      }

      // Check for common image extensions or known image hosts
      final validImageHosts = [
        'firebasestorage.googleapis.com',
        'googleusercontent.com',
        'facebook.com',
        'fbcdn.net',
        'apple.com',
        'icloud.com',
      ];

      final hasValidHost = validImageHosts.any((host) => uri.host.contains(host));
      final hasImageExtension = photoURL.toLowerCase().endsWith('.jpg') ||
                                photoURL.toLowerCase().endsWith('.jpeg') ||
                                photoURL.toLowerCase().endsWith('.png') ||
                                photoURL.toLowerCase().endsWith('.gif') ||
                                photoURL.toLowerCase().endsWith('.webp');

      if (!hasValidHost && !hasImageExtension) {
        debugPrint('Warning: Photo URL might not be a valid image');
      }

      return true;
    } catch (e) {
      debugPrint('Invalid URL format: $photoURL');
      return false;
    }
  }
}