import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../services/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  auth.User? _user;
  bool _isLoading = false;

  AuthenticationProvider() {
    _user = AuthService.currentUser;
    // Listen to auth state changes
    AuthService.authStateChanges.listen((auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  auth.User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential?.user != null) {
        _user = userCredential!.user;
        notifyListeners();
      }
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Erro ao fazer login com Google no AuthenticationProvider',
        fatal: false,
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await AuthService.signOut();
      _user = null;
      notifyListeners();
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Erro ao fazer logout no AuthenticationProvider',
        fatal: false,
      );
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
