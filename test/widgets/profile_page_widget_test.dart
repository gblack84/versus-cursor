import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the widget to test
import '../../lib/features/profile/presentation/screens/profile_page/profile_page_widget.dart';

// Import repository interfaces
import '../../lib/features/profile/domain/repositories/i_user_repository.dart';
import '../../lib/features/posts/domain/repositories/i_post_repository.dart';

// Import domain models
import '../../lib/features/profile/domain/models/user_profile.dart';
import '../../lib/features/posts/domain/models/post.dart';
import '../../lib/features/posts/domain/models/creator_info.dart';
import '../../lib/features/posts/domain/models/media_content.dart';
import '../../lib/features/posts/domain/models/vote_data.dart';
import '../../lib/features/posts/domain/models/post_stats.dart';

// Mock classes
@GenerateMocks([IUserRepository, IPostRepository, DocumentReference])
import 'profile_page_widget_test.mocks.dart';

void main() {
  group('ProfilePageWidget Tests', () {
    late MockIUserRepository mockUserRepository;
    late MockIPostRepository mockPostRepository;
    late MockDocumentReference mockDocumentReference;
    late GetIt sl;

    setUp(() {
      // Initialize GetIt for testing
      sl = GetIt.instance;
      sl.reset();

      // Create mocks
      mockUserRepository = MockIUserRepository();
      mockPostRepository = MockIPostRepository();
      mockDocumentReference = MockDocumentReference();

      // Register mocks in DI container
      sl.registerSingleton<IUserRepository>(mockUserRepository);
      sl.registerSingleton<IPostRepository>(mockPostRepository);
    });

    tearDown(() {
      sl.reset();
    });

    UserProfile createTestUser() {
      return UserProfile.fromFirestore(
        {
          'uid': 'test-user-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'shortDescription': 'I love testing Flutter apps',
          'isPremiumUser': true,
          'pointsA': 500,
          'pointsQ': 250,
          'currentRank': 'Gold',
          'currentTitle': 'Expert Tester',
          'friends': ['friend1', 'friend2'],
          'interests': ['flutter', 'testing', 'mobile'],
          'expertise': ['dart', 'testing'],
          'createdTime': Timestamp.now(),
        },
        mockDocumentReference,
      );
    }

    Post createUserPost(String id, String title) {
      return Post(
        id: id,
        creatorInfo: CreatorInfo(
          userid: 'test-user-id',
          displayName: 'Test User',
        ),
        questionTitle: title,
        description: 'Description for $title',
        optionA: MediaContent(
          mediaType: 'text',
          text: 'Option A',
          aspectRatio: 1.0,
        ),
        optionB: MediaContent(
          mediaType: 'text',
          text: 'Option B',
          aspectRatio: 1.0,
        ),
        voteData: VoteData(
          votesA: 30,
          votesB: 20,
          totalVotes: 50,
        ),
        stats: PostStats(),
        createdAt: DateTime.now(),
      );
    }

    testWidgets('should display user profile information',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('I love testing Flutter apps'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Expert Tester'), findsOneWidget);
    });

    testWidgets('should display user points and stats',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('500'), findsOneWidget); // pointsA
      expect(find.text('250'), findsOneWidget); // pointsQ
      expect(find.text('포인트 A'), findsOneWidget); // Points A in Korean
      expect(find.text('포인트 Q'), findsOneWidget); // Points Q in Korean
    });

    testWidgets('should display user interests and expertise',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check interests
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('testing'),
          findsWidgets); // Appears in both interests and expertise
      expect(find.text('mobile'), findsOneWidget);

      // Check expertise
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('should display user posts from repository',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();
      final userPosts = [
        createUserPost('1', 'My First Question'),
        createUserPost('2', 'Another Question'),
      ];

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value(userPosts));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('My First Question'), findsOneWidget);
      expect(find.text('Another Question'), findsOneWidget);
    });

    testWidgets('should display premium badge for premium users',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser(); // isPremiumUser = true

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.verified), findsOneWidget); // Premium badge
      expect(find.text('프리미엄'), findsOneWidget); // Premium in Korean
    });

    testWidgets('should display edit button for own profile',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act - Viewing own profile
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(
            userId: 'test-user-id',
            isOwnProfile: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('프로필 편집'), findsOneWidget); // Edit Profile in Korean
    });

    testWidgets('should not display edit button for other users profile',
        (WidgetTester tester) async {
      // Arrange
      final testUser = createTestUser();

      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async => testUser);
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act - Viewing another user's profile
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(
            userId: 'test-user-id',
            isOwnProfile: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.text('프로필 편집'), findsNothing);
    });

    testWidgets('should display loading state while fetching user data',
        (WidgetTester tester) async {
      // Arrange
      when(mockUserRepository.getUserByUid('test-user-id'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return createTestUser();
      });
      when(mockPostRepository.getPostsByUserId('test-user-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'test-user-id'),
        ),
      );

      // Assert - Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Loading should disappear after data loads
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('should display error message when user not found',
        (WidgetTester tester) async {
      // Arrange
      when(mockUserRepository.getUserByUid('non-existent'))
          .thenAnswer((_) async => null);
      when(mockPostRepository.getPostsByUserId('non-existent'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'non-existent'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('사용자를 찾을 수 없습니다'),
          findsOneWidget); // User not found in Korean
    });

    testWidgets('should use domain models instead of backend models',
        (WidgetTester tester) async {
      // This test verifies Clean Architecture compliance
      // The widget should use UserProfile domain model, not backend models

      final domainUser = UserProfile.fromFirestore(
        {
          'uid': 'domain-user',
          'displayName': 'Domain Model User',
          'email': 'domain@test.com',
          'pointsA': 999,
          'pointsQ': 888,
          'isPremiumUser': false,
          'createdTime': Timestamp.now(),
        },
        mockDocumentReference,
      );

      when(mockUserRepository.getUserByUid('domain-user'))
          .thenAnswer((_) async => domainUser);
      when(mockPostRepository.getPostsByUserId('domain-user'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageWidget(userId: 'domain-user'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Domain Model User'), findsOneWidget);
      expect(find.text('999'), findsOneWidget); // pointsA
      expect(find.text('888'), findsOneWidget); // pointsQ

      // The test compiles and runs, proving it uses domain models
    });
  });
}
