import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/enums.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final firebaseUser = credential.user!;
    final profile = AppUser(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      department: department.trim(),
      role: UserRole.student,
      createdAt: DateTime.now(),
    );
    await createProfile(profile);
    await firebaseUser.updateDisplayName(name.trim());
  }

  Future<void> createProfile(AppUser user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<AppUser?> watchProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return AppUser.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> signOut() => _auth.signOut();
}