import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/chat_user.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';

class AuthService {
  static final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Stream<auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();
  static auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with Google (web vs mobile approach).
  static Future<auth.UserCredential?> signInWithGoogle() async {
    const String metodo = 'google';
    // Log login attempt
    await AnalyticsService.logTentativaLogin(metodo);

    try {
      // Set user identifier for Crashlytics
      if (_firebaseAuth.currentUser != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(
          _firebaseAuth.currentUser!.uid,
        );
      }
      auth.UserCredential userCredential;

      if (kIsWeb) {
        // Web
        final googleProvider = auth.GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile (Android/iOS)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User canceled the sign-in flow
          FirebaseCrashlytics.instance.log('Usuário cancelou login com Google');
          return null;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      // Successfully signed in, now store the user in Firestore
      final auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final token = await firebaseUser.getIdToken();
        debugPrint("Token: $token");
        await _storeUserData(firebaseUser);
        // Trigger a state refresh
        _firebaseAuth.currentUser?.reload();

        // Log successful login
        await AnalyticsService.logLoginSucesso(metodo, firebaseUser.uid);
        await AnalyticsService.logLogin(metodo);
      }

      return userCredential;
    } on auth.FirebaseAuthException catch (e) {
      // Log failed login
      await AnalyticsService.logLoginFalha(metodo, e.code);
      rethrow;
    } catch (error, stackTrace) {
      // Log the error to Crashlytics
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Erro durante login com Google',
        fatal: false,
      );
      // Log failed login with generic error
      await AnalyticsService.logLoginFalha(metodo, error.toString());
      rethrow;
    }
  }

  /// Stores/updates the user data in Firestore under `users/{uid}`.
  static Future<void> _storeUserData(auth.User firebaseUser) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid);

    // Get the FCM token
    final fcmToken = await NotificationService.getToken();

    final user = ChatUser(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'No Name',
      email: firebaseUser.email ?? 'No Email',
      photoURL: firebaseUser.photoURL,
      lastSignIn: Timestamp.now(),
      fcmToken: fcmToken,
    );

    await userDoc.set(user.toMap(), SetOptions(merge: true));
  }

  /// Sign out from Firebase and Google.
  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
