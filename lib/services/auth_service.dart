import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign up ──────────────────────────────────────────────────────────────

  static Future<UserProfile> signUp({
    required String email,
    required String password,
    required String nickname,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = UserProfile(
      uid: cred.user!.uid,
      email: email,
      nickname: nickname,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      age: age,
    );
    await _db.collection('users').doc(cred.user!.uid).set(profile.toMap());
    return profile;
  }

  // ─── Sign in ──────────────────────────────────────────────────────────────

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ─── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() => _auth.signOut();

  // ─── Profile ──────────────────────────────────────────────────────────────

  static Future<UserProfile?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, user.uid);
  }

  static Future<void> updateProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update(profile.toMap());
  }

  static Future<void> updateTaperPath({
    required String purpose,
    String? taperDuration,
    String? medication,
    String? reasonForTapering,
  }) async {
    final user = currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({
      'purpose': purpose,
      if (taperDuration != null) 'taperDuration': taperDuration,
      if (medication != null) 'medication': medication,
      if (reasonForTapering != null) 'reasonForTapering': reasonForTapering,
    });
  }
}
