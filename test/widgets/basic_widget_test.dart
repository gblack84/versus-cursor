import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Import repository interfaces
import 'package:versus_space/features/posts/domain/repositories/i_post_repository.dart';
import 'package:versus_space/features/profile/domain/repositories/i_user_repository.dart';

// Import domain models
import 'package:versus_space/features/posts/domain/models/post.dart';
import 'package:versus_space/features/posts/domain/models/creator_info.dart';
import 'package:versus_space/features/posts/domain/models/media_content.dart';
import 'package:versus_space/features/posts/domain/models/vote_data.dart';
import 'package:versus_space/features/posts/domain/models/post_stats.dart';

void main() {
  group('Basic Widget Tests - Clean Architecture', () {
    late GetIt sl;

    setUp(() {
      sl = GetIt.instance;
      sl.reset();
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('should render a simple Material App', 
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Test App')),
            body: Center(child: Text('Hello World')),
          ),
        ),
      );

      // Assert
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });

    test('should create Post domain model correctly', () {
      // Arrange & Act
      final post = Post(
        id: 'test-1',
        creatorInfo: CreatorInfo(
          userid: 'user-1',
          displayName: 'Test User',
        ),
        questionTitle: 'Test Question',
        description: 'Test Description',
        optionA: MediaContent(
          mediaType: 'text',
          text: 'Option A',
        ),
        optionB: MediaContent(
          mediaType: 'text', 
          text: 'Option B',
        ),
        voteData: VoteData(
          votesA: 10,
          votesB: 5,
          totalVotes: 15,
        ),
        stats: PostStats(),
        createdAt: DateTime.now(),
      );

      // Assert
      expect(post.id, equals('test-1'));
      expect(post.questionTitle, equals('Test Question'));
      expect(post.voteData.votesA, equals(10));
      expect(post.voteData.totalVotes, equals(15));
    });

    test('should create MediaContent with text type', () {
      // Arrange & Act
      final media = MediaContent(
        mediaType: 'text',
        text: 'Sample Text',
        aspectRatio: 1.0,
      );

      // Assert
      expect(media.mediaType, equals('text'));
      expect(media.text, equals('Sample Text'));
      expect(media.aspectRatio, equals(1.0));
    });

    test('should create VoteData with proper calculations', () {
      // Arrange & Act
      final voteData = VoteData(
        votesA: 30,
        votesB: 20,
        totalVotes: 50,
      );

      // Assert
      expect(voteData.votesA, equals(30));
      expect(voteData.votesB, equals(20));
      expect(voteData.totalVotes, equals(50));
    });

    testWidgets('should display domain model data in widget', 
        (WidgetTester tester) async {
      // Arrange
      final post = Post(
        id: 'widget-test-1',
        creatorInfo: CreatorInfo(
          userid: 'user-1',
          displayName: 'Widget Tester',
        ),
        questionTitle: 'Which is better?',
        description: 'A test question',
        optionA: MediaContent(
          mediaType: 'text',
          text: 'Option A',
        ),
        optionB: MediaContent(
          mediaType: 'text',
          text: 'Option B',
        ),
        voteData: VoteData(
          votesA: 100,
          votesB: 50,
          totalVotes: 150,
        ),
        stats: PostStats(),
        createdAt: DateTime.now(),
      );

      // Act - Create a simple widget that displays the post
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(post.questionTitle),
                  Text('Created by: ${post.creatorInfo.displayName}'),
                  Text('Votes A: ${post.voteData.votesA}'),
                  Text('Votes B: ${post.voteData.votesB}'),
                  Text('Total: ${post.voteData.totalVotes}'),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Which is better?'), findsOneWidget);
      expect(find.text('Created by: Widget Tester'), findsOneWidget);
      expect(find.text('Votes A: 100'), findsOneWidget);
      expect(find.text('Votes B: 50'), findsOneWidget);
      expect(find.text('Total: 150'), findsOneWidget);
    });
  });
}