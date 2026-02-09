import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDao {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    // Create/merge profile document
    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'username': username,
      'bio': 'NA',
      'phone': 'NA',
      'avatarUrl': 'NA',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Login with email/password. Returns the user profile map from Firestore (like before).
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    // Fetch profile doc (optional, but matches your old API style)
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Update user profile in Firestore.
  /// (The `id` parameter is kept for compatibility but is ignored; Firebase uses uid.)
  static Future<void> updateUser({
    String? id, // kept for compatibility; ignore it
    required String username,
    required String bio,
    required String phone,
    String? avatarUrl,
  }) async {
    final uid = getCurrentUserId();
    if (uid == null) throw Exception("Please login first");

    await _db.collection('users').doc(uid).update({
      'username': username,
      'bio': bio,
      'phone': phone,
      'avatarUrl': avatarUrl ?? 'NA',
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
    if (uid == null) {
      // Return an empty stream if not logged in
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots();
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
