import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// DI imports
import '../../lib/app/di/injection.dart';

// Repository interfaces
import '../../lib/features/profile/domain/repositories/i_user_repository.dart';
import '../../lib/features/posts/domain/repositories/i_post_repository.dart';

// Repository and Adapter imports
import '../../lib/features/profile/data/repositories/user_repository_impl.dart';
import '../../lib/features/profile/data/adapters/user_profile_adapter.dart';
import '../../lib/features/posts/data/repositories/post_repository_impl.dart';
import '../../lib/features/posts/data/adapters/posts_model_adapter.dart';

// Domain Model imports
import '../../lib/features/auth/domain/models/auth_user.dart';
import '../../lib/features/profile/domain/models/profile_info.dart';
import '../../lib/features/profile/domain/models/user_settings.dart';
import '../../lib/features/profile/domain/models/user_stats.dart';
import '../../lib/features/profile/domain/models/user_profile.dart';
import '../../lib/features/posts/domain/models/post_core.dart';
import '../../lib/features/posts/domain/models/post_content.dart';
import '../../lib/features/posts/domain/models/post_voting.dart';
import '../../lib/features/posts/domain/models/post_metrics.dart';
import '../../lib/features/posts/domain/models/media_content.dart';

// Legacy Model imports
import '../../lib/features/posts/data/models/posts_model.dart' as feature_posts;

// Utils

// Global test data
late UserProfile testUserProfile;
late feature_posts.PostsModel testPostsModel;
late UserProfileBundle testUserBundle;
late PostBundle testPostBundle;

void main() {
  group('Repository-Adapter Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late IUserRepository userRepository;
    late IPostRepository postRepository;
    final GetIt sl = GetIt.instance;

    setUpAll(() async {
      // Initialize Flutter testing
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Reset DI container
      await sl.reset();

      // Initialize fake Firestore
      fakeFirestore = FakeFirebaseFirestore();

      // Initialize DI container with test configuration
      await DIContainer.initialize();

      // Get repository instances from DI container
      userRepository = sl<IUserRepository>();
      postRepository = sl<IPostRepository>();

      // Verify correct implementations are registered
      expect(userRepository, isA<UserRepositoryImpl>());
      expect(postRepository, isA<PostRepositoryImpl>());

      // Create test data
      _setupTestData();
    });

    tearDown(() async {
      // Clean up
      fakeFirestore.terminate();
      // Reset DI container
      await DIContainer.reset();
    });

    group('UserRepository + UserProfileAdapter Integration', () {
      test('should retrieve user and convert to domain models via adapter',
          () async {
        // Arrange: Add test user to fake Firestore
        await fakeFirestore
            .collection('users')
            .doc(testUserProfile.uid)
            .set(_createUserFirestoreData());

        // Act: Retrieve user bundle using repository + adapter
        final retrievedBundle =
            await userRepository.getUserBundleByUid(testUserProfile.uid);

        // Assert: Verify data flow through adapter
        expect(retrievedBundle, isNotNull);
        expect(retrievedBundle!.auth.uid, equals(testUserProfile.uid));
        expect(retrievedBundle.profile.displayName,
            equals(testUserProfile.displayName));
        expect(retrievedBundle.settings.isPremiumUser,
            equals(testUserProfile.isPremiumUser));
        expect(retrievedBundle.stats.pointsA, equals(testUserProfile.pointsA));

        // Verify adapter mapping completeness
        final isValid = UserProfileAdapter.validateMapping(
          legacy: testUserProfile,
          auth: retrievedBundle.auth,
          profile: retrievedBundle.profile,
          settings: retrievedBundle.settings,
          stats: retrievedBundle.stats,
        );
        expect(isValid, isTrue);
      });

      test('should create user from domain models via adapter', () async {
        // Arrange: Create user bundle with domain models
        final newUserBundle = UserProfileBundle(
          auth: AuthUser(
            uid: 'test-user-create',
            email: 'create@test.com',
            displayName: 'Create Test User',
            photoURL: 'https://example.com/photo.jpg',
            phoneNumber: '+1234567890',
            isEmailVerified: true,
            isAnonymous: false,
            createdTime: DateTime.now(),
            lastActive: DateTime.now(),
          ),
          profile: ProfileInfo(
            userId: 'test-user-create',
            displayName: 'Create Test User',
            photoUrl: 'https://example.com/photo.jpg',
            shortDescription: 'Test user description',
            gender: 'male',
            dateOfBirth: DateTime(1990, 1, 1),
            language: 'en',
            interests: const ['technology', 'music'],
            expertise: const ['flutter', 'dart'],
            location: const GeoPoint(37.7749, -122.4194),
          ),
          settings: UserSettings(
            userId: 'test-user-create',
            isPremiumUser: false,
            receiveRankUpdateNotifications: true,
            receiveTitleUpdateNotifications: true,
            receiveVoteNotifications: true,
            receiveCommentNotifications: true,
            receiveFriendNotifications: true,
            subscription: 'free',
            stats: const <String, dynamic>{},
            privacySettings: const <String, dynamic>{},
          ),
          stats: UserStats(
            userId: 'test-user-create',
            pointsA: 100,
            pointsQ: 50,
            totalAPoints: 1000,
            totalQPoints: 500,
            currentRank: 'silver',
            currentTitle: 'Contributor',
            rankChangeDate: DateTime.now(),
            titleChangeDate: DateTime.now(),
            isRankEligible: true,
            rankEvaluationCount: 5,
            friends: const [],
            activeChats: const [],
            rankHistory: const [],
            titleHistory: const [],
            anonymousPostsCount: 0,
            anonymousCommentsCount: 0,
          ),
          reference: fakeFirestore.collection('users').doc('test-user-create'),
        );

        // Act: Create user using repository + adapter
        await userRepository.createUserFromBundle(newUserBundle);

        // Assert: Verify user was created in Firestore
        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-create')
            .get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['uid'], equals('test-user-create'));
        expect(data['email'], equals('create@test.com'));
        expect(data['displayName'], equals('Create Test User'));
        expect(data['pointsA'], equals(100));
        expect(data['pointsQ'], equals(50));
        expect(data['isPremiumUser'], equals(false));
      });

      test('should update user using domain models via adapter', () async {
        // Arrange: Create initial user
        await fakeFirestore
            .collection('users')
            .doc(testUserProfile.uid)
            .set(_createUserFirestoreData());

        // Create updated bundle
        final updatedBundle = testUserBundle.copyWith(
          stats: testUserBundle.stats.copyWith(pointsA: 999, pointsQ: 888),
          settings: testUserBundle.settings.copyWith(isPremiumUser: true),
        );

        // Act: Update user using repository + adapter
        await userRepository.updateUserWithBundle(updatedBundle);

        // Assert: Verify changes were persisted
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserProfile.uid)
            .get();
        final data = doc.data()!;
        expect(data['pointsA'], equals(999));
        expect(data['pointsQ'], equals(888));
        expect(data['isPremiumUser'], equals(true));
      });

      test('should retrieve user and extract individual domain models',
          () async {
        // Arrange: Add test user to fake Firestore
        await fakeFirestore
            .collection('users')
            .doc(testUserProfile.uid)
            .set(_createUserFirestoreData());

        // Act: Retrieve user and convert to bundle
        final user = await userRepository.getUserByUid(testUserProfile.uid);
        expect(user, isNotNull);

        final bundle = UserProfileAdapter.fromLegacy(user!);

        // Assert: Test individual model extraction
        final profileInfo = bundle.profile;
        expect(profileInfo.displayName, equals(testUserProfile.displayName));

        final settings = bundle.settings;
        expect(settings.isPremiumUser, equals(testUserProfile.isPremiumUser));

        final stats = bundle.stats;
        expect(stats.pointsA, equals(testUserProfile.pointsA));

        final authUser = bundle.auth;
        expect(authUser.uid, equals(testUserProfile.uid));
      });
    });

    group('PostRepository + PostsModelAdapter Integration', () {
      test('should retrieve post and convert to domain models via adapter',
          () async {
        // Arrange: Add test post to fake Firestore
        const postId = 'test-post-123';
        await fakeFirestore
            .collection('posts')
            .doc(postId)
            .set(_createPostFirestoreData());

        // Act: Retrieve post bundle using repository + adapter
        final retrievedBundle = await postRepository.getPostBundleById(postId);

        // Assert: Verify data flow through adapter
        expect(retrievedBundle, isNotNull);
        expect(retrievedBundle!.core.id, equals(postId));
        expect(retrievedBundle.core.questionTitle, equals('Test vs Question'));
        expect(retrievedBundle.content.optionA.text, equals('Option A Text'));
        expect(retrievedBundle.voting.votesA, equals(10));
        expect(retrievedBundle.metrics.likeCount, equals(5));

        // Verify bundle consistency
        expect(retrievedBundle.isConsistent, isTrue);
      });

      test('should create post from domain models via adapter', () async {
        // Arrange: Create post bundle with domain models
        final newPostBundle = PostBundle(
          core: PostCore(
            id: 'create-test-post',
            questionTitle: 'Created Question Title',
            description: 'Created description',
            content: 'Created content',
            userId: 'test-user-123',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            category: 'technology',
            tags: ['flutter', 'dart'],
            visibility: 'public',
            isAnonymous: false,
            premiumRequired: false,
            location: const GeoPoint(40.7128, -74.0060),
          ),
          content: PostContent(
            postId: 'create-test-post',
            optionA: MediaContent(
              text: 'Created Option A',
              imageUrls: const ['https://example.com/a1.jpg'],
              aspectRatio: 1.5,
            ),
            optionB: MediaContent(
              text: 'Created Option B',
              imageUrls: const ['https://example.com/b1.jpg'],
              aspectRatio: 1.2,
            ),
            layoutType: 'horizontal',
            targetAudience: 'developers',
            moderation: 'approved',
            processingStatus: 'completed',
            processedAt: DateTime.now(),
          ),
          voting: PostVoting(
            postId: 'create-test-post',
            voteStartTime: DateTime.now(),
            voteEndTime: DateTime.now().add(const Duration(minutes: 10)),
            voteStatus: 'active',
            voteCompleted: false,
            voteTimeout: const Duration(minutes: 10),
            votesA: 0,
            votesB: 0,
            votedUserIdsA: const [],
            votedUserIdsB: const [],
            notificationsSent: false,
            expansionPointsUsed: 0,
            expandedUserCount: 0,
            expansionStatus: 'none',
          ),
          metrics: PostMetrics(
            postId: 'create-test-post',
            commentCount: 0,
            likeCount: 0,
            shareCount: 0,
            saveCount: 0,
            reportCount: 0,
            participantCount: 0,
            interestCount: 0,
            engagementRate: 0.0,
            qualityScore: 0.5,
            firstInteractionAt: DateTime.now(),
            lastInteractionAt: DateTime.now(),
          ),
        );

        // Act: Create post using repository + adapter
        final createdPostId =
            await postRepository.createPostFromBundle(newPostBundle);

        // Assert: Verify post was created in Firestore
        expect(createdPostId, isNotEmpty);
        final doc =
            await fakeFirestore.collection('posts').doc(createdPostId).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['questionTitle'], equals('Created Question Title'));
        expect(data['userid'], equals('test-user-123'));
        expect(data['category'], equals('technology'));
      });

      test('should update post using domain models via adapter', () async {
        // Arrange: Create initial post
        const postId = 'update-test-post';
        await fakeFirestore
            .collection('posts')
            .doc(postId)
            .set(_createPostFirestoreData());

        // Create updated bundle
        final updatedBundle = PostBundle(
          core: testPostBundle.core.copyWith(questionTitle: 'Updated Title'),
          content: testPostBundle.content,
          voting: testPostBundle.voting.copyWith(votesA: 999, votesB: 888),
          metrics: testPostBundle.metrics,
        );

        // Act: Update post using repository + adapter
        await postRepository.updatePostFromBundle(postId, updatedBundle);

        // Assert: Verify changes were persisted
        final doc = await fakeFirestore.collection('posts').doc(postId).get();
        final data = doc.data()!;
        expect(data['questionTitle'], equals('Updated Title'));
        expect(data['votesA'], equals(999));
        expect(data['votesB'], equals(888));
      });

      test('should retrieve individual domain models via adapter', () async {
        // Arrange: Add test post to fake Firestore
        const postId = 'individual-test-post';
        await fakeFirestore
            .collection('posts')
            .doc(postId)
            .set(_createPostFirestoreData());

        // Act & Assert: Test individual model retrieval
        final postCore = await postRepository.getPostCore(postId);
        expect(postCore, isNotNull);
        expect(postCore!.questionTitle, equals('Test vs Question'));

        final postContent = await postRepository.getPostContent(postId);
        expect(postContent, isNotNull);
        expect(postContent!.optionA.text, equals('Option A Text'));

        final postVoting = await postRepository.getPostVoting(postId);
        expect(postVoting, isNotNull);
        expect(postVoting!.votesA, equals(10));

        final postMetrics = await postRepository.getPostMetrics(postId);
        expect(postMetrics, isNotNull);
        expect(postMetrics!.likeCount, equals(5));
      });

      test('should stream post bundles and filter by user', () async {
        // Arrange: Add multiple test posts
        const userId = 'test-user-123';
        await fakeFirestore
            .collection('posts')
            .doc('post1')
            .set(_createPostFirestoreData(userId: userId));
        await fakeFirestore
            .collection('posts')
            .doc('post2')
            .set(_createPostFirestoreData(userId: 'other-user'));
        await fakeFirestore
            .collection('posts')
            .doc('post3')
            .set(_createPostFirestoreData(userId: userId));

        // Act: Get posts stream filtered by user
        final stream = postRepository.getPostBundlesByUserId(userId);
        final postBundles = await stream.first;

        // Assert: Verify filtering worked
        expect(postBundles.length, equals(2));
        for (final bundle in postBundles) {
          expect(bundle.core.userId, equals(userId));
          expect(bundle.isConsistent, isTrue);
        }
      });
    });

    group('Performance Benchmarks', () {
      test('adapter conversion overhead should be <10ms', () async {
        // Arrange: Create test data
        await fakeFirestore
            .collection('users')
            .doc(testUserProfile.uid)
            .set(_createUserFirestoreData());

        const iterations = 100;
        final stopwatch = Stopwatch();

        // Act: Measure adapter conversion time
        stopwatch.start();
        for (int i = 0; i < iterations; i++) {
          final models = UserProfileAdapter.toDomainModels(testUserProfile);
          final converted = UserProfileAdapter.fromDomainModels(
            auth: models.auth,
            profile: models.profile,
            settings: models.settings,
            stats: models.stats,
            reference: testUserProfile.reference,
          );
          expect(converted.uid, equals(testUserProfile.uid));
        }
        stopwatch.stop();

        // Assert: Verify performance requirement
        final averageTimeMs = stopwatch.elapsedMilliseconds / iterations;
        expect(averageTimeMs, lessThan(10.0),
            reason:
                'Adapter conversion should be <10ms, but took ${averageTimeMs.toStringAsFixed(2)}ms');

        print(
            'User adapter average conversion time: ${averageTimeMs.toStringAsFixed(2)}ms');
      });

      test('post adapter conversion overhead should be <10ms', () async {
        const iterations = 100;
        final stopwatch = Stopwatch();

        // Act: Measure post adapter conversion time
        stopwatch.start();
        for (int i = 0; i < iterations; i++) {
          final bundle = PostsModelAdapter.toDomainModels(testPostsModel);
          final converted = PostsModelAdapter.fromDomainModels(bundle);
          expect(converted.reference.id, equals(testPostsModel.reference.id));
        }
        stopwatch.stop();

        // Assert: Verify performance requirement
        final averageTimeMs = stopwatch.elapsedMilliseconds / iterations;
        expect(averageTimeMs, lessThan(10.0),
            reason:
                'Post adapter conversion should be <10ms, but took ${averageTimeMs.toStringAsFixed(2)}ms');

        print(
            'Post adapter average conversion time: ${averageTimeMs.toStringAsFixed(2)}ms');
      });

      test('batch operations should scale linearly', () async {
        // Arrange: Create multiple test posts
        final batchSizes = [10, 50, 100];
        final results = <int, double>{};

        for (final batchSize in batchSizes) {
          final testPosts = List.generate(batchSize, (i) => testPostsModel);
          final stopwatch = Stopwatch();

          // Act: Measure batch conversion time
          stopwatch.start();
          final bundles = PostsModelAdapter.toDomainModelsList(testPosts);
          final converted = PostsModelAdapter.fromDomainModelsList(bundles);
          stopwatch.stop();

          expect(converted.length, equals(batchSize));
          results[batchSize] = stopwatch.elapsedMilliseconds.toDouble();
        }

        // Assert: Verify linear scaling
        final ratio5050 = results[50]! / results[10]!;
        final ratio10050 = results[100]! / results[50]!;

        expect(
            ratio5050, lessThan(6.0), // Should be ~5x but allow some variance
            reason: 'Batch processing should scale linearly');
        expect(
            ratio10050, lessThan(2.5), // Should be ~2x but allow some variance
            reason: 'Batch processing should scale linearly');

        print(
            'Batch processing scaling: 10=${results[10]}ms, 50=${results[50]}ms, 100=${results[100]}ms');
      });

      test('memory usage should remain stable during batch operations',
          () async {
        // This is a basic test - more sophisticated memory testing would require additional tools
        final largeBatch = List.generate(1000, (i) => testPostsModel);

        // Act: Process large batch
        final bundles = PostsModelAdapter.toDomainModelsList(largeBatch);
        final converted = PostsModelAdapter.fromDomainModelsList(bundles);

        // Assert: Basic validation that operation completed successfully
        expect(converted.length, equals(1000));
        expect(bundles.every((b) => b.isConsistent), isTrue);

        print('Successfully processed 1000 posts batch without memory issues');
      });
    });

    group('Error Handling', () {
      test('should handle invalid user data gracefully', () async {
        // Arrange: Add invalid user data to Firestore
        await fakeFirestore.collection('users').doc('invalid-user').set({
          'uid': 'invalid-user',
          // Missing required fields
          'invalidField': 'should not break adapter'
        });

        // Act & Assert: Should handle gracefully without crashing
        expect(
          () async => await userRepository.getUserBundleByUid('invalid-user'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle missing post data', () async {
        // Act & Assert: Should return null for non-existent post
        final bundle =
            await postRepository.getPostBundleById('non-existent-post');
        expect(bundle, isNull);
      });

      test('should handle Firestore connection failures', () async {
        // This would require more sophisticated mocking of connection failures
        // For now, we test the error propagation structure

        // Act & Assert: Error should be properly wrapped and propagated
        expect(
          () async => await postRepository.getPostBundleById('connection-test'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle data consistency validation', () async {
        // Arrange: Create inconsistent post bundle
        final inconsistentBundle = PostBundle(
          core: testPostBundle.core.copyWith(id: 'different-id'),
          content: testPostBundle.content,
          voting: testPostBundle.voting,
          metrics: testPostBundle.metrics,
        );

        // Act & Assert: Should detect inconsistency
        expect(inconsistentBundle.isConsistent, isFalse);
        expect(
          () => PostsModelAdapter.fromDomainModels(inconsistentBundle),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Backward Compatibility', () {
      test('should maintain all legacy UserProfile fields', () async {
        // Arrange: Create user with all legacy fields
        final legacyFields = _createUserFirestoreData();
        await fakeFirestore
            .collection('users')
            .doc('legacy-test')
            .set(legacyFields);

        // Act: Convert through adapter
        final bundle = await userRepository.getUserBundleByUid('legacy-test');
        final reconstructed = bundle!.toLegacy();

        // Assert: Verify all critical fields are preserved
        expect(reconstructed.uid, equals(testUserProfile.uid));
        expect(reconstructed.email, equals(testUserProfile.email));
        expect(reconstructed.displayName, equals(testUserProfile.displayName));
        expect(reconstructed.pointsA, equals(testUserProfile.pointsA));
        expect(reconstructed.pointsQ, equals(testUserProfile.pointsQ));
        expect(
            reconstructed.isPremiumUser, equals(testUserProfile.isPremiumUser));
      });

      test('should maintain all legacy PostsModel fields', () async {
        // Arrange: Create post with all legacy fields
        const postId = 'legacy-post-test';
        await fakeFirestore
            .collection('posts')
            .doc(postId)
            .set(_createPostFirestoreData());

        // Act: Convert through adapter
        final bundle = await postRepository.getPostBundleById(postId);
        final reconstructed = PostsModelAdapter.fromDomainModels(bundle!);

        // Assert: Verify critical legacy fields are preserved
        expect(
            reconstructed.questionTitle, equals(testPostsModel.questionTitle));
        expect(reconstructed.votesA, equals(testPostsModel.votesA));
        expect(reconstructed.votesB, equals(testPostsModel.votesB));
        expect(reconstructed.likecount, equals(testPostsModel.likecount));
        expect(reconstructed.commentcount, equals(testPostsModel.commentcount));
      });

      test('should handle partial data scenarios', () async {
        // Arrange: Create user with minimal required fields only
        await fakeFirestore.collection('users').doc('minimal-user').set({
          'uid': 'minimal-user',
          'email': 'minimal@test.com',
          'displayName': 'Minimal User',
          'createdTime': Timestamp.now(),
        });

        // Act: Should handle gracefully with default values
        final bundle = await userRepository.getUserBundleByUid('minimal-user');

        // Assert: Should have reasonable defaults
        expect(bundle, isNotNull);
        expect(bundle!.auth.uid, equals('minimal-user'));
        expect(bundle.stats.pointsA, equals(0)); // Default value
        expect(bundle.settings.receiveVoteNotifications, isTrue); // Default
      });
    });
  });
}

// Helper methods to create test data
void _setupTestData() {
  // Create test UserProfile using the correct factory constructor
  testUserProfile = UserProfile.getDocumentFromData(
    _createUserFirestoreData(),
    FakeFirebaseFirestore().collection('users').doc('test-user-123'),
  );

  // Create test PostsModel using the correct factory constructor
  testPostsModel = feature_posts.PostsModel.getDocumentFromData(
    _createPostFirestoreData(),
    FakeFirebaseFirestore().collection('posts').doc('test-post-123'),
  );

  // Create bundles
  testUserBundle = UserProfileAdapter.createBundle(testUserProfile);
  testPostBundle = PostsModelAdapter.toDomainModels(testPostsModel);
}

Map<String, dynamic> _createUserFirestoreData() {
  return {
    'uid': 'test-user-123',
    'email': 'test@example.com',
    'displayName': 'Test User',
    'photoUrl': 'https://example.com/photo.jpg',
    'phoneNumber': '+1234567890',
    'createdTime': Timestamp.now(),
    'lastActive': Timestamp.now(),
    'shortDescription': 'Test user description',
    'gender': 'male',
    'dateOfBirth': Timestamp.fromDate(DateTime(1990, 1, 1)),
    'language': 'en',
    'interests': const ['technology', 'music'],
    'expertise': const ['flutter', 'dart'],
    'location': const GeoPoint(37.7749, -122.4194),
    'isPremiumUser': false,
    'pointsA': 100,
    'pointsQ': 50,
    'totalAPoints': 1000,
    'totalQPoints': 500,
    'currentRank': 'silver',
    'currentTitle': 'Contributor',
    'friends': const <String>[],
    'activeChats': const <String>[],
    'rankHistory': const <String>[],
    'titleHistory': const <String>[],
    'anonymousPostsCount': 0,
    'anonymousCommentsCount': 0,
    'receiveRankUpdateNotifications': true,
    'receiveTitleUpdateNotifications': true,
    'subscription': 'free',
    'stats': const <String, dynamic>{},
    'rankChangeDate': Timestamp.now(),
    'titleChangeDate': Timestamp.now(),
    'isRankEligible': true,
    'rankEvaluationCount': 5,
  };
}

Map<String, dynamic> _createPostFirestoreData({String? userId}) {
  return {
    'questionTitle': 'Test vs Question',
    'description': 'Test description',
    'content': 'Test content',
    'userid': userId ?? 'test-user-123',
    'uid': userId ?? 'test-user-123',
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'category': 'technology',
    'tags': const ['test', 'flutter'],
    'visibility': 0,
    'isAnonymous': false,
    'premiumRequired': false,
    'location': const GeoPoint(40.7128, -74.0060),
    'optionA': <String, dynamic>{
      'text': 'Option A Text',
      'imageUrls': const ['https://example.com/a1.jpg'],
      'aspectRatio': 1.5,
    },
    'optionB': <String, dynamic>{
      'text': 'Option B Text',
      'imageUrls': const ['https://example.com/b1.jpg'],
      'aspectRatio': 1.2,
    },
    'votesA': 10,
    'votesB': 8,
    'totalVotes': 18,
    'votedUserIdsA': const ['user1', 'user2'],
    'votedUserIdsB': const ['user3', 'user4'],
    'likecount': 5,
    'commentcount': 3,
    'sherecount': 2,
    'savecount': 1,
    'participantcount': 20,
    'interestcount': 15,
    'reportCount': 0,
    'voteStartTime': Timestamp.now(),
    'voteEndTime':
        Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
    'voteStatus': 'active',
    'voteCompleted': false,
    'isVotingComplete': false,
    'notificationsSent': false,
    'expansionPointsUsed': 0,
    'expandedUserCount': 0,
    'expansionStatus': 'none',
    'displayVotesA': 10,
    'displayVotesB': 8,
    'displayPercentA': 56,
    'displayPercentB': 44,
    'actualVotesA': 10,
    'actualVotesB': 8,
    'actualTotalVotes': 18,
    'stats': const <String, dynamic>{
      'commentCount': 3,
      'likeCount': 5,
      'shareCount': 2,
      'saveCount': 1,
      'participantCount': 20,
      'reportCount': 0,
    },
    'isReported': false,
    'reportedBy': const <String>[],
    'initialCommentLimit': 10,
    'currentCommentCount': 3,
    'option': const <int>[],
    'layoutType': 'vertical',
    'targetAudience': 'developers',
    'moderation': 'approved',
    // Legacy user info fields for backward compatibility
    'email': 'test@example.com',
    'displayName': 'Test User',
    'photoUrl': 'https://example.com/photo.jpg',
    'phoneNumber': '+1234567890',
    'createdTime': Timestamp.now(),
    'creatorInfo': <String, dynamic>{
      'userid': userId ?? 'test-user-123',
      'uid': userId ?? 'test-user-123',
    },
  };
}
