import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Firebase
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storageRef = FirebaseStorage.instance;

  // Secure storage
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyToken = 'jwt_token';

  // ---------- Firebase session ----------
  static User? get user => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      _db.collection('users').doc(uid);

  // Create/merge profile doc
  static Future<void> _upsertProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _profileDoc(uid).set({
      'email': email.trim(),
      'username': username,
      'bio': 'NA',
      'phone': 'NA',
      'avatarUrl': 'NA',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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

    await _upsertProfile(
      uid: cred.user!.uid,
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

  // One-time profile fetch
  static Future<Map<String, dynamic>?> getProfile() async {
    final currentUid = uid;
    if (currentUid == null) return null;
    final doc = await _profileDoc(currentUid).get();
    return doc.data();
  }

  // Realtime profile stream
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final currentUid = uid;
    if (currentUid == null) return const Stream.empty();
    return _profileDoc(currentUid).snapshots();
  }

  // ---- update profile + optional avatar upload (Web+Mobile) ----
  static Future<void> updateProfile({
    required String username,
    required String bio,
    required String phone,
    Uint8List? avatarBytes, // ✅ NEW
    String? existingAvatarUrl,
  }) async {
    final currentUid = uid;
    if (currentUid == null) throw Exception("Please login first");

    String? avatarUrlToSave = existingAvatarUrl;

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = _storageRef
          .ref()
          .child('users')
          .child(currentUid)
          .child('avatars')
          .child('avatar_$ts.jpg');

      await ref.putData(
        avatarBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=3600',
        ),
      );

      avatarUrlToSave = await ref.getDownloadURL();
    }

    final data = <String, dynamic>{
      'username': username,
      'bio': bio,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtLocal': DateTime.now().millisecondsSinceEpoch,
    };

    if (avatarUrlToSave != null &&
        avatarUrlToSave.isNotEmpty &&
        avatarUrlToSave != 'NA') {
      data['avatarUrl'] = avatarUrlToSave;
    }

    await _profileDoc(currentUid).update(data);
  }

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
