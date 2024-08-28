import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_wellnest_frontend/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Check if the user is currently signed in
  Future<bool> isSignedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      debugPrint('$e');
    }
    return false;
  }

  /// Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This user has been disabled.';
        default:
          return 'An error occurred during sign-in. Please try again.';
      }
    } catch (e) {
      debugPrint('Sign in failed: $e');
      return 'An unknown error occurred during sign-in.';
    }
  }

  /// Sign Out
  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return null;
    } catch (e) {
      debugPrint('Sign out failed: $e');
      return 'An unknown error occurred during sign-out. Please try again.';
    }
  }

  /// Sign up and save user data in Firestore
  Future<String?> signUp(
      String email, String password, UserModel userModel) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = result.user?.uid;

      if (uid != null) {
        userModel = userModel.copyWith(uid: uid);
        await saveUser(userModel);
        return null;
      }

      return 'Failed to retrieve user ID during sign-up.';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return 'An error occurred during sign-up. Please try again.';
      }
    } catch (e) {
      debugPrint("Sign up failed: $e");
      return 'An unknown error occurred during sign-up.';
    }
  }

  /// Sign In with Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Sign in aborted by user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final UserModel userModel = UserModel(
        uid: userCredential.user?.uid ?? '',
        username: userCredential.user?.displayName ?? '',
        profilePic: userCredential.user?.photoURL ?? '',
      );

      await saveUser(userModel);

      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return 'An error occurred during Google sign-in: ${e.message}';
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      return 'An unknown error occurred during Google sign-in.';
    }
  }

  /// Save user data in Firestore
  Future<String?> saveUser(UserModel userModel) async {
    try {
      await _firestore
          .collection("users")
          .doc(userModel.uid)
          .set(userModel.toMap());
      return null;
    } catch (e) {
      debugPrint("Failed to save user: $e");
      return 'Failed to save user data. Please try again.';
    }
  }

  /// Get the current signed in user from Firestore
  Future<UserModel?> getUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final doc =
            await _firestore.collection("users").doc(firebaseUser.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Failed to get user: $e");
      return null;
    }
  }

  /// Delete user data from Firestore
  Future<String?> deleteUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        await _firestore.collection("users").doc(firebaseUser.uid).delete();
        return null;
      } catch (e) {
        debugPrint("Failed to delete user: $e");
        return 'Failed to delete user data. Please try again.';
      }
    }
    return 'User is not signed in.';
  }
}
