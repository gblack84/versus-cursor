import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:versus_space/features/profile/presentation/providers/profile_provider.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/get_current_user_profile_usecase.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/get_profile_completion_usecase.dart';
import 'package:versus_space/features/profile/domain/usecases/profile/watch_user_profile_usecase.dart';
import 'package:versus_space/features/profile/domain/models/user_profile.dart';
import 'package:versus_space/features/profile/domain/failures/profile_failures.dart';

import 'profile_provider_test.mocks.dart';

@GenerateMocks([
  GetUserProfileUseCase,
  GetCurrentUserProfileUseCase,
  UpdateUserProfileUseCase,
  UploadProfileImageUseCase,
  GetProfileCompletionUseCase,
  WatchUserProfileUseCase,
])
void main() {
  late ProfileProvider provider;
  late MockGetUserProfileUseCase mockGetProfileUseCase;
  late MockGetCurrentUserProfileUseCase mockGetCurrentProfileUseCase;
  late MockUpdateUserProfileUseCase mockUpdateProfileUseCase;
  late MockUploadProfileImageUseCase mockUploadImageUseCase;
  late MockGetProfileCompletionUseCase mockGetCompletionUseCase;
  late MockWatchUserProfileUseCase mockWatchProfileUseCase;

  setUp(() {
    mockGetProfileUseCase = MockGetUserProfileUseCase();
    mockGetCurrentProfileUseCase = MockGetCurrentUserProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateUserProfileUseCase();
    mockUploadImageUseCase = MockUploadProfileImageUseCase();
    mockGetCompletionUseCase = MockGetProfileCompletionUseCase();
    mockWatchProfileUseCase = MockWatchUserProfileUseCase();

    provider = ProfileProvider(
      getProfileUseCase: mockGetProfileUseCase,
      getCurrentProfileUseCase: mockGetCurrentProfileUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      uploadImageUseCase: mockUploadImageUseCase,
      getProfileCompletionUseCase: mockGetCompletionUseCase,
      watchProfileUseCase: mockWatchProfileUseCase,
    );
  });

  group('ProfileProvider - watchOtherUserProfile (Stream)', () {
    const testUserId = 'other_user_123';

    final testProfile = UserProfile(
      uid: testUserId,
      email: 'other@example.com',
      displayName: 'Other User',
      photoUrl: 'https://example.com/photo.jpg',
      shortDescription: 'Other user bio',
      createdTime: DateTime(2024, 1, 1),
      pointsA: 200,
      pointsQ: 100,
      interests: const ['music', 'art'],
      expertise: const ['design', 'ux'],
    );

    test('Provider의 watchOtherUserProfile은 UseCase Stream을 그대로 반환해야 함', () async {
      // Arrange
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.value(Right(testProfile)),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);

      // Assert - Stream이 UserProfile?를 emit하는지 확인
      await expectLater(
        stream,
        emits(testProfile),
      );
    });

    test('UseCase가 Left(ProfileNotFoundFailure)를 emit하면 null을 반환하고 errorMessage 설정', () async {
      // Arrange
      final failure = ProfileNotFoundFailure(userId: testUserId);
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.value(Left(failure)),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // Assert
      await expectLater(stream, emits(null));

      // notifyListeners()가 호출되어 에러 상태가 Provider 리스너들에게 전달되어야 함
      await Future.delayed(Duration(milliseconds: 50));
      expect(notifyCount, greaterThan(0), reason: 'Provider should notify listeners on error');
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, failure.getUserMessage());
    });

    test('UseCase가 Left(FirestoreReadFailure)를 emit하면 null을 반환하고 errorMessage 설정', () async {
      // Arrange
      final failure = FirestoreReadFailure(message: 'Network error');
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.value(Left(failure)),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // Assert
      await expectLater(stream, emits(null));

      await Future.delayed(Duration(milliseconds: 50));
      expect(notifyCount, greaterThan(0));
      // getUserMessage()는 한국어 사용자 메시지를 반환하므로 null이 아닌지만 확인
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('데이터'));
    });

    test('실시간 프로필 업데이트를 여러 번 emit해야 함', () async {
      // Arrange - 프로필 사진 변경 시나리오
      final profile1 = testProfile;
      final profile2 = testProfile.copyWith(
        photoUrl: 'https://example.com/new-photo.jpg',
      );
      final profile3 = testProfile.copyWith(
        photoUrl: 'https://example.com/final-photo.jpg',
        displayName: 'Updated Name',
      );

      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.fromIterable([
          Right(profile1),
          Right(profile2),
          Right(profile3),
        ]),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);

      // Assert - 3번의 업데이트가 모두 전달되어야 함
      await expectLater(
        stream,
        emitsInOrder([
          profile1,
          profile2,
          profile3,
        ]),
      );
    });

    test('프로필 삭제 시나리오: Right → Left(ProfileNotFoundFailure)', () async {
      // Arrange - 프로필이 있다가 삭제됨
      final failure = ProfileNotFoundFailure(userId: testUserId);
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.fromIterable([
          Right(testProfile),
          Left(failure),
        ]),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          testProfile,  // 처음엔 프로필 존재
          null,         // 삭제 후 null
        ]),
      );
    });

    test('에러 발생 시에도 errorMessage는 null로 초기화되어야 함 (Right 수신 시)', () async {
      // Arrange
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => Stream.value(Right(testProfile)),
      );

      // Act
      provider.watchOtherUserProfile(testUserId).listen((_) {});
      await Future.delayed(Duration(milliseconds: 50));

      // Assert
      expect(provider.errorMessage, isNull);
    });

    test('여러 번 watchOtherUserProfile 호출 시 독립적인 Stream 반환', () async {
      // Arrange
      const userId1 = 'user_1';
      const userId2 = 'user_2';

      final profile1 = testProfile.copyWith(uid: userId1);
      final profile2 = testProfile.copyWith(uid: userId2);

      when(mockWatchProfileUseCase.execute(userId: userId1)).thenAnswer(
        (_) => Stream.value(Right(profile1)),
      );
      when(mockWatchProfileUseCase.execute(userId: userId2)).thenAnswer(
        (_) => Stream.value(Right(profile2)),
      );

      // Act
      final stream1 = provider.watchOtherUserProfile(userId1);
      final stream2 = provider.watchOtherUserProfile(userId2);

      // Assert - 각 Stream이 독립적으로 작동해야 함
      await expectLater(stream1, emits(profile1));
      await expectLater(stream2, emits(profile2));
    });

    test('Stream 구독 취소 후에도 Provider는 정상 작동해야 함', () async {
      // Arrange
      final controller = StreamController<Either<ProfileFailure, UserProfile>>();
      when(mockWatchProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) => controller.stream,
      );

      // loadProfile() 호출을 위한 stub 추가
      when(mockGetProfileUseCase.execute(userId: testUserId)).thenAnswer(
        (_) async => Right(testProfile),
      );

      // Act
      final stream = provider.watchOtherUserProfile(testUserId);
      final subscription = stream.listen((_) {});

      controller.add(Right(testProfile));
      await Future.delayed(Duration(milliseconds: 10));

      await subscription.cancel();

      // Assert - Provider는 여전히 사용 가능해야 함
      expect(provider, isNotNull);
      expect(() => provider.loadProfile(testUserId), returnsNormally);

      await controller.close();
    });
  });

  group('ProfileProvider - Hybrid Pattern 검증', () {
    test('Provider 상태(Future 기반)와 Stream이 공존해야 함', () async {
      // Arrange
      const futureUserId = 'future_user';
      const streamUserId = 'stream_user';

      final futureProfile = UserProfile(
        uid: futureUserId,
        email: 'future@example.com',
        displayName: 'Future User',
        photoUrl: null,
        shortDescription: null,
        createdTime: DateTime(2024, 1, 1),
        pointsA: 0,
        pointsQ: 0,
        interests: const [],
        expertise: const [],
      );

      final streamProfile = futureProfile.copyWith(uid: streamUserId);

      // Future-based method
      when(mockGetProfileUseCase.execute(userId: futureUserId)).thenAnswer(
        (_) async => Right(futureProfile),
      );

      // Stream-based method
      when(mockWatchProfileUseCase.execute(userId: streamUserId)).thenAnswer(
        (_) => Stream.value(Right(streamProfile)),
      );

      // Act - Future 방식
      await provider.loadProfile(futureUserId);

      // Assert - Future 방식 결과
      expect(provider.profile, futureProfile);
      expect(provider.isLoading, false);

      // Act - Stream 방식
      final stream = provider.watchOtherUserProfile(streamUserId);

      // Assert - Stream 방식 결과 (Provider 상태와 독립적)
      await expectLater(stream, emits(streamProfile));
      expect(provider.profile, futureProfile, reason: 'Stream should not affect Provider state');
    });
  });
}
