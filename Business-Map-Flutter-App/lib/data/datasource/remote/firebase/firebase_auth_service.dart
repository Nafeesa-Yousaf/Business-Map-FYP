import 'package:business_map/utils/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService(this._firebaseAuth, this._googleSignIn);

  Future<User?> authState() async {
    return _firebaseAuth.currentUser;
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential cred = await _firebaseAuth
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 10));

    await cred.user?.updateDisplayName(name).timeout(const Duration(seconds: 10));
    await cred.user?.reload().timeout(const Duration(seconds: 10));

    return _firebaseAuth.currentUser;
  }

  Future<User?> login({required String email, required String password}) async {
    await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 10));
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _googleSignIn.initialize(serverClientId: AppConfigs.googleClientId);
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final List<String> scopes = <String>['email', 'profile'];
    final GoogleSignInClientAuthorization authorization = await googleUser
        .authorizationClient
        .authorizeScopes(scopes);
    final String accessToken = authorization.accessToken;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .timeout(const Duration(seconds: 10));
  }

  Future<void> logout() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) return;

    for (var provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        await _googleSignIn.signOut();
      }
    }
    await _firebaseAuth.signOut().timeout(const Duration(seconds: 10));
  }

  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth
        .sendPasswordResetEmail(email: email)
        .timeout(const Duration(seconds: 10));
  }

  Future<void> changePassword({required String currentPassword,
    required String newPassword}) async {
    final user = _firebaseAuth.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    await user
        .reauthenticateWithCredential(cred)
        .timeout(const Duration(seconds: 10));

    await user.updatePassword(newPassword).timeout(const Duration(seconds: 10));
  }

  Future<void> reauthenticate({String? password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found.',
      );
    }

    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    if (isGoogle) {
      await _googleSignIn.initialize(serverClientId: AppConfigs.googleClientId);
      final googleUser = await _googleSignIn.authenticate();
      final currentEmail = user.email?.trim().toLowerCase();
      final googleEmail = googleUser.email.trim().toLowerCase();
      if (currentEmail != null &&
          currentEmail.isNotEmpty &&
          googleEmail != currentEmail) {
        throw FirebaseAuthException(
          code: 'user-mismatch',
          message:
              'Please re-authenticate with the same Google account used for this profile.',
        );
      }

      final googleAuth = googleUser.authentication;
      final List<String> scopes = ['email', 'profile'];
      final authorization =
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );
      await user
          .reauthenticateWithCredential(credential)
          .timeout(const Duration(seconds: 10));
    } else {
      final email = user.email?.trim();
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Account email is missing. Please sign in again.',
        );
      }
      if (password == null || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Password is required to re-authenticate.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password.trim(),
      );
      await user
          .reauthenticateWithCredential(credential)
          .timeout(const Duration(seconds: 10));
    }
  }

  Future<void> deleteUserAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found.',
      );
    }
    await user.delete().timeout(const Duration(seconds: 10));
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Best-effort local Google session cleanup.
    }
  }
}
