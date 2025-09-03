import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_loc/models/current_user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  Stream<CurrentUserModel?> get firebaseAuthStream {
    return authStateChanges.map((User? user) {
      if (user == null) {
        return null;
      } else {
        CurrentUserModel currentUserModel = CurrentUserModel(uid: user.uid);
        return currentUserModel;
      }
    });
  }

  Future<String?> get currentUserUidAsync async {
    return _firebaseAuth.currentUser?.uid;
  }

  String? get currentUserUid {
    return _firebaseAuth.currentUser?.uid;
  }
}
