abstract class AuthenticationApi {
  getFirebaseAuth();
  Future<String?> currentUserUid();
  Future<void> signOut();
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String?> signInWithGoogle();
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
}