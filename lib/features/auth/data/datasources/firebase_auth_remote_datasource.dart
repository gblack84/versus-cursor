// Firebase Remote DataSource Implementation
// Clean Architecture - Data Layer

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

import 'i_auth_remote_datasource.dart';
import '../dto/user_profile_dto.dart';

/// FirebaseAuthRemoteDataSource
///
/// Concrete implementation of IAuthRemoteDataSource using Firebase services.
/// Handles all Firebase Auth and Firestore operations.
class FirebaseAuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after sign in',
        );
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Failed to create user',
        );
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during user creation: $e');
      rethrow;
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign in was cancelled',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Failed to sign in with Google',
        );
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during Google sign in: $e');
      rethrow;
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'apple-sign-in-failed',
          message: 'Failed to sign in with Apple',
        );
      }

      // Update display name if provided by Apple
      final user = userCredential.user!;
      if (user.displayName == null && appleCredential.givenName != null) {
        final fullName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
          return _firebaseAuth.currentUser!;
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during Apple sign in: $e');
      rethrow;
    }
  }

  @override
  Future<User> signInWithPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      // Note: This is a simplified implementation
      // In a real app, you would need to implement the full phone auth flow
      // with verificationId management

      // For now, throw an unimplemented error
      // This should be implemented based on your specific phone auth flow
      throw UnimplementedError(
        'Phone authentication requires additional setup with verification ID management',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error during phone sign in: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendSmsOtp(String phoneNumber) async {
    try {
      // Phone authentication typically requires Firebase Phone Auth setup
      // with verificationId management
      // This should be implemented based on your specific phone auth flow

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          debugPrint('SMS code sent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
          debugPrint('Auto retrieval timeout');
        },
      );
    } catch (e) {
      debugPrint('Error sending SMS OTP: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error sending password reset email: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in',
        );
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error sending email verification: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in',
        );
      }

      // Delete user document from Firestore first
      await _firestore.collection('users').doc(user.uid).delete();

      // Then delete the auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error deleting user: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload to get updated user
      await user.reload();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error updating user profile: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<UserProfileDto?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserProfileDto.fromFirestore(data, uid);
    } catch (e) {
      debugPrint('Error getting user profile from Firestore: $e');
      return null;
    }
  }

  @override
  Future<void> createUserProfile(String uid, UserProfileDto profile) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        profile.toFirestore(),
        SetOptions(merge: false),
      );
    } catch (e) {
      debugPrint('Error creating user profile in Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data) async {
    try {
      // Add timestamp for tracking
      data['lastActive'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user profile in Firestore: $e');
      rethrow;
    }
  }
}