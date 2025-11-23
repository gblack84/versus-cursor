import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/auth/domain/usecases/account/reset_password_usecase.dart';
import 'package:versus_space/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:versus_space/features/auth/domain/failures/auth_failure.dart';
import 'package:versus_space/services/rate_limit/rate_limit_service.dart';

@GenerateMocks([], customMocks: [
  MockSpec<IAuthRepository>(
    onMissingStub: OnMissingStub.returnDefault,
  ),
  MockSpec<RateLimitService>(
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
import 'reset_password_usecase_test.mocks.dart';

void main() {
  late ResetPasswordUseCase useCase;
  late MockIAuthRepository mockRepository;
  late MockRateLimitService mockRateLimitService;

  // Provide dummy values for Either types to fix MissingDummyValueError
  setUpAll(() {
    provideDummy<Either<AuthFailure, void>>(right(null));
  });

  setUp(() {
    mockRepository = MockIAuthRepository();
    mockRateLimitService = MockRateLimitService();

    // Default: Allow password reset (rate limit not exceeded)
    when(mockRateLimitService.canPerformAction(
      userId: anyNamed('userId'),
      action: anyNamed('action'),
    )).thenAnswer((_) async => true);

    useCase = ResetPasswordUseCase(
      repository: mockRepository,
      rateLimitService: mockRateLimitService,
    );
  });

  group('ResetPasswordUseCase', () {
    const testEmail = 'test@example.com';

    test('should return Right(void) when password reset email sent successfully',
        () async {
      // Arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => right(null));

      // Act
      final result = await useCase.execute(email: testEmail);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (_) => expect(true, true),
      );
      verify(mockRepository.sendPasswordResetEmail(testEmail)).called(1);
    });

    test('should return Left(AuthFailure.invalidEmail) for invalid email format',
        () async {
      // Arrange
      const invalidEmail = 'invalid-email';

      // Act
      final result = await useCase.execute(email: invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidEmail>()),
        (_) => fail('Should return failure'),
      );
      // Email validation happens before repository call
    });

    test('should return Left(AuthFailure.invalidEmail) for email without @',
        () async {
      // Arrange
      const invalidEmail = 'testexample.com';

      // Act
      final result = await useCase.execute(email: invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidEmail>()),
        (_) => fail('Should return failure'),
      );
      // Email validation happens before repository call
    });

    test('should return Left(AuthFailure.invalidEmail) for email without domain',
        () async {
      // Arrange
      const invalidEmail = 'test@';

      // Act
      final result = await useCase.execute(email: invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidEmail>()),
        (_) => fail('Should return failure'),
      );
      // Email validation happens before repository call
    });

    test('should return Left(AuthFailure) when repository fails', () async {
      // Arrange
      when(mockRepository.sendPasswordResetEmail(any)).thenAnswer(
        (_) async => left(const AuthFailure.networkError()),
      );

      // Act
      final result = await useCase.execute(email: testEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkError>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.sendPasswordResetEmail(testEmail)).called(1);
    });

    test('should accept valid email formats', () async {
      // Arrange
      final validEmails = [
        'test@example.com',
        'user+tag@domain.co.uk',
        'first.last@subdomain.example.com',
        'test_123@test-domain.org',
      ];

      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => right(null));

      // Act & Assert
      for (final email in validEmails) {
        final result = await useCase.execute(email: email);
        expect(result.isRight(), true, reason: 'Email $email should be valid');
        verify(mockRepository.sendPasswordResetEmail(email)).called(1);
      }
    });

    test('should return Left(AuthFailure.tooManyRequests) when rate limit exceeded',
        () async {
      // Arrange - Override default behavior to simulate rate limit exceeded
      when(mockRateLimitService.canPerformAction(
        userId: anyNamed('userId'),
        action: anyNamed('action'),
      )).thenAnswer((_) async => false);

      when(mockRateLimitService.getTimeUntilNextRequest(
        userId: anyNamed('userId'),
        action: anyNamed('action'),
      )).thenAnswer((_) async => const Duration(seconds: 3600)); // 1시간 대기

      // Act
      final result = await useCase.execute(email: testEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<TooManyRequests>());
          // Verify error message contains wait time
          final tooManyRequestsFailure = failure as TooManyRequests;
          expect(tooManyRequestsFailure.message, contains('3600초'));
        },
        (_) => fail('Should return failure'),
      );

      // Rate limit check should be called
      verify(mockRateLimitService.canPerformAction(
        userId: testEmail,
        action: RateLimitAction.resetPassword,
      )).called(1);

      // Repository should NOT be called (rate limit prevents it)
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });
  });
}
