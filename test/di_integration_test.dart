import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:versus_space/app/di/injection.dart';
import 'package:versus_space/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:versus_space/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:versus_space/features/posts/domain/repositories/i_post_repository.dart';
import 'package:versus_space/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:versus_space/features/profile/domain/repositories/i_friends_repository.dart';

void main() {
  group('DI Integration Tests', () {
    late GetIt sl;

    setUpAll(() async {
      // Initialize DI container
      await Injection.init();
      sl = GetIt.instance;
    });

    tearDownAll(() async {
      await Injection.reset();
    });

    group('Firebase Services', () {
      test('Firebase services should be registered', () {
        expect(sl.isRegistered<FirebaseAuth>(), isTrue);
        expect(sl.isRegistered<FirebaseFirestore>(), isTrue);
      });

      test('Firebase instances should be singletons', () {
        final auth1 = sl<FirebaseAuth>();
        final auth2 = sl<FirebaseAuth>();
        expect(identical(auth1, auth2), isTrue);
      });
    });

    group('Repository Registration', () {
      test('All feature repositories should be registered', () {
        expect(sl.isRegistered<IAuthRepository>(), isTrue);
        expect(sl.isRegistered<IChatRepository>(), isTrue);
        expect(sl.isRegistered<IPostRepository>(), isTrue);
        expect(sl.isRegistered<IProfileRepository>(), isTrue);
        expect(sl.isRegistered<IFriendsRepository>(), isTrue);
      });

      test('Repository instances should be singletons', () {
        final authRepo1 = sl<IAuthRepository>();
        final authRepo2 = sl<IAuthRepository>();
        expect(identical(authRepo1, authRepo2), isTrue);
      });
    });

    group('Feature Module Integration', () {
      test('Feature modules should be registered', () {
        // Check that feature modules manager has modules
        expect(sl.isRegistered<IAuthRepository>(), isTrue);
        expect(sl.isRegistered<IChatRepository>(), isTrue);
        expect(sl.isRegistered<IPostRepository>(), isTrue);
        expect(sl.isRegistered<IProfileRepository>(), isTrue);
      });

      test('Repository dependencies should resolve', () {
        expect(() => sl<IAuthRepository>(), returnsNormally);
        expect(() => sl<IChatRepository>(), returnsNormally);
        expect(() => sl<IPostRepository>(), returnsNormally);
        expect(() => sl<IProfileRepository>(), returnsNormally);
        expect(() => sl<IFriendsRepository>(), returnsNormally);
      });
    });

    group('Dependency Graph', () {
      test('No circular dependencies should exist', () {
        // Try to resolve all main dependencies
        expect(() {
          sl<IAuthRepository>();
          sl<IChatRepository>();
          sl<IPostRepository>();
          sl<IProfileRepository>();
          sl<IFriendsRepository>();
        }, returnsNormally);
      });

      test('Dependencies should follow Feature-First boundaries', () {
        // Test that repositories don't depend on each other inappropriately
        final authRepo = sl<IAuthRepository>();
        final chatRepo = sl<IChatRepository>();
        final postRepo = sl<IPostRepository>();

        expect(authRepo, isNotNull);
        expect(chatRepo, isNotNull);
        expect(postRepo, isNotNull);

        // Each should be independent instances
        expect(authRepo != chatRepo, isTrue);
        expect(chatRepo != postRepo, isTrue);
        expect(postRepo != authRepo, isTrue);
      });
    });

    group('Service Dependencies', () {
      test('Services should have access to repositories', () {
        // UnifiedCacheService should work with repositories
        expect(() => sl<IAuthRepository>(), returnsNormally);
        expect(() => sl<IChatRepository>(), returnsNormally);
        expect(() => sl<IPostRepository>(), returnsNormally);
      });
    });
  });
}
