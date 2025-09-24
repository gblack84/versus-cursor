import 'package:rxdart/rxdart.dart';
import 'package:go_router/go_router.dart';

import '/core/interfaces/i_base_auth_user.dart';
export '/core/interfaces/i_base_auth_user.dart';

/// Extension methods for BaseAuthUser stream operations
extension BaseAuthUserStreamX on Stream<BaseAuthUser> {
  /// Handles authentication state changes and retries
  Stream<BaseAuthUser> get onAuthUserChange => switchMap(
        (user) => user.loggedIn
            ? ConcatStream([
                Stream.value(user),
                Rx.timer(
                  user,
                  const Duration(seconds: 1),
                ).asyncMap(
                  (user) async {
                    await user.refreshUser();
                    return user;
                  },
                ),
              ])
            : Stream.value(user),
      );
}

/// Extension for GoRouter context
extension GoRouterStateAuthExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      (extra as Map<String, dynamic>?) ?? <String, dynamic>{};
}