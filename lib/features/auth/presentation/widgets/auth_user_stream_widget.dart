import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

/// Consumer widget for authenticated user state
///
/// Automatically rebuilds when user authentication state changes.
/// Uses Riverpod's authStateStreamProvider to monitor user authentication.
///
/// **Important**: This widget makes Firebase Auth's currentUser globally available
/// through module-level getters for backward compatibility during Riverpod migration.
///
/// Example:
/// ```dart
/// AuthUserStreamWidget(
///   builder: (context) => Text('User: $currentUserEmail'),
/// )
/// ```
class AuthUserStreamWidget extends ConsumerWidget {
  const AuthUserStreamWidget({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state stream to trigger rebuilds
    ref.watch(authStateStreamProvider(const AuthStateParams()));

    // Call the builder to render the widget
    return builder(context);
  }
}

// ========== Global Auth State Accessors (Backward Compatibility) ==========
//
// These module-level variables provide backward compatibility during the
// Riverpod migration. They access Firebase Auth directly.
//
// ⚠️ DEPRECATED: Use ref.watch(authStateStreamProvider) instead in new code.

/// Current user's email address (or null if not logged in)
String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

/// Current user's display name (or null if not set)
String? get currentUserDisplayName => FirebaseAuth.instance.currentUser?.displayName;

/// Current user's photo URL (or null if not set)
String? get currentUserPhotoUrl => FirebaseAuth.instance.currentUser?.photoURL;

/// Current user's UID (or empty string if not logged in)
String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

/// Whether current user's email is verified
bool get currentUserEmailVerified => FirebaseAuth.instance.currentUser?.emailVerified ?? false;

/// Current user's phone number (or null if not set)
String? get currentUserPhoneNumber => FirebaseAuth.instance.currentUser?.phoneNumber;
