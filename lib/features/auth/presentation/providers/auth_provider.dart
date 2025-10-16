// Auth Provider for State Management
// Clean Architecture - Presentation Layer

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/password_management_usecase.dart';
import '../../domain/usecases/email_verification_usecase.dart';
import '../../domain/usecases/account_management_usecase.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/features/profile/data/dto/user_profile_dto.dart';
import '/features/profile/data/mappers/user_profile_mapper.dart';
import '/core/interfaces/i_base_auth_user.dart';
import '/app/contracts/auth_contract.dart';
import '../../data/adapters/firebase_user_provider.dart';

/// AuthProvider
///
/// Central state management for authentication in the Versus Space app.
/// Manages user authentication state and provides methods for all auth operations.
/// Implements AuthContract to provide auth information to other Features.
class AuthProvider extends ChangeNotifier implements AuthContract {
  // Private instance for singleton
  static AuthProvider? _instance;

  // UseCases from DI
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithPhoneUseCase _signInWithPhoneUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final PasswordManagementUseCase _passwordManagementUseCase;
  final EmailVerificationUseCase _emailVerificationUseCase;
  final AccountManagementUseCase _accountManagementUseCase;

  // Auth State
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Phone Auth State
  bool _isCodeSent = false;
  String? _phoneNumber;

  // Legacy compatibility state (replacing global variables)
  VersusSpaceFirebaseUser? _firebaseUser;
  UserProfile? _currentUserDocument;
  String? _currentJwtToken;
  StreamSubscription? _authStreamSubscription;
  StreamSubscription? _userDocumentSubscription;
  StreamSubscription? _jwtTokenSubscription;

  // Private constructor for singleton
  AuthProvider._({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInWithPhoneUseCase signInWithPhoneUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required PasswordManagementUseCase passwordManagementUseCase,
    required EmailVerificationUseCase emailVerificationUseCase,
    required AccountManagementUseCase accountManagementUseCase,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signUpWithEmailUseCase = signUpWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithPhoneUseCase = signInWithPhoneUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _passwordManagementUseCase = passwordManagementUseCase,
       _emailVerificationUseCase = emailVerificationUseCase,
       _accountManagementUseCase = accountManagementUseCase;

  // Singleton factory
  factory AuthProvider() {
    if (_instance == null) {
      final getIt = GetIt.instance;
      _instance = AuthProvider._(
        signInWithEmailUseCase: getIt<SignInWithEmailUseCase>(),
        signUpWithEmailUseCase: getIt<SignUpWithEmailUseCase>(),
        signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
        signInWithAppleUseCase: getIt<SignInWithAppleUseCase>(),
        signInWithPhoneUseCase: getIt<SignInWithPhoneUseCase>(),
        signOutUseCase: getIt<SignOutUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
        passwordManagementUseCase: getIt<PasswordManagementUseCase>(),
        emailVerificationUseCase: getIt<EmailVerificationUseCase>(),
        accountManagementUseCase: getIt<AccountManagementUseCase>(),
      );
    }
    return _instance!;
  }

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.isEmailVerified ?? false;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  bool get isInitialized => _isInitialized;
  bool get isCodeSent => _isCodeSent;
  String? get phoneNumber => _phoneNumber;

  // ============= AuthContract Implementation =============

  @override
  String? getCurrentUserId() => currentUserUid;

  @override
  String? getCurrentUserEmail() => currentUserEmail;

  @override
  bool get isSignedIn => loggedIn;

  @override
  Future<String?> getIdToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (e) {
      debugPrint('getIdToken error: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } catch (e) {
      debugPrint('refreshToken error: $e');
      return null;
    }
  }

  @override
  String? get currentUserDisplayName =>
      _currentUserDocument?.displayName ?? _currentUser?.displayName ?? '';

  @override
  String? get currentUserPhoto =>
      _currentUserDocument?.photoUrl ?? _currentUser?.photoUrl ?? '';

  @override
  String? get currentPhoneNumber =>
      _currentUserDocument?.phoneNumber ?? _currentUser?.phoneNumber ?? '';

  // ============= Legacy compatibility getters =============

  BaseAuthUser? get baseAuthUser => _firebaseUser;
  bool get loggedIn => _firebaseUser?.loggedIn ?? false;
  UserProfile? get currentUserDocument => _currentUserDocument;
  String get currentUserEmail =>
      _currentUserDocument?.email ?? _currentUser?.email ?? '';
  String get currentUserUid => _currentUser?.uid ?? '';
  String get currentJwtToken => _currentJwtToken ?? '';
  bool get currentUserEmailVerified => _currentUser?.isEmailVerified ?? false;
  DocumentReference? get currentUserReference =>
      loggedIn ? FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid) : null;

  // Initialize provider (call on app start)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      _currentUser = await _getCurrentUserUseCase.call();

      // Set up legacy compatibility streams
      _setupLegacyStreams();

      _isInitialized = true;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Setup legacy streams for backward compatibility
  void _setupLegacyStreams() {
    // Firebase user stream
    _authStreamSubscription = versusSpaceFirebaseUserStream().listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });

    // User document stream
    _userDocumentSubscription = FirebaseAuth.instance
        .authStateChanges()
        .map<String>((user) => user?.uid ?? '')
        .switchMap(
          (uid) => uid.isEmpty
              ? Stream.value(null)
              : FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots()
                  .map((doc) {
                    if (!doc.exists || doc.data() == null) return null;
                    final dto = UserProfileDto.fromFirestore(doc.data()!);
                    return UserProfileMapper.toDomain(dto, doc.reference);
                  })
                  .handleError((_) {}),
        )
        .listen((userDoc) {
      _currentUserDocument = userDoc;
      notifyListeners();
    });

    // JWT token stream
    _jwtTokenSubscription = FirebaseAuth.instance
        .idTokenChanges()
        .asyncMap((user) => user?.getIdToken())
        .listen((token) {
      _currentJwtToken = token;
    });
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signInWithEmailUseCase.execute(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Login failed. Please check your credentials.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signUpWithEmailUseCase.execute(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Account creation failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during sign up: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signInWithGoogleUseCase.execute();

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Google sign in failed.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during Google sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signInWithAppleUseCase.execute();

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Apple sign in failed.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during Apple sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send OTP for phone authentication
  Future<bool> sendPhoneOtp(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _signInWithPhoneUseCase.sendOtp(phoneNumber);

      if (success) {
        _isCodeSent = true;
        _phoneNumber = phoneNumber;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to send verification code.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred sending OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP for phone authentication
  Future<bool> resendPhoneOtp() async {
    if (_phoneNumber == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _signInWithPhoneUseCase.resendOtp(_phoneNumber!);

      if (!success) {
        _setError('Failed to resend verification code. Please wait and try again.');
        return false;
      }
      return true;
    } catch (e) {
      _setError('An error occurred resending OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with phone number
  Future<bool> signInWithPhone({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _signInWithPhoneUseCase.execute(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );

      if (user != null) {
        _currentUser = user;
        _isCodeSent = false;
        _phoneNumber = null;
        notifyListeners();
        return true;
      } else {
        _setError('Phone sign in failed. Please check the verification code.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during phone sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _signOutUseCase.execute();
      _currentUser = null;
      _isCodeSent = false;
      _phoneNumber = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _passwordManagementUseCase.sendPasswordResetEmail(email);

      if (!success) {
        _setError('Failed to send password reset email.');
        return false;
      }
      return true;
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _passwordManagementUseCase.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!success) {
        _setError('Failed to update password.');
        return false;
      }
      return true;
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _emailVerificationUseCase.sendVerificationEmail();

      if (!success) {
        _setError('Failed to send verification email.');
        return false;
      }
      return true;
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await _emailVerificationUseCase.isEmailVerified();

      if (isVerified && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(isEmailVerified: true);
        notifyListeners();
      }

      return isVerified;
    } catch (e) {
      debugPrint('Check email verification error: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _accountManagementUseCase.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (success) {
        // Reload user to get updated info
        _currentUser = await _accountManagementUseCase.getCurrentUser();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _accountManagementUseCase.deleteAccount();

      if (success) {
        _currentUser = null;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete account.');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Stream auth state changes
  Stream<AuthUser?> get authStateChanges {
    return _accountManagementUseCase.authStateChanges;
  }

  // Check user roles and permissions
  Future<bool> get isPremiumUser async {
    return await _accountManagementUseCase.isPremiumUser();
  }

  Future<bool> get isAdmin async {
    return await _accountManagementUseCase.isAdmin();
  }

  Future<bool> get isTester async {
    return await _accountManagementUseCase.isTester();
  }

  Future<bool> get isProfileComplete async {
    return await _accountManagementUseCase.isProfileComplete();
  }

  // Clean up resources
  @override
  void dispose() {
    _authStreamSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    _jwtTokenSubscription?.cancel();
    super.dispose();
  }
}