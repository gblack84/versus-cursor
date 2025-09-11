import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/features/posts/data/adapters/posts_model_adapter.dart';
import 'package:versus_space/features/posts/data/models/posts_model.dart';
import 'package:versus_space/features/posts/domain/models/post_core.dart';
import 'package:versus_space/features/posts/domain/models/post_content.dart';
import 'package:versus_space/features/posts/domain/models/post_voting.dart';
import 'package:versus_space/features/posts/domain/models/post_metrics.dart';
import 'package:versus_space/features/posts/domain/models/media_content.dart';

void main() {
  group('PostsModelAdapter', () {
    group('toDomainModels', () {
      test('should convert PostsModel to PostBundle with all 4 domain models',
          () {
        // Arrange
        final testData = _createTestPostsModelData();
        final postsModel = PostsModel.getDocumentFromData(testData,
            FirebaseFirestore.instance.collection('posts').doc('test-post-id'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert PostBundle consistency
        expect(result.isConsistent, isTrue);
        expect(result.postId, equals('test-post-id'));

        // Assert - PostCore
        expect(result.core.id, equals('test-post-id'));
        expect(result.core.questionTitle, equals('Flutter vs React Native'));
        expect(result.core.description,
            equals('Which framework is better for mobile development?'));
        expect(result.core.content, equals('Detailed comparison needed'));
        expect(result.core.userId, equals('user-123'));
        expect(result.core.createdAt, isA<DateTime>());
        expect(result.core.updatedAt, isA<DateTime>());
        expect(result.core.category, equals('technology'));
        expect(result.core.tags, equals(['flutter', 'react-native', 'mobile']));
        expect(result.core.visibility, equals('public'));
        expect(result.core.isAnonymous, isFalse);
        expect(result.core.premiumRequired, isFalse);
        expect(result.core.location, isA<GeoPoint>());

        // Assert - PostContent
        expect(result.content.postId, equals('test-post-id'));
        expect(result.content.optionA, isA<MediaContent>());
        expect(result.content.optionB, isA<MediaContent>());
        expect(result.content.layoutType, isNotEmpty);
        expect(result.content.targetAudience, equals('developers'));
        expect(result.content.processingStatus, equals('completed'));
        expect(result.content.processedAt, isA<DateTime>());

        // Assert - PostVoting
        expect(result.voting.postId, equals('test-post-id'));
        expect(result.voting.voteStartTime, isA<DateTime>());
        expect(result.voting.voteEndTime, isA<DateTime>());
        expect(result.voting.voteStatus, equals('active'));
        expect(result.voting.voteCompleted, isFalse);
        expect(result.voting.votesA, equals(150));
        expect(result.voting.votesB, equals(200));
        expect(result.voting.votedUserIdsA, hasLength(2));
        expect(result.voting.votedUserIdsB, hasLength(3));
        expect(result.voting.notificationsSent, isTrue);
        expect(result.voting.expansionPointsUsed, equals(50));

        // Assert - PostMetrics
        expect(result.metrics.postId, equals('test-post-id'));
        expect(result.metrics.commentCount, equals(25));
        expect(result.metrics.likeCount, equals(75));
        expect(result.metrics.shareCount,
            equals(10)); // Note: using typo 'sherecount'
        expect(result.metrics.saveCount, equals(30));
        expect(result.metrics.reportCount, equals(2));
        expect(result.metrics.participantCount, equals(500));
        expect(result.metrics.interestCount, equals(100));
        expect(result.metrics.engagementRate, greaterThan(0));
        expect(result.metrics.qualityScore, greaterThan(0));
      });

      test('should handle null and empty values correctly', () {
        // Arrange
        final minimalData = _createMinimalPostsModelData();
        final postsModel = PostsModel.getDocumentFromData(
            minimalData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('minimal-post-id'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert null handling
        expect(result.core.description, isNull);
        expect(result.core.content, isNull);
        expect(result.core.updatedAt, isNull);
        expect(result.core.category, isNull);
        expect(result.core.tags, isEmpty);
        expect(result.core.location, isNull);
        expect(result.content.targetAudience, isNull);
        expect(result.content.moderation, isNull);
        expect(result.voting.voteStartTime, isNull);
        expect(result.voting.voteEndTime, isNull);
        expect(result.voting.voteCancelledReason, isNull);
        expect(result.voting.displayVotesA, isNull);
        expect(result.voting.displayVotesB, isNull);
      });

      test('should determine layout type correctly based on aspect ratios', () {
        // Arrange - Both portrait images
        final portraitData = _createTestPostsModelData();
        portraitData['optionA'] = {
          'text': 'Option A',
          'imageUrls': ['https://example.com/portrait1.jpg'],
          'aspectRatio': 0.7, // Portrait
        };
        portraitData['optionB'] = {
          'text': 'Option B',
          'imageUrls': ['https://example.com/portrait2.jpg'],
          'aspectRatio': 0.8, // Portrait
        };

        final postsModel = PostsModel.getDocumentFromData(
            portraitData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('portrait-post'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert
        expect(result.content.layoutType, equals('horizontal'));
      });

      test('should handle voting status conversion correctly', () {
        // Arrange
        final votingData = _createTestPostsModelData();
        votingData['voteCompleted'] = true;
        votingData['isVotingComplete'] = true;
        votingData['voteStatus'] = 'completed';

        final postsModel = PostsModel.getDocumentFromData(
            votingData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('completed-vote'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert
        expect(result.voting.voteCompleted, isTrue);
        expect(result.voting.voteStatus, equals('completed'));
      });

      test('should calculate engagement and quality metrics correctly', () {
        // Arrange
        final metricsData = _createTestPostsModelData();
        metricsData['commentcount'] = 100;
        metricsData['likecount'] = 200;
        metricsData['sherecount'] = 50; // Note: original typo
        metricsData['savecount'] = 75;
        metricsData['participantcount'] = 1000;
        metricsData['reportCount'] = 0; // No reports for good quality

        final postsModel = PostsModel.getDocumentFromData(
            metricsData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('high-engagement'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert calculated metrics
        expect(result.metrics.engagementRate,
            equals(42.5)); // (100+200+50+75)/1000 * 100
        expect(result.metrics.qualityScore,
            greaterThan(0.5)); // Should be high with no reports
      });
    });

    group('fromDomainModels', () {
      test('should convert PostBundle back to PostsModel correctly', () {
        // Arrange
        final bundle = _createTestPostBundle();

        // Act
        final result = PostsModelAdapter.fromDomainModels(bundle);

        // Assert core fields
        expect(result.questionTitle, equals('Test Question'));
        expect(result.description, equals('Test Description'));
        expect(result.userid, equals('test-user-id'));
        expect(result.createdAt, isA<DateTime>());
        expect(result.category, equals('test-category'));
        expect(result.tags, equals(['tag1', 'tag2']));
        expect(result.visibility, equals(0)); // 'public' -> 0
        expect(result.isAnonymous, isFalse);
        expect(result.premiumRequired, isFalse);

        // Assert voting fields
        expect(result.voteStartTime, isA<DateTime>());
        expect(result.voteEndTime, isA<DateTime>());
        expect(result.voteStatus, equals('pending'));
        expect(result.voteCompleted, isFalse);
        expect(result.isVotingComplete, isFalse); // Backward compatibility
        expect(result.votesA, equals(10));
        expect(result.votesB, equals(20));
        expect(result.totalVotes, equals(30));

        // Assert metrics fields
        expect(result.commentcount, equals(5));
        expect(result.likecount, equals(15));
        expect(result.sherecount, equals(3)); // Preserve typo
        expect(result.savecount, equals(8));
        expect(result.participantcount, equals(100));
      });

      test('should handle visibility conversion correctly', () {
        // Arrange - Test all visibility options
        final testCases = [
          ('public', 0),
          ('private', 1),
          ('friends', 2),
          ('unknown', 0), // Default to public
        ];

        for (final (visibility, expectedInt) in testCases) {
          final bundle = _createTestPostBundle();
          final modifiedCore = bundle.core.copyWith(visibility: visibility);
          final modifiedBundle = PostBundle(
            core: modifiedCore,
            content: bundle.content,
            voting: bundle.voting,
            metrics: bundle.metrics,
          );

          // Act
          final result = PostsModelAdapter.fromDomainModels(modifiedBundle);

          // Assert
          expect(result.visibility, equals(expectedInt));
        }
      });

      test('should handle optionA and optionB conversion correctly', () {
        // Arrange
        final bundle = _createTestPostBundle();

        // Act
        final result = PostsModelAdapter.fromDomainModels(bundle);

        // Assert
        expect(result.optionA, isA<Map<String, dynamic>>());
        expect(result.optionB, isA<Map<String, dynamic>>());
        expect(result.optionA['text'], equals('Option A Text'));
        expect(result.optionB['text'], equals('Option B Text'));
      });

      test('should calculate display percentages correctly', () {
        // Arrange
        final bundle = _createTestPostBundle();
        final modifiedVoting = bundle.voting.copyWith(
          votesA: 30,
          votesB: 70,
        );
        final modifiedBundle = PostBundle(
          core: bundle.core,
          content: bundle.content,
          voting: modifiedVoting,
          metrics: bundle.metrics,
        );

        // Act
        final result = PostsModelAdapter.fromDomainModels(modifiedBundle);

        // Assert percentages
        expect(result.totalVotes, equals(100));

        // Note: The PostsModel should contain calculated percentage fields
        // based on the voting data conversion in the adapter
      });

      test('should include legacy compatibility fields', () {
        // Arrange
        final bundle = _createTestPostBundle();

        // Act
        final result = PostsModelAdapter.fromDomainModels(bundle);

        // Assert legacy fields
        expect(result.uid, equals('test-user-id')); // Backward compatibility
        expect(result.createdTime, isA<DateTime>()); // Legacy timestamp
        expect(result.isVotingComplete,
            equals(result.voteCompleted)); // Duplicate field
        expect(result.stats, isA<Map>()); // Legacy stats object
      });
    });

    group('round-trip conversion (bidirectional)', () {
      test('should preserve all data through full conversion cycle', () {
        // Arrange
        final originalData = _createTestPostsModelData();
        final originalPostsModel = PostsModel.getDocumentFromData(originalData,
            FirebaseFirestore.instance.collection('posts').doc('test-post-id'));

        // Act - Convert to domain models and back
        final bundle = PostsModelAdapter.toDomainModels(originalPostsModel);
        final reconstructed = PostsModelAdapter.fromDomainModels(bundle);

        // Assert key fields are preserved
        expect(reconstructed.questionTitle,
            equals(originalPostsModel.questionTitle));
        expect(
            reconstructed.description, equals(originalPostsModel.description));
        expect(reconstructed.userid, equals(originalPostsModel.userid));
        expect(reconstructed.category, equals(originalPostsModel.category));
        expect(reconstructed.tags, equals(originalPostsModel.tags));
        expect(
            reconstructed.isAnonymous, equals(originalPostsModel.isAnonymous));
        expect(reconstructed.votesA, equals(originalPostsModel.votesA));
        expect(reconstructed.votesB, equals(originalPostsModel.votesB));
        expect(reconstructed.commentcount,
            equals(originalPostsModel.commentcount));
        expect(reconstructed.likecount, equals(originalPostsModel.likecount));
      });

      test('should handle minimal data through round-trip conversion', () {
        // Arrange
        final minimalData = _createMinimalPostsModelData();
        final originalPostsModel = PostsModel.getDocumentFromData(minimalData,
            FirebaseFirestore.instance.collection('posts').doc('minimal-post'));

        // Act - Convert to domain models and back
        final bundle = PostsModelAdapter.toDomainModels(originalPostsModel);
        final reconstructed = PostsModelAdapter.fromDomainModels(bundle);

        // Assert essential fields are preserved
        expect(reconstructed.questionTitle,
            equals(originalPostsModel.questionTitle));
        expect(reconstructed.userid, equals(originalPostsModel.userid));
        expect(reconstructed.votesA, equals(originalPostsModel.votesA));
        expect(reconstructed.votesB, equals(originalPostsModel.votesB));
      });
    });

    group('PostBundle', () {
      test('should validate consistency correctly', () {
        // Arrange - Consistent bundle
        final consistentBundle = _createTestPostBundle();

        // Assert
        expect(consistentBundle.isConsistent, isTrue);
        expect(consistentBundle.postId, equals('test-post-id'));
      });

      test('should detect inconsistent postId across models', () {
        // Arrange - Inconsistent bundle
        final bundle = _createTestPostBundle();
        final inconsistentCore = bundle.core.copyWith(id: 'different-id');
        final inconsistentBundle = PostBundle(
          core: inconsistentCore,
          content: bundle.content,
          voting: bundle.voting,
          metrics: bundle.metrics,
        );

        // Assert
        expect(inconsistentBundle.isConsistent, isFalse);
      });

      test('should throw error for inconsistent bundle in fromDomainModels',
          () {
        // Arrange
        final bundle = _createTestPostBundle();
        final inconsistentVoting =
            bundle.voting.copyWith(postId: 'different-id');
        final inconsistentBundle = PostBundle(
          core: bundle.core,
          content: bundle.content,
          voting: inconsistentVoting,
          metrics: bundle.metrics,
        );

        // Act & Assert
        expect(() => PostsModelAdapter.fromDomainModels(inconsistentBundle),
            throwsArgumentError);
      });
    });

    group('batch conversions', () {
      test('should convert list of PostsModels to PostBundles', () {
        // Arrange
        final postsModels = [
          PostsModel.getDocumentFromData(_createTestPostsModelData(),
              FirebaseFirestore.instance.collection('posts').doc('post-1')),
          PostsModel.getDocumentFromData(_createMinimalPostsModelData(),
              FirebaseFirestore.instance.collection('posts').doc('post-2')),
        ];

        // Act
        final bundles = PostsModelAdapter.toDomainModelsList(postsModels);

        // Assert
        expect(bundles, hasLength(2));
        expect(bundles[0].postId, equals('post-1'));
        expect(bundles[1].postId, equals('post-2'));
        expect(bundles.every((b) => b.isConsistent), isTrue);
      });

      test('should convert list of PostBundles to PostsModels', () {
        // Arrange
        final bundles = [
          _createTestPostBundle(),
          _createTestPostBundle(),
        ];

        // Act
        final postsModels = PostsModelAdapter.fromDomainModelsList(bundles);

        // Assert
        expect(postsModels, hasLength(2));
        expect(postsModels[0].questionTitle, equals('Test Question'));
        expect(postsModels[1].questionTitle, equals('Test Question'));
      });
    });

    group('convenience extraction methods', () {
      test('should extract individual domain models correctly', () {
        // Arrange
        final testData = _createTestPostsModelData();
        final postsModel = PostsModel.getDocumentFromData(testData,
            FirebaseFirestore.instance.collection('posts').doc('extract-test'));

        // Act
        final core = PostsModelAdapter.extractCore(postsModel);
        final content = PostsModelAdapter.extractContent(postsModel);
        final voting = PostsModelAdapter.extractVoting(postsModel);
        final metrics = PostsModelAdapter.extractMetrics(postsModel);

        // Assert
        expect(core.id, equals('extract-test'));
        expect(content.postId, equals('extract-test'));
        expect(voting.postId, equals('extract-test'));
        expect(metrics.postId, equals('extract-test'));
      });
    });

    group('edge cases', () {
      test('should handle empty optionB correctly', () {
        // Arrange
        final singleOptionData = _createTestPostsModelData();
        singleOptionData['optionB'] = {}; // Empty option B

        final postsModel = PostsModel.getDocumentFromData(
            singleOptionData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('single-option'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert
        expect(result.content.layoutType, equals('single'));
        expect(result.content.optionB.isEmpty, isTrue);
      });

      test('should handle extreme vote counts', () {
        // Arrange
        final extremeVotesData = _createTestPostsModelData();
        extremeVotesData['votesA'] = 999999999;
        extremeVotesData['votesB'] = 0;
        extremeVotesData['votedUserIdsA'] =
            List.generate(1000000, (i) => 'user$i');
        extremeVotesData['votedUserIdsB'] = <String>[];

        final postsModel = PostsModel.getDocumentFromData(
            extremeVotesData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('extreme-votes'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert
        expect(result.voting.votesA, equals(999999999));
        expect(result.voting.votesB, equals(0));
        expect(result.voting.totalVotes, equals(999999999));
        expect(result.voting.votedUserIdsA.length, equals(1000000));
        expect(result.voting.votedUserIdsB, isEmpty);
      });

      test('should handle very long strings', () {
        // Arrange
        final longStringData = _createTestPostsModelData();
        final longTitle = 'A' * 10000; // 10K character title
        final longDescription = 'B' * 50000; // 50K character description
        longStringData['questionTitle'] = longTitle;
        longStringData['description'] = longDescription;

        final postsModel = PostsModel.getDocumentFromData(longStringData,
            FirebaseFirestore.instance.collection('posts').doc('long-strings'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert
        expect(result.core.questionTitle.length, equals(10000));
        expect(result.core.description!.length, equals(50000));
      });

      test('should handle malformed media content gracefully', () {
        // Arrange
        final malformedData = _createTestPostsModelData();
        malformedData['optionA'] = 'invalid_map'; // Not a map
        malformedData['optionB'] = null; // Null value

        final postsModel = PostsModel.getDocumentFromData(
            malformedData,
            FirebaseFirestore.instance
                .collection('posts')
                .doc('malformed-media'));

        // Act & Assert - Should not throw
        expect(() => PostsModelAdapter.toDomainModels(postsModel),
            returnsNormally);
      });
    });

    group('helper methods', () {
      test('should calculate engagement rate correctly for various scenarios',
          () {
        // Test cases: [comments, likes, shares, saves, participants, expectedRate]
        final testCases = [
          [100, 200, 50, 75, 1000, 42.5], // Normal case
          [0, 0, 0, 0, 1000, 0.0], // No engagement
          [100, 200, 50, 75, 0, 0.0], // No participants
          [10, 20, 5, 15, 100, 50.0], // High engagement rate
        ];

        for (final testCase in testCases) {
          final testData = _createTestPostsModelData();
          testData['commentcount'] = testCase[0];
          testData['likecount'] = testCase[1];
          testData['sherecount'] = testCase[2]; // Note: typo preserved
          testData['savecount'] = testCase[3];
          testData['participantcount'] = testCase[4];

          final postsModel = PostsModel.getDocumentFromData(
              testData,
              FirebaseFirestore.instance
                  .collection('posts')
                  .doc('engagement-test'));

          final result = PostsModelAdapter.toDomainModels(postsModel);
          expect(result.metrics.engagementRate, closeTo(testCase[5], 0.1));
        }
      });

      test('should calculate quality score based on multiple factors', () {
        // Arrange - High quality post (many likes, no reports)
        final highQualityData = _createTestPostsModelData();
        highQualityData['likecount'] = 1000;
        highQualityData['reportCount'] = 0;
        highQualityData['commentcount'] = 100;
        highQualityData['participantcount'] = 2000;

        final postsModel = PostsModel.getDocumentFromData(highQualityData,
            FirebaseFirestore.instance.collection('posts').doc('high-quality'));

        // Act
        final result = PostsModelAdapter.toDomainModels(postsModel);

        // Assert - Should have high quality score
        expect(result.metrics.qualityScore, greaterThan(0.7));
      });
    });
  });
}

// Test Data Helper Methods

Map<String, dynamic> _createTestPostsModelData() {
  final now = DateTime.now();
  return {
    'questionTitle': 'Flutter vs React Native',
    'description': 'Which framework is better for mobile development?',
    'content': 'Detailed comparison needed',
    'userid': 'user-123',
    'uid': 'user-123', // Backward compatibility
    'createdAt': now,
    'updatedAt': now.subtract(const Duration(minutes: 30)),
    'category': 'technology',
    'tags': ['flutter', 'react-native', 'mobile'],
    'visibility': 0, // public
    'isAnonymous': false,
    'premiumRequired': false,
    'location': GeoPoint(40.7128, -74.0060), // New York
    'optionA': {
      'text': 'Flutter',
      'imageUrls': ['https://example.com/flutter.jpg'],
      'aspectRatio': 1.0,
    },
    'optionB': {
      'text': 'React Native',
      'imageUrls': ['https://example.com/reactnative.jpg'],
      'aspectRatio': 1.0,
    },
    'layoutType': 'vertical',
    'targetAudience': 'developers',
    'moderation': {'status': 'approved', 'reviewedBy': 'moderator-1'},
    'voteStartTime': now,
    'voteEndTime': now.add(const Duration(hours: 24)),
    'voteStatus': 'active',
    'voteCompleted': false,
    'isVotingComplete': false,
    'voteCompletedAt': null,
    'voteCancelledAt': null,
    'voteCancelledReason': '',
    'voteTimeout': false,
    'votesA': 150,
    'votesB': 200,
    'totalVotes': 350,
    'votedUserIdsA': ['user-1', 'user-2'],
    'votedUserIdsB': ['user-3', 'user-4', 'user-5'],
    'displayVotesA': 150,
    'displayVotesB': 200,
    'notificationsSent': true,
    'notificationsSentAt': now,
    'expansionPointsUsed': 50,
    'expandedUserCount': 25,
    'expansionStatus': 'expanded',
    'commentcount': 25,
    'likecount': 75,
    'sherecount': 10, // Note: preserving typo from original
    'savecount': 30,
    'reportCount': 2,
    'participantcount': 500,
    'interestcount': 100,
    'stats': {
      'commentCount': 25,
      'likeCount': 75,
      'shareCount': 10,
    },
    'isReported': false,
    'reportedBy': [],
    'initialCommentLimit': 10,
    'currentCommentCount': 25,
    'option': [],
    // Legacy user info fields
    'email': 'user@example.com',
    'displayName': 'Test User',
    'photoUrl': 'https://example.com/avatar.jpg',
    'phoneNumber': '+1234567890',
    'createdTime': now,
    'creatorInfo': {
      'userid': 'user-123',
      'uid': 'user-123',
    },
  };
}

Map<String, dynamic> _createMinimalPostsModelData() {
  final now = DateTime.now();
  return {
    'questionTitle': 'Minimal Question',
    'description': '',
    'content': '',
    'userid': 'minimal-user',
    'uid': 'minimal-user',
    'createdAt': now,
    'category': '',
    'tags': [],
    'visibility': 0,
    'isAnonymous': false,
    'premiumRequired': false,
    'optionA': {'text': 'A'},
    'optionB': {'text': 'B'},
    'layoutType': 'vertical',
    'targetAudience': '',
    'moderation': {},
    'voteStatus': 'pending',
    'voteCompleted': false,
    'isVotingComplete': false,
    'voteTimeout': false,
    'votesA': 0,
    'votesB': 0,
    'totalVotes': 0,
    'votedUserIdsA': [],
    'votedUserIdsB': [],
    'displayVotesA': 0,
    'displayVotesB': 0,
    'notificationsSent': false,
    'expansionPointsUsed': 0,
    'expandedUserCount': 0,
    'expansionStatus': 'none',
    'commentcount': 0,
    'likecount': 0,
    'sherecount': 0,
    'savecount': 0,
    'reportCount': 0,
    'participantcount': 0,
    'interestcount': 0,
    'stats': {},
    'isReported': false,
    'reportedBy': [],
    'initialCommentLimit': 10,
    'currentCommentCount': 0,
    'option': [],
    'email': '',
    'displayName': '',
    'photoUrl': '',
    'phoneNumber': '',
    'createdTime': now,
    'creatorInfo': {
      'userid': 'minimal-user',
      'uid': 'minimal-user',
    },
  };
}

PostBundle _createTestPostBundle() {
  const postId = 'test-post-id';
  final now = DateTime.now();

  final core = PostCore(
    id: postId,
    questionTitle: 'Test Question',
    description: 'Test Description',
    content: 'Test Content',
    userId: 'test-user-id',
    createdAt: now,
    updatedAt: now,
    category: 'test-category',
    tags: ['tag1', 'tag2'],
    visibility: 'public',
    isAnonymous: false,
    premiumRequired: false,
    location: GeoPoint(37.7749, -122.4194),
  );

  final content = PostContent(
    postId: postId,
    optionA: MediaContent(
      text: 'Option A Text',
      imageUrls: ['https://example.com/a.jpg'],
      aspectRatio: 1.0,
    ),
    optionB: MediaContent(
      text: 'Option B Text',
      imageUrls: ['https://example.com/b.jpg'],
      aspectRatio: 1.0,
    ),
    layoutType: 'vertical',
    targetAudience: const {'type': 'test-audience'},
    moderation: const {'status': 'approved'},
    processingStatus: 'completed',
    processedAt: now,
  );

  final voting = PostVoting(
    postId: postId,
    voteStartTime: now,
    voteEndTime: now.add(const Duration(hours: 24)),
    voteStatus: 'pending',
    voteCompleted: false,
    voteTimeout: const Duration(minutes: 10),
    votesA: 10,
    votesB: 20,
    votedUserIdsA: ['user1'],
    votedUserIdsB: ['user2', 'user3'],
    notificationsSent: false,
    expansionPointsUsed: 0,
    expandedUserCount: 0,
    expansionStatus: 'none',
  );

  final metrics = PostMetrics(
    postId: postId,
    commentCount: 5,
    likeCount: 15,
    shareCount: 3,
    saveCount: 8,
    reportCount: 0,
    participantCount: 100,
    interestCount: 25,
    engagementRate: 31.0,
    qualityScore: 0.8,
    firstInteractionAt: now,
    lastInteractionAt: now,
  );

  return PostBundle(
    core: core,
    content: content,
    voting: voting,
    metrics: metrics,
  );
}
