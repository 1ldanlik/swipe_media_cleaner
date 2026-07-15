import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authUserChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authFirebaseAuthProvider);
  return auth.authStateChanges();
});
