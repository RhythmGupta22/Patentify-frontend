import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 static Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }



  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final User? user = userCredential.user;
        if (user != null) {
          debugPrint('User signed in: ${user.displayName}');
        }
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          debugPrint('Google sign-in canceled by user');
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        if (user != null) {
          debugPrint('User signed in: ${user.displayName}');
          update();
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Account exists with different credentials.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credential. Please try again.';
          break;
        case 'popup-blocked':
          errorMessage = 'Popup was blocked. Please allow popups and try again.';
          break;
        default:
          errorMessage = e.message ?? 'An unknown error occurred.';
      }
      debugPrint('Google sign-in error: $e');
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      Get.snackbar('Error', 'Failed to sign in with Google: $e');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      Get.snackbar('Error', 'Failed to sign in with Apple: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (e) {
      debugPrint('Sign-out error: $e');
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}