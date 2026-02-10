import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserDao {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Current logged-in Firebase user (null if not logged in)
  static User? get currentUser => _auth.currentUser;

  /// Firebase UID (stable across devices). Use this instead of int userId.
  static String? getCurrentUserId() => _auth.currentUser?.uid;

  /// Register with email/password and create user profile doc in Firestore.
  static Future<void> registerUser(
    String email,
    String password,
    String username,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'username': username,
      'bio': 'NA',
      'phone': 'NA',
      'avatarUrl': 'NA',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Login with email/password. Returns the user profile map from Firestore.
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Update user profile in Firestore + optional avatar upload (Web+Mobile)
  static Future<void> updateUser({
    String? id, // kept for compatibility; ignored
    required String username,
    required String bio,
    required String phone,
    Uint8List? avatarBytes, // ✅ NEW: bytes instead of local path
    String? existingAvatarUrl,
  }) async {
    final uid = getCurrentUserId();
    if (uid == null) throw Exception("Please login first");

    String? avatarUrlToSave = existingAvatarUrl;

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      final ts = DateTime.now().millisecondsSinceEpoch;

      final ref = _storage
          .ref()
          .child('users')
          .child(uid)
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

    final updateData = <String, dynamic>{
      'username': username,
      'bio': bio,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtLocal': DateTime.now().millisecondsSinceEpoch,
    };

    if (avatarUrlToSave != null &&
        avatarUrlToSave.isNotEmpty &&
        avatarUrlToSave != 'NA') {
      updateData['avatarUrl'] = avatarUrlToSave;
    }

    await _db.collection('users').doc(uid).update(updateData);
  }

  /// Read current user's profile (one-time)
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = getCurrentUserId();
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Realtime stream of current user's profile (auto-updates UI)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    final uid = getCurrentUserId();
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
