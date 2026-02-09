import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get user => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    // Create user profile doc
    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'username': username,
      'bio': 'NA',
      'phone': 'NA',
      'avatarUrl': 'NA',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
