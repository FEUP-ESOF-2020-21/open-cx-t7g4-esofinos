part of '../../main.dart';

class FireAuth {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  AuthResultStatus status;

  User get currentUser => auth.currentUser;

  Stream<User> get authStateChanges => auth.authStateChanges();

  Future<AuthResultStatus> register(
      {String email,
      String password,
      String displayName,
      String photoURL}) async {
    try {
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<AuthResultStatus> loginAccount({String email, String password}) async {
    try {
      final authResult = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        status = AuthResultStatus.successful;
      } else {
        status = AuthResultStatus.undefined;
      }
    } catch (e) {
      status = AuthExceptionHandler.handleException(e);
    }
    return status;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}

