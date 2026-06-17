import 'package:journal/services/auth/authentication_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication implements AuthenticationApi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  FirebaseAuth getFirebaseAuth() {
    return _firebaseAuth;
  }

  @override
  Future<String?> currentUserUid() async {
    User? user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          print('No user found for that email');
          break;

        case 'wrong-password':
          print('Wrong password provided for that user');
          break;

        case 'invalid-email':
          print('The email address is badly formatted');
          break;

        case 'user-disabled':
          print('This user account has been disabled');
          break;

        default:
          print('Authentication error (${e.code}): ${e.message}');
      }
      rethrow;
    }
    
  }

  @override
  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          print('The password provided is too weak');
          break;

        case 'email-already-in-use':
          print('An account already exists for that email');
          break;

        default:
          print('Registration error (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    await user?.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  @override
  Future<String?> signInWithGoogle() async {
    try {
      _googleSignIn.initialize(
        clientId: '',
        serverClientId: '',
      );
      
      // trigger the local Google authentication UI
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // if (googleUser == null) return null;

      // obtian auth details (access & ID tokens) from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Failed to retrieve Google ID Token';
      }

      // create a new credential for firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error during Google Sign-In: ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In failed: $e');
      rethrow;
    }
  }
}