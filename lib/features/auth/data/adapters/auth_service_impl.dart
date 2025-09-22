// Implementation of IAuthService using Repository Pattern
// Clean Architecture - Data Layer Adapter
// Phase 2.6에서 DI 컨테이너 통합 예정

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/i_auth_service.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../datasources/firebase_auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// AuthServiceImpl
///
/// IAuthService의 구현체로 Repository 패턴을 사용합니다.
/// FirebaseAuthManager 대신 Clean Architecture 원칙을 따릅니다.
class AuthServiceImpl implements IAuthService {
  late final IAuthRepository _repository;

  AuthServiceImpl() {
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    // Phase 2.6에서 DI 컨테이너로 교체 예정
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalDataSource(prefs: prefs);

    _repository = AuthRepositoryImpl(
      remoteDataSource: FirebaseAuthRemoteDataSource(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        googleSignIn: GoogleSignIn(),
      ),
      localDataSource: localDataSource,
    );
  }

  @override
  User? get currentUser {
    // Firebase Auth의 현재 사용자 반환
    return FirebaseAuth.instance.currentUser;
  }

  @override
  bool get loggedIn {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final authUser = await _repository.signInWithEmailAndPassword(email, password);
      if (authUser != null) {
        // Firebase User 객체 반환
        return FirebaseAuth.instance.currentUser;
      }
      return null;
    } catch (e) {
      print('AuthServiceImpl signInWithEmail error: $e');
      return null;
    }
  }

  @override
  Future<User?> createUserWithEmail(String email, String password) async {
    try {
      final authUser = await _repository.createUserWithEmailAndPassword(email, password);
      if (authUser != null) {
        // Firebase User 객체 반환
        return FirebaseAuth.instance.currentUser;
      }
      return null;
    } catch (e) {
      print('AuthServiceImpl createUserWithEmail error: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } catch (e) {
      print('AuthServiceImpl signOut error: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
    } catch (e) {
      print('AuthServiceImpl sendPasswordResetEmail error: $e');
      rethrow;
    }
  }

  @override
  Future<void> beginPhoneAuth({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onCodeSent,
    required void Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    try {
      // Repository를 통한 SMS OTP 발송
      final result = await _repository.sendSmsOtp(phoneNumber);
      if (!result) {
        onVerificationFailed(
          FirebaseAuthException(
            code: 'sms-send-failed',
            message: 'Failed to send SMS OTP',
          ),
        );
      }
      // Note: 실제 credential 생성은 별도 처리 필요
    } catch (e) {
      onVerificationFailed(
        FirebaseAuthException(
          code: 'unknown-error',
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<User?> authStateChanges() {
    // Firebase Auth의 상태 변경 스트림 직접 반환
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future<void> updateUserDisplayName(String displayName) async {
    try {
      await _repository.updateUserProfile(displayName: displayName);
    } catch (e) {
      print('AuthServiceImpl updateUserDisplayName error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _repository.deleteUser();
    } catch (e) {
      print('AuthServiceImpl deleteUser error: $e');
      rethrow;
    }
  }
}