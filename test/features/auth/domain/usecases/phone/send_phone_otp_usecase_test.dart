import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/auth/domain/usecases/phone/send_phone_otp_usecase.dart';
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
import 'send_phone_otp_usecase_test.mocks.dart';

void main() {
  late SendPhoneOtpUseCase useCase;
  late MockIAuthRepository mockRepository;
  late MockRateLimitService mockRateLimitService;

  // Provide dummy values for Either types to fix MissingDummyValueError
  setUpAll(() {
    provideDummy<Either<AuthFailure, bool>>(right(true));
  });

  setUp(() {
    mockRepository = MockIAuthRepository();
    mockRateLimitService = MockRateLimitService();

    // Default: Allow OTP sending (rate limit not exceeded)
    when(mockRateLimitService.canPerformAction(
      userId: anyNamed('userId'),
      action: anyNamed('action'),
    )).thenAnswer((_) async => true);

    useCase = SendPhoneOtpUseCase(
      repository: mockRepository,
      rateLimitService: mockRateLimitService,
    );
  });

  group('SendPhoneOtpUseCase', () {
    const testPhoneNumber = '+821012345678';

    test('should return Right(true) when OTP sent successfully', () async {
      // Arrange
      when(mockRepository.sendSmsOtp(any))
          .thenAnswer((_) async => right(true));

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        userId: testPhoneNumber,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => expect(success, true),
      );
      verify(mockRepository.sendSmsOtp(testPhoneNumber)).called(1);
      verify(mockRateLimitService.canPerformAction(
        userId: testPhoneNumber,
        action: RateLimitAction.sendSmsOtp,
      )).called(1);
    });

    test('should return Left(AuthFailure.invalidPhoneNumber) when phone number does not start with +',
        () async {
      // Arrange
      const invalidPhone = '821012345678'; // Missing '+'

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        userId: invalidPhone,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      // Phone validation happens before repository and rate limit calls
      verifyNever(mockRepository.sendSmsOtp(any));
      verifyNever(mockRateLimitService.canPerformAction(
        userId: anyNamed('userId'),
        action: anyNamed('action'),
      ));
    });

    test('should return Left(AuthFailure.invalidPhoneNumber) when phone number is too short',
        () async {
      // Arrange
      const invalidPhone = '+82101234'; // Too short (< 10 characters)

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        userId: invalidPhone,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.sendSmsOtp(any));
      verifyNever(mockRateLimitService.canPerformAction(
        userId: anyNamed('userId'),
        action: anyNamed('action'),
      ));
    });

    test('should return Left(AuthFailure.invalidPhoneNumber) when phone number contains invalid characters',
        () async {
      // Arrange
      const invalidPhone = '+82-10-1234-5678'; // Contains dashes

      // Act
      final result = await useCase.execute(
        phoneNumber: invalidPhone,
        userId: invalidPhone,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumber>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(mockRepository.sendSmsOtp(any));
      verifyNever(mockRateLimitService.canPerformAction(
        userId: anyNamed('userId'),
        action: anyNamed('action'),
      ));
    });

    test('should return Left(AuthFailure) when repository fails', () async {
      // Arrange
      when(mockRepository.sendSmsOtp(any)).thenAnswer(
        (_) async => left(const AuthFailure.networkError()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        userId: testPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkError>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.sendSmsOtp(testPhoneNumber)).called(1);
      verify(mockRateLimitService.canPerformAction(
        userId: testPhoneNumber,
        action: RateLimitAction.sendSmsOtp,
      )).called(1);
    });

    test('should accept valid phone numbers from different countries', () async {
      // Arrange
      final validPhoneNumbers = [
        '+821012345678',        // Korea
        '+14155552671',         // USA
        '+447911123456',        // UK
        '+8613800138000',       // China
        '+819012345678',        // Japan
        '+33612345678',         // France
        '+4915112345678',       // Germany
      ];

      when(mockRepository.sendSmsOtp(any))
          .thenAnswer((_) async => right(true));

      // Act & Assert
      for (final phone in validPhoneNumbers) {
        final result = await useCase.execute(
          phoneNumber: phone,
          userId: phone,
        );
        expect(result.isRight(), true, reason: 'Phone $phone should be valid');
        verify(mockRepository.sendSmsOtp(phone)).called(1);
        verify(mockRateLimitService.canPerformAction(
          userId: phone,
          action: RateLimitAction.sendSmsOtp,
        )).called(1);
      }
    });

    test('should handle server error from repository', () async {
      // Arrange
      when(mockRepository.sendSmsOtp(any)).thenAnswer(
        (_) async => left(const AuthFailure.serverError()),
      );

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        userId: testPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerError>()),
        (_) => fail('Should return failure'),
      );
      verify(mockRepository.sendSmsOtp(testPhoneNumber)).called(1);
      verify(mockRateLimitService.canPerformAction(
        userId: testPhoneNumber,
        action: RateLimitAction.sendSmsOtp,
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
      )).thenAnswer((_) async => const Duration(seconds: 300)); // 5분 대기

      // Act
      final result = await useCase.execute(
        phoneNumber: testPhoneNumber,
        userId: testPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<TooManyRequests>());
          // Verify error message contains wait time
          final tooManyRequestsFailure = failure as TooManyRequests;
          expect(tooManyRequestsFailure.message, contains('300초'));
        },
        (_) => fail('Should return failure'),
      );

      // Rate limit check should be called
      verify(mockRateLimitService.canPerformAction(
        userId: testPhoneNumber,
        action: RateLimitAction.sendSmsOtp,
      )).called(1);

      // Repository should NOT be called (rate limit prevents it)
      verifyNever(mockRepository.sendSmsOtp(any));
    });
  });
}
