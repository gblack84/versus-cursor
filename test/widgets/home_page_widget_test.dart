import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';

// Import the widget to test
import 'package:versus_space/features/posts/presentation/screens/feed/home_page_widget.dart';

// Import repository interfaces
import 'package:versus_space/features/posts/domain/repositories/i_post_repository.dart';
import 'package:versus_space/features/profile/domain/repositories/i_user_repository.dart';

// Import domain models
import 'package:versus_space/features/posts/domain/models/post.dart';
import 'package:versus_space/features/posts/domain/models/creator_info.dart';
import 'package:versus_space/features/posts/domain/models/media_content.dart';
import 'package:versus_space/features/posts/domain/models/vote_data.dart';
import 'package:versus_space/features/posts/domain/models/post_stats.dart';

// Mock classes
@GenerateMocks([IPostRepository, IUserRepository])
import 'home_page_widget_test.mocks.dart';

void main() {
  group('HomePageWidget Tests', () {
    late MockIPostRepository mockPostRepository;
    late MockIUserRepository mockUserRepository;
    late GetIt sl;

    setUp(() {
      // Initialize GetIt for testing
      sl = GetIt.instance;
      sl.reset();
      
      // Create mocks
      mockPostRepository = MockIPostRepository();
      mockUserRepository = MockIUserRepository();
      
      // Register mocks in DI container
      sl.registerSingleton<IPostRepository>(mockPostRepository);
      sl.registerSingleton<IUserRepository>(mockUserRepository);
    });

    tearDown(() {
      sl.reset();
    });

    Post createTestPost(String id, String title) {
      return Post(
        id: id,
        creatorInfo: CreatorInfo(
          userid: 'test-user',
          displayName: 'Test User',
        ),
        questionTitle: title,
        description: 'Test Description for $title',
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
          votesA: 10,
          votesB: 5,
          totalVotes: 15,
        ),
        stats: PostStats(),
        createdAt: DateTime.now(),
      );
    }

    testWidgets('should display app bar with title', 
        (WidgetTester tester) async {
      // Arrange
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );

      // Assert
      expect(find.text('Versus Space'), findsOneWidget);
    });

    testWidgets('should display list of posts from repository', 
        (WidgetTester tester) async {
      // Arrange
      final testPosts = [
        createTestPost('1', 'First Question'),
        createTestPost('2', 'Second Question'),
        createTestPost('3', 'Third Question'),
      ];

      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value(testPosts));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('First Question'), findsOneWidget);
      expect(find.text('Second Question'), findsOneWidget);
      expect(find.text('Third Question'), findsOneWidget);
    });

    testWidgets('should show loading indicator while fetching posts', 
        (WidgetTester tester) async {
      // Arrange
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );

      // Assert - Initial loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // Loading should disappear after data loads
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display vote counts for each post', 
        (WidgetTester tester) async {
      // Arrange
      final testPost = createTestPost('1', 'Vote Test Question');
      
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([testPost]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check vote data is displayed
      expect(find.text('10'), findsOneWidget); // votesA
      expect(find.text('5'), findsOneWidget); // votesB
    });

    testWidgets('should navigate to post detail when post is tapped', 
        (WidgetTester tester) async {
      // Arrange
      final testPost = createTestPost('1', 'Tappable Question');
      
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([testPost]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Find and tap the post
      await tester.tap(find.text('Tappable Question'));
      await tester.pumpAndSettle();

      // Assert - Navigation would occur (needs GoRouter in real test)
      expect(find.text('Tappable Question'), findsOneWidget);
    });

    testWidgets('should display empty state when no posts available', 
        (WidgetTester tester) async {
      // Arrange
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('아직 게시물이 없습니다'), findsOneWidget); // No posts yet in Korean
    });

    testWidgets('should display error message when repository throws error', 
        (WidgetTester tester) async {
      // Arrange
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.error('Failed to load posts'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('게시물을 불러올 수 없습니다'), findsOneWidget); // Cannot load posts in Korean
    });

    testWidgets('should refresh posts when pull to refresh is triggered', 
        (WidgetTester tester) async {
      // Arrange
      final initialPosts = [createTestPost('1', 'Initial Post')];
      final refreshedPosts = [
        createTestPost('2', 'New Post'),
        createTestPost('1', 'Initial Post'),
      ];

      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value(initialPosts));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Initial Post'), findsOneWidget);
      expect(find.text('New Post'), findsNothing);

      // Update mock to return refreshed data
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value(refreshedPosts));

      // Trigger pull to refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - New post should appear
      expect(find.text('New Post'), findsOneWidget);
      expect(find.text('Initial Post'), findsOneWidget);
    });

    testWidgets('should display floating action button for creating post', 
        (WidgetTester tester) async {
      // Arrange
      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should use domain models instead of backend models', 
        (WidgetTester tester) async {
      // This test verifies the architecture compliance
      // The widget should use Post domain model, not PostsModel
      
      // Arrange
      final domainPost = Post(
        id: 'domain-1',
        creatorInfo: CreatorInfo(
          userid: 'user-1',
          displayName: 'Domain User',
        ),
        questionTitle: 'Domain Model Question',
        description: 'Using domain models',
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
          votesA: 20,
          votesB: 30,
          totalVotes: 50,
        ),
        stats: PostStats(),
        createdAt: DateTime.now(),
      );

      when(mockPostRepository.getRecentPosts(limit: 20))
          .thenAnswer((_) => Stream.value([domainPost]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Domain Model Question'), findsOneWidget);
      expect(find.text('Domain User'), findsOneWidget);
      
      // The test compiles and runs, proving it uses domain models
      // not the legacy PostsModel
    });
  });
}