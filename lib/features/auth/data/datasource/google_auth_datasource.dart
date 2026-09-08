import 'package:firebase_auth/firebase_auth.dart';
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

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        try {
          await _googleSignIn.initialize();
        } catch (_) {
          // Ignore if it was already initialized elsewhere
        }
        _isInitialized = true;
      }
      // Open Google account selection
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.authenticate();

      // User cancelled Google sign-in
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }

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
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Firebase Google sign-in failed.',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}