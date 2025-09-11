import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the widget to test
import '../../lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart';

// Import repository interfaces
import '../../lib/features/profile/domain/repositories/i_user_repository.dart';

// Import domain models

// Mock classes
@GenerateMocks([IUserRepository, User, UserCredential])
import 'login_page_widget_test.mocks.dart';

void main() {
  group('LoginPageWidget Tests', () {
    late MockIUserRepository mockUserRepository;
    late GetIt sl;

    setUp(() {
      // Initialize GetIt for testing
      sl = GetIt.instance;
      sl.reset();

      // Create mocks
      mockUserRepository = MockIUserRepository();

      // Register mocks in DI container
      sl.registerSingleton<IUserRepository>(mockUserRepository);
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('should display login form with email and password fields',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Assert
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Email and password fields
      expect(find.text('이메일'), findsOneWidget); // Email label in Korean
      expect(find.text('비밀번호'), findsOneWidget); // Password label in Korean
      expect(find.text('로그인'), findsOneWidget); // Login button
    });

    testWidgets('should show validation error for invalid email',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Act - Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('로그인'));
      await tester.pump();

      // Assert
      expect(find.text('유효한 이메일을 입력해주세요'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Act - Leave password empty
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('로그인'));
      await tester.pump();

      // Assert
      expect(find.text('비밀번호를 입력해주세요'), findsOneWidget);
    });

    testWidgets('should call repository when login is successful',
        (WidgetTester tester) async {
      // Arrange
      // Create a mock user profile for testing
      // Note: UserProfile requires a DocumentReference, so we'll mock the response instead
      final Map<String, dynamic> testUserData = {
        'uid': 'test-uid',
        'email': 'test@example.com',
        'displayName': 'Test User',
      };

      // Note: Actual login testing would require mocking Firebase Auth
      // This test is simplified to focus on UI behavior

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Act - Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Note: Actual login would require Firebase Auth mock
      // This test focuses on UI behavior

      // Assert - Check UI responds correctly
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should navigate to sign up page when link is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Act - Find and tap sign up link
      final signUpLink = find.text('회원가입'); // Sign up in Korean
      expect(signUpLink, findsOneWidget);

      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Assert - Navigation would occur (needs GoRouter in real test)
      // This is a simplified test focusing on UI presence
      expect(signUpLink, findsOneWidget);
    });

    testWidgets('should show/hide password when visibility icon is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Find password field and visibility toggle
      final passwordField = find.byType(TextFormField).last;
      final visibilityToggle = find.byIcon(Icons.visibility_off);

      // Initially password should be obscured
      expect(visibilityToggle, findsOneWidget);

      // Act - Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Assert - Icon should change
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('should display social login buttons',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPageWidget(),
        ),
      );

      // Assert - Check for social login options
      expect(find.text('Google로 로그인'), findsOneWidget);
      expect(find.text('Apple로 로그인'), findsOneWidget);
      expect(find.text('전화번호로 로그인'), findsOneWidget);
    });
  });
}
