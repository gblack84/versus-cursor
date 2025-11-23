import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/auth/domain/usecases/account/update_password_usecase.dart';
import 'package:versus_space/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:versus_space/features/auth/domain/failures/auth_failure.dart';

@GenerateMocks([], customMocks: [
  MockSpec<IAuthRepository>(
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
import 'update_password_usecase_test.mocks.dart';

void main() {
  late UpdatePasswordUseCase useCase;
  late MockIAuthRepository mockRepository;

  // Provide dummy values for Either types to fix MissingDummyValueError
  setUpAll(() {
    provideDummy<Either<AuthFailure, bool>>(right(true));
    provideDummy<Either<AuthFailure, void>>(right(null));
  });

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = UpdatePasswordUseCase(repository: mockRepository);
  });

  group('UpdatePasswordUseCase', () {
    const testPassword = 'newSecurePassword123';

    test('should return Right(true) when password update succeeds', () async {
      // Arrange
      when(mockRepository.isSignedIn).thenReturn(true);
      when(mockRepository.updatePassword(any))
          .thenAnswer((_) async => right(true));

      // Act
      final result = await useCase.execute(newPassword: testPassword);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => expect(success, true),
      );
      verify(mockRepository.updatePassword(testPassword)).called(1);
    });

    test('should return Left(AuthFailure.weakPassword) for password < 6 chars',
        () async {
      // Arrange
      const weakPassword = '12345'; // 5 chars

      // Act
      final result = await useCase.execute(newPassword: weakPassword);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<WeakPassword>()),
        (_) => fail('Should return failure'),
      );
      // Password validation happens before repository call
    });

    test('should return Left(AuthFailure.userNotFound) when user not signed in',
        () async {
      // Arrange
      when(mockRepository.isSignedIn).thenReturn(false);

      // Act
      final result = await useCase.execute(newPassword: testPassword);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UserNotFound>()),
        (_) => fail('Should return failure'),
      );
      // User check happens before repository call
    });

    test('should return Left(AuthFailure) when repository fails', () async {
      // Arrange
      when(mockRepository.isSignedIn).thenReturn(true);
      when(mockRepository.updatePassword(any)).thenAnswer(
        (_) async => left(const AuthFailure.requiresRecentLogin()),
      );

      // Act
      final result = await useCase.execute(newPassword: testPassword);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<RequiresRecentLogin>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.updatePassword(testPassword)).called(1);
    });
  });
}
