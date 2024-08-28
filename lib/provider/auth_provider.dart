import 'package:flutter/material.dart';
import 'package:ai_wellnest_frontend/repository/auth_repository.dart';
import 'package:ai_wellnest_frontend/model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  bool isLoadingSignIn = false;
  bool isLoadingSignOut = false;
  bool isLoadingSignUp = false;
  bool isSignedIn = false;
  UserModel? currentUser;
  String? authErrorMessage;
  bool isCheckingAuthState = true;

  AuthProvider(this.authRepository) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 1));
    isSignedIn = await authRepository.isSignedIn();
    if (isSignedIn) {
      currentUser = await authRepository.getUser();
    }
    isCheckingAuthState = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    isLoadingSignIn = true;
    authErrorMessage = null;
    notifyListeners();

    final user = await authRepository.signIn(email, password);
    if (user != null) {
      currentUser = await authRepository.getUser();
      isSignedIn = currentUser != null;
    } else {
      authErrorMessage = user;
    }

    isLoadingSignIn = false;
    notifyListeners();
    return isSignedIn;
  }

  Future<bool> signOut() async {
    isLoadingSignOut = true;
    authErrorMessage = null;
    notifyListeners();

    final result = await authRepository.signOut();
    if (result == null) {
      currentUser = null;
      isSignedIn = false;
    } else {
      authErrorMessage = result;
    }

    isLoadingSignOut = false;
    notifyListeners();
    return !isSignedIn;
  }

  Future<bool> signUp(String email, String password, UserModel user) async {
    isLoadingSignUp = true;
    authErrorMessage = null;
    notifyListeners();

    final result = await authRepository.signUp(email, password, user);
    if (result == null) {
      currentUser = await authRepository.getUser();
      isSignedIn = currentUser != null;
    } else {
      authErrorMessage = result;
    }

    isLoadingSignUp = false;
    notifyListeners();
    return isSignedIn;
  }

  Future<bool> signInWithGoogle() async {
    isLoadingSignIn = true;
    authErrorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithGoogle();

    if (result != null) {
      currentUser = await authRepository.getUser();
      isSignedIn = currentUser != null;
    } else {
      authErrorMessage = result;
    }

    isLoadingSignIn = false;
    notifyListeners();
    return isSignedIn;
  }

  void clearErrorMessage() {
    authErrorMessage = null;
    notifyListeners();
  }
}
