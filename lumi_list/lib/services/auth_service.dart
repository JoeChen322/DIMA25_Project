import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Firebase
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Secure storage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyToken = 'jwt_token';

  // ---------- Firebase session ----------
  static User? get user => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  // Create/merge profile doc
  static Future<void> _upsertProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'username': username,
      'bio': 'NA',
      'phone': 'NA',
      'avatarUrl': 'NA',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Sign up
  static Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final newUid = cred.user!.uid;

    await _upsertProfile(
      uid: newUid,
      email: email,
      username: username,
    );
  }

  // Sign in
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Optional: fetch current user profile (one-time)
  static Future<Map<String, dynamic>?> getProfile() async {
    final currentUid = uid;
    if (currentUid == null) return null;
    final doc = await _db.collection('users').doc(currentUid).get();
    return doc.data();
  }

  // Optional: realtime profile stream
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final currentUid = uid;
    if (currentUid == null) return const Stream.empty();
    return _db.collection('users').doc(currentUid).snapshots();
  }

  // Sign out (also clears stored token)
  static Future<void> signOut({bool clearStoredToken = true}) async {
    await _auth.signOut();
    if (clearStoredToken) {
      await clearToken();
    }
  }

  // ---------- Secure token helpers ----------
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }
}
