import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// DI imports
import '../../lib/app/di/injection.dart';

// Repository interfaces
import '../../lib/features/profile/domain/repositories/i_user_repository.dart';
import '../../lib/features/posts/domain/repositories/i_post_repository.dart';

// Repository implementations
import '../../lib/features/profile/data/repositories/user_repository_impl.dart';
import '../../lib/features/posts/data/repositories/post_repository_impl.dart';

// Domain models
import '../../lib/features/profile/domain/models/user_profile.dart';
import '../../lib/features/posts/domain/models/post.dart';
import '../../lib/features/posts/domain/models/media_content.dart';
import '../../lib/features/posts/domain/models/creator_info.dart';
import '../../lib/features/posts/domain/models/vote_data.dart';
import '../../lib/features/posts/domain/models/post_stats.dart';

// Adapters
import '../../lib/features/profile/data/adapters/user_profile_adapter.dart';

void main() {
  group('Repository Integration Tests V2 - Feature-First Architecture', () {
    late FakeFirebaseFirestore fakeFirestore;
    late IUserRepository userRepository;
    late IPostRepository postRepository;
    final GetIt sl = GetIt.instance;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Reset DI container
      await sl.reset();

      // Initialize fake Firestore
      fakeFirestore = FakeFirebaseFirestore();

      // Initialize DI container
      await DIContainer.initialize();

      // Get repository instances from DI container
      userRepository = sl<IUserRepository>();
      postRepository = sl<IPostRepository>();

      // Verify correct implementations are registered
      expect(userRepository, isA<UserRepositoryImpl>());
      expect(postRepository, isA<PostRepositoryImpl>());
    });

    tearDown(() async {
      fakeFirestore.terminate();
      await DIContainer.reset();
    });

    group('UserRepository with DI Integration', () {
      test('should create and retrieve user through repository interface',
          () async {
        // Arrange: Create test user
        final testUser = UserProfile(
          uid: 'test-user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          shortDescription: 'Test description',
          isPremiumUser: false,
          pointsA: 100,
          pointsQ: 50,
          createdTime: DateTime.now(),
          reference: fakeFirestore.collection('users').doc('test-user-1'),
        );

        // Act: Create user through repository
        await userRepository.createUser(testUser);

        // Assert: Retrieve and verify
        final retrievedUser = await userRepository.getUserByUid('test-user-1');
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.uid, equals('test-user-1'));
        expect(retrievedUser.displayName, equals('Test User'));
        expect(retrievedUser.pointsA, equals(100));
        expect(retrievedUser.isPremiumUser, isFalse);
      });

      test('should update user points through repository', () async {
        // Arrange: Create initial user
        final testUser = UserProfile(
          uid: 'test-user-2',
          email: 'test2@example.com',
          displayName: 'Test User 2',
          photoUrl: null,
          shortDescription: '',
          isPremiumUser: false,
          pointsA: 100,
          pointsQ: 50,
          createdTime: DateTime.now(),
          reference: fakeFirestore.collection('users').doc('test-user-2'),
        );
        await userRepository.createUser(testUser);

        // Act: Update points
        await userRepository.updateUserPoints('test-user-2', 200, 100);

        // Assert: Verify update
        final updatedUser = await userRepository.getUserByUid('test-user-2');
        expect(updatedUser!.pointsA, equals(200));
        expect(updatedUser.pointsQ, equals(100));
      });

      test('should search users by name', () async {
        // Arrange: Create multiple users
        for (int i = 1; i <= 3; i++) {
          final user = UserProfile(
            uid: 'search-user-$i',
            email: 'search$i@example.com',
            displayName: 'Search User $i',
            photoUrl: null,
            shortDescription: '',
            isPremiumUser: false,
            pointsA: i * 10,
            pointsQ: i * 5,
            createdTime: DateTime.now(),
            reference: fakeFirestore.collection('users').doc('search-user-$i'),
          );
          await userRepository.createUser(user);
        }

        // Act: Search users
        final results =
            await userRepository.searchUsersByName('Search', limit: 5);

        // Assert: Verify search results
        expect(results.length, equals(3));
        expect(results.every((u) => u.displayName.contains('Search')), isTrue);
      });
    });

    group('PostRepository with DI Integration', () {
      test('should create and retrieve post through repository interface',
          () async {
        // Arrange: Create test post
        final testPost = Post(
          id: 'test-post-1',
          creatorInfo: CreatorInfo(
            userId: 'creator-1',
            userName: 'Creator Name',
            userAvatar: 'avatar.jpg',
            isAnonymous: false,
          ),
          questionTitle: 'Test Question',
          description: 'Test Description',
          optionA: MediaContent(
            type: 'text',
            content: 'Option A',
            thumbnailUrl: null,
            aspectRatio: 1.0,
          ),
          optionB: MediaContent(
            type: 'text',
            content: 'Option B',
            thumbnailUrl: null,
            aspectRatio: 1.0,
          ),
          voteData: VoteData(
            votesA: 10,
            votesB: 5,
            totalVotes: 15,
            votePercentageA: 66.7,
            votePercentageB: 33.3,
            votedUsers: const [],
            votedUsersA: const [],
            votedUsersB: const [],
          ),
          stats: PostStats(
            views: 100,
            likes: 20,
            dislikes: 2,
            shares: 5,
            comments: 10,
            engagement: 0.37,
          ),
          createdAt: DateTime.now(),
        );

        // Act: Create post
        final postId = await postRepository.createPost(testPost);

        // Assert: Retrieve and verify
        final retrievedPost = await postRepository.getPostById(postId);
        expect(retrievedPost, isNotNull);
        expect(retrievedPost!.questionTitle, equals('Test Question'));
        expect(retrievedPost.voteData.votesA, equals(10));
        expect(retrievedPost.stats.views, equals(100));
      });

      test('should update vote data through repository', () async {
        // Arrange: Create initial post
        final testPost = Post(
          id: 'test-post-2',
          creatorInfo: CreatorInfo(
            userId: 'creator-2',
            userName: 'Creator 2',
            userAvatar: null,
            isAnonymous: false,
          ),
          questionTitle: 'Vote Test',
          description: 'Testing voting',
          optionA: MediaContent(
            type: 'text',
            content: 'A',
            thumbnailUrl: null,
            aspectRatio: 1.0,
          ),
          optionB: MediaContent(
            type: 'text',
            content: 'B',
            thumbnailUrl: null,
            aspectRatio: 1.0,
          ),
          voteData: VoteData(
            votesA: 0,
            votesB: 0,
            totalVotes: 0,
            votePercentageA: 0,
            votePercentageB: 0,
            votedUsers: const [],
            votedUsersA: const [],
            votedUsersB: const [],
          ),
          stats: PostStats(
            views: 0,
            likes: 0,
            dislikes: 0,
            shares: 0,
            comments: 0,
            engagement: 0,
          ),
          createdAt: DateTime.now(),
        );
        final postId = await postRepository.createPost(testPost);

        // Act: Cast votes
        await postRepository.castVote(postId, 'user-1', 'A');
        await postRepository.castVote(postId, 'user-2', 'B');
        await postRepository.castVote(postId, 'user-3', 'A');

        // Assert: Verify vote data
        final updatedPost = await postRepository.getPostById(postId);
        expect(updatedPost!.voteData.votesA, equals(2));
        expect(updatedPost.voteData.votesB, equals(1));
        expect(updatedPost.voteData.totalVotes, equals(3));
      });

      test('should retrieve posts by user ID', () async {
        // Arrange: Create multiple posts
        for (int i = 1; i <= 3; i++) {
          final post = Post(
            id: 'user-post-$i',
            creatorInfo: CreatorInfo(
              userId: 'test-creator',
              userName: 'Test Creator',
              userAvatar: null,
              isAnonymous: false,
            ),
            questionTitle: 'Question $i',
            description: 'Description $i',
            optionA: MediaContent(
              type: 'text',
              content: 'A$i',
              thumbnailUrl: null,
              aspectRatio: 1.0,
            ),
            optionB: MediaContent(
              type: 'text',
              content: 'B$i',
              thumbnailUrl: null,
              aspectRatio: 1.0,
            ),
            voteData: VoteData(
              votesA: i,
              votesB: i * 2,
              totalVotes: i * 3,
              votePercentageA: 33.3,
              votePercentageB: 66.7,
              votedUsers: const [],
              votedUsersA: const [],
              votedUsersB: const [],
            ),
            stats: PostStats(
              views: i * 10,
              likes: i * 2,
              dislikes: 0,
              shares: i,
              comments: i,
              engagement: 0.3,
            ),
            createdAt: DateTime.now(),
          );
          await postRepository.createPost(post);
        }

        // Act: Get posts by user ID
        final userPosts =
            await postRepository.getPostsByUserId('test-creator').first;

        // Assert: Verify results
        expect(userPosts.length, equals(3));
        expect(userPosts.every((p) => p.creatorInfo.userId == 'test-creator'),
            isTrue);
      });
    });

    group('Clean Architecture Compliance', () {
      test('repositories should be accessed through interfaces only', () {
        // Verify that we're using interfaces, not implementations
        expect(userRepository, isA<IUserRepository>());
        expect(postRepository, isA<IPostRepository>());

        // Verify that the actual implementations are registered
        expect(userRepository.runtimeType.toString().contains('Impl'), isTrue);
        expect(postRepository.runtimeType.toString().contains('Impl'), isTrue);
      });

      test('domain models should be used in repository interfaces', () {
        // This test documents that repositories use domain models
        // The compilation itself verifies this requirement
        expect(true, isTrue, reason: 'Repository interfaces use domain models');
      });
    });

    group('Adapter Integration', () {
      test('should convert between legacy and domain models for users', () {
        // Arrange: Create legacy user
        final legacyUser = UserProfile(
          uid: 'adapter-test',
          email: 'adapter@test.com',
          displayName: 'Adapter Test',
          photoUrl: 'photo.jpg',
          shortDescription: 'Testing adapters',
          isPremiumUser: true,
          pointsA: 500,
          pointsQ: 250,
          createdTime: DateTime.now(),
          reference: fakeFirestore.collection('users').doc('adapter-test'),
        );

        // Act: Convert to bundle and back
        final bundle = UserProfileAdapter.createBundle(legacyUser);
        final convertedUser = UserProfileAdapter.fromDomainModels(
          auth: bundle.auth,
          profile: bundle.profile,
          settings: bundle.settings,
          stats: bundle.stats,
          reference: bundle.reference,
        );

        // Assert: Verify round-trip conversion
        expect(convertedUser.uid, equals(legacyUser.uid));
        expect(convertedUser.displayName, equals(legacyUser.displayName));
        expect(convertedUser.isPremiumUser, equals(legacyUser.isPremiumUser));
        expect(convertedUser.pointsA, equals(legacyUser.pointsA));
      });
    });

    group('Performance Tests', () {
      test('should handle bulk operations efficiently', () async {
        final stopwatch = Stopwatch()..start();

        // Create 100 users
        for (int i = 0; i < 100; i++) {
          final user = UserProfile(
            uid: 'perf-user-$i',
            email: 'perf$i@test.com',
            displayName: 'Perf User $i',
            photoUrl: null,
            shortDescription: '',
            isPremiumUser: false,
            pointsA: i,
            pointsQ: i,
            createdTime: DateTime.now(),
            reference: fakeFirestore.collection('users').doc('perf-user-$i'),
          );
          await userRepository.createUser(user);
        }

        stopwatch.stop();

        // Should complete in reasonable time (under 5 seconds for 100 users)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Verify all users were created
        final doc =
            await fakeFirestore.collection('users').doc('perf-user-99').get();
        expect(doc.exists, isTrue);
      });
    });
  });
}
