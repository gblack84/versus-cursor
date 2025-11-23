import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/auth/domain/usecases/phone/sign_in_with_phone_usecase.dart';
import 'package:versus_space/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:versus_space/features/auth/domain/failures/auth_failure.dart';
import 'package:versus_space/features/auth/domain/entities/auth_user.dart';
import 'package:versus_space/services/rate_limit/rate_limit_service.dart';

@GenerateMocks([], customMocks: [
  MockSpec<IAuthRepository>(
    onMissingStub: OnMissingStub.returnDefault,
  ),
  MockSpec<RateLimitService>(
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
import 'sign_in_with_phone_usecase_test.mocks.dart';

void main() {
  late SignInWithPhoneUseCase useCase;
  late MockIAuthRepository mockRepository;
  late MockRateLimitService mockRateLimitService;

  // Provide dummy values for Either types to fix MissingDummyValueError
  setUpAll(() {
    provideDummy<Either<AuthFailure, AuthUser>>(
      right(const AuthUser(uid: 'test-uid', email: null)),
    );
  });

  setUp(() {
    mockRepository = MockIAuthRepository();
    mockRateLimitService = MockRateLimitService();

    // Default: Allow phone sign-in (rate limit not exceeded)
    when(mockRateLimitService.canPerformAction(
      userId: anyNamed('userId'),
      action: anyNamed('action'),
    )).thenAnswer((_) async => true);

    useCase = SignInWithPhoneUseCase(
      repository: mockRepository,
      rateLimitService: mockRateLimitService,
    );
  });

  group('SignInWithPhoneUseCase', () {
    const testPhoneNumber = '+821012345678';
    const testVerificationCode = '123456';
    const testAuthUser = AuthUser(uid: 'test-uid', email: null);

    test('should return Right(AuthUser) when sign in successful', () async {
      // Arrange
      when(mockRepository.signInWithPhoneNumber(any, any))
          .thenAnswer((_) async => right(testAuthUser));

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.uid, testAuthUser.uid);
          expect(user.email, testAuthUser.email);
        },
      );
      verify(mockRepository.signInWithPhoneNumber(
        testPhoneNumber,
        testVerificationCode,
      )).called(1);
    });

    test(
        'should return Left(AuthFailure.invalidPhoneNumber) when phone number does not start with +',
        () async {
      // Arrange
      const invalidPhone = '821012345678'; // Missing '+'

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      // Phone validation happens before repository call
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });

    test(
        'should return Left(AuthFailure.invalidPhoneNumber) when phone number is too short',
        () async {
      // Arrange
      const invalidPhone = '+82101234'; // Too short (< 10 characters)

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });

    test(
        'should return Left(AuthFailure.invalidPhoneNumber) when phone number contains invalid characters',
        () async {
      // Arrange
      const invalidPhone = '+82-10-1234-5678'; // Contains dashes

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });

    test(
        'should return Left(AuthFailure.invalidSmsCode) when verification code is not 6 digits',
        () async {
      // Arrange
      const invalidCode = '12345'; // Too short (5 digits)

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: invalidCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidSmsCode>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });

    test(
        'should return Left(AuthFailure.invalidSmsCode) when verification code contains non-digits',
        () async {
      // Arrange
      const invalidCode = '12a456'; // Contains letter

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: invalidCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidSmsCode>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });

    test('should return Left(AuthFailure) when repository fails', () async {
      // Arrange
      when(mockRepository.signInWithPhoneNumber(any, any)).thenAnswer(
        (_) async => left(const AuthFailure.networkError()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkError>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.signInWithPhoneNumber(
        testPhoneNumber,
        testVerificationCode,
      )).called(1);
    });

    test(
        'should return Left(AuthFailure.invalidSmsCode) when SMS code is invalid',
        () async {
      // Arrange
      when(mockRepository.signInWithPhoneNumber(any, any)).thenAnswer(
        (_) async => left(const AuthFailure.invalidSmsCode()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidSmsCode>()),
        (_) => fail('Should return failure'),
      );
    });

    test(
        'should return Left(AuthFailure.smsCodeExpired) when SMS code expired',
        () async {
      // Arrange
      when(mockRepository.signInWithPhoneNumber(any, any)).thenAnswer(
        (_) async => left(const AuthFailure.smsCodeExpired()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SmsCodeExpired>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should accept valid phone numbers from different countries',
        () async {
      // Arrange
      final validPhoneNumbers = [
        '+821012345678', // Korea
        '+14155552671', // USA
        '+447911123456', // UK
        '+8613800138000', // China
        '+819012345678', // Japan
        '+33612345678', // France
        '+4915112345678', // Germany
      ];

      when(mockRepository.signInWithPhoneNumber(any, any))
          .thenAnswer((_) async => right(testAuthUser));

      // Act & Assert
      for (final phone in validPhoneNumbers) {
        final result = await useCase.execute(
          phoneNumber: phone,
          verificationCode: testVerificationCode,
        );
        expect(result.isRight(), true, reason: 'Phone $phone should be valid');
        verify(mockRepository.signInWithPhoneNumber(
          phone,
          testVerificationCode,
        )).called(1);
      }
    });

    test('should handle server error from repository', () async {
      // Arrange
      when(mockRepository.signInWithPhoneNumber(any, any)).thenAnswer(
        (_) async => left(const AuthFailure.serverError()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerError>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.signInWithPhoneNumber(
        testPhoneNumber,
        testVerificationCode,
      )).called(1);
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
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        verificationCode: testVerificationCode,
      );

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
        userId: testPhoneNumber,
        action: RateLimitAction.phoneAuth,
      )).called(1);

      // Repository should NOT be called (rate limit prevents it)
      verifyNever(mockRepository.signInWithPhoneNumber(any, any));
    });
  });
}
