/// Firebase-based AuthContract implementation
///
/// Provides AuthContract interface by wrapping FirebaseAuth.instance
/// Used for dependency injection in repositories that need auth information
///
/// **Purpose**: Bridge between Auth Feature and other features via Contract pattern
///
/// **Usage**:
/// ```dart
/// final authContract = FirebaseAuthContractImpl();
/// UserRepositoryImpl.initialize(authContract, idempotencyService);
/// ```
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_contract.dart';

class FirebaseAuthContractImpl implements AuthContract {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthContractImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  @override
  bool get isSignedIn {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  @override
  Future<String?> refreshToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true); // Force refresh
  }

  @override
  bool get isEmailVerified {
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  bool get isAnonymous {
    return _firebaseAuth.currentUser?.isAnonymous ?? false;
  }

  @override
  String? get currentUserDisplayName {
    return _firebaseAuth.currentUser?.displayName;
  }

  @override
  String? get currentUserPhoto {
    return _firebaseAuth.currentUser?.photoURL;
  }

  @override
  String? get currentPhoneNumber {
    return _firebaseAuth.currentUser?.phoneNumber;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
