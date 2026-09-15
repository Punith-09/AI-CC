import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static bool _isInitialized = false;

  static const String _serverClientId =
      '352475496558-10fvhb6f5gm6ilddplc7g3bstfnm0l68.apps.googleusercontent.com';

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        await _googleSignIn.initialize(
          serverClientId: _serverClientId,
        );
      } catch (e) {
        debugPrint('GoogleSignIn initialize info: $e');
      }
      _isInitialized = true;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // Open Google account selection
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: null, // accessToken is no longer available directly in v7+, idToken is sufficient for Firebase Auth
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled or dismissed the sign-in sheet
        debugPrint('Google sign-in was cancelled by the user.');
        return null;
      }
      debugPrint('GoogleSignInException [${e.code}]: ${e.description}');
      throw Exception(
        e.description ?? 'Google Sign-In failed (${e.code.name}).',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Firebase Google sign-in failed.',
      );
    } catch (e) {
      final errorStr = e.toString().replaceFirst('Exception: ', '');
      if (errorStr.contains('canceled') ||
          errorStr.contains('Account result failed')) {
        return null;
      }
      throw Exception(errorStr);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('GoogleSignIn signOut error (ignored): $e');
    }
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error (ignored): $e');
    }
  }
}