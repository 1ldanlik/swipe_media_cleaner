import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_gate_provider.dart';
import 'auth_gate_state.dart';
import 'auth_gate_strings.dart';

class AuthGateController extends Notifier<AuthGateState> {
  @override
  AuthGateState build() {
    return const AuthGateState();
  }

  void setRegisterMode(bool isRegisterMode) {
    state = state.copyWith(isRegisterMode: isRegisterMode, clearErrorText: true);
  }

  Future<void> submitAuth({required String email, required String password}) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      state = state.copyWith(errorText: AuthGateStrings.invalidEmail);
      return;
    }

    if (normalizedPassword.length < 6) {
      state = state.copyWith(errorText: AuthGateStrings.shortPassword);
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorText: true);

    final auth = ref.read(authFirebaseAuthProvider);

    try {
      if (state.isRegisterMode) {
        await auth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: normalizedPassword,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: normalizedEmail, password: normalizedPassword);
      }
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(errorText: _mapFirebaseError(error), isLoading: false);
      return;
    } catch (_) {
      state = state.copyWith(errorText: AuthGateStrings.authFailed, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: false, clearErrorText: true);
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    final message = error.message;

    if (message != null && message.contains('CONFIGURATION_NOT_FOUND')) {
      return AuthGateStrings.configurationNotFound;
    }

    switch (error.code) {
      case 'invalid-email':
        return AuthGateStrings.invalidEmailFirebase;
      case 'email-already-in-use':
        return AuthGateStrings.emailAlreadyInUse;
      case 'user-not-found':
        return AuthGateStrings.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthGateStrings.invalidCredentials;
      case 'weak-password':
        return AuthGateStrings.weakPassword;
      case 'network-request-failed':
        return AuthGateStrings.networkRequestFailed;
      default:
        return AuthGateStrings.unknownFirebaseError(error.code, message);
    }
  }
}

final authGateControllerProvider = NotifierProvider<AuthGateController, AuthGateState>(
  AuthGateController.new,
);
