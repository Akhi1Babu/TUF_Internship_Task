import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authProvider).authStateChanges();
});

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false; // represents whether we are currently loading
  }

  Future<void> signIn(String email, String password) async {
    state = true;
    try {
      await ref.read(authProvider).signInWithEmailAndPassword(email: email, password: password);
    } finally {
      state = false;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = true;
    try {
      UserCredential userCred = await ref.read(authProvider).createUserWithEmailAndPassword(email: email, password: password);
      await userCred.user?.updateDisplayName(name);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authProvider).signOut();
  }
}
