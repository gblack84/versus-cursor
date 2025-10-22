import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../providers/auth_provider.dart';

/// StreamBuilder widget for authenticated user state
///
/// Automatically rebuilds when user authentication state changes.
/// Uses AuthProvider.authStateChanges to monitor user authentication.
///
/// Example:
/// ```dart
/// AuthUserStreamWidget(
///   builder: (context) => Text('User logged in'),
/// )
/// ```
class AuthUserStreamWidget extends StatelessWidget {
  const AuthUserStreamWidget({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final authProvider = GetIt.instance<AuthProvider>();
    return StreamBuilder(
      stream: authProvider.authStateChanges,
      builder: (context, _) => builder(context),
    );
  }
}
