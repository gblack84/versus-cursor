import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/firebase_auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';

/// Factory class for creating AuthRepository instances
/// This isolates the Data layer dependencies from Presentation layer
class AuthRepositoryFactory {
  static Future<IAuthRepository> create() async {
    final prefs = await SharedPreferences.getInstance();

    final localDataSource = AuthLocalDataSource(prefs: prefs);
    final remoteDataSource = FirebaseAuthRemoteDataSource(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    );

    return AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  }
}