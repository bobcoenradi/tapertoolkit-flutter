import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Journal entries ──────────────────────────────────────────────────────

  static Future<void> saveJournalEntry(JournalEntry entry) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(entry.dateKey);
    await ref.set(entry.toMap());
  }

  static Future<List<JournalEntry>> fetchJournalEntries() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('journal')
        .orderBy('date', descending: true)
        .limit(90)
        .get();
    return snap.docs
        .map((d) => JournalEntry.fromMap(d.data(), d.id))
        .toList();
  }

  static Future<JournalEntry?> fetchEntryForDate(DateTime date) async {
    final uid = _uid;
    if (uid == null) return null;
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('journal')
        .doc(key)
        .get();
    if (!doc.exists) return null;
    return JournalEntry.fromMap(doc.data()!, doc.id);
  }

  // ─── Appointments ─────────────────────────────────────────────────────────

  static Future<void> saveAppointment(Appointment appt) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = appt.id.isEmpty
        ? _db.collection('users').doc(uid).collection('appointments').doc()
        : _db.collection('users').doc(uid).collection('appointments').doc(appt.id);
    await ref.set(appt.toMap());
  }

  static Future<List<Appointment>> fetchUpcomingAppointments() async {
    final uid = _uid;
    if (uid == null) return [];
    final now = DateTime.now().toIso8601String();
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .where('dateTime', isGreaterThanOrEqualTo: now)
        .orderBy('dateTime')
        .limit(20)
        .get();
    return snap.docs
        .map((d) => Appointment.fromMap(d.data(), d.id))
        .toList();
  }

  static Future<void> deleteAppointment(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('appointments').doc(id).delete();
  }

  // ─── Meds ─────────────────────────────────────────────────────────────────

  static Future<void> saveMedReminder(MedReminder med) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = med.id.isEmpty
        ? _db.collection('users').doc(uid).collection('meds').doc()
        : _db.collection('users').doc(uid).collection('meds').doc(med.id);
    await ref.set(med.toMap());
  }

  static Future<List<MedReminder>> fetchMedReminders() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('meds')
        .get();
    return snap.docs
        .map((d) => MedReminder.fromMap(d.data(), d.id))
        .toList();
  }

  static Future<void> deleteMedReminder(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('meds').doc(id).delete();
  }

  // ─── Dose log (taper progress) ────────────────────────────────────────────

  static Future<void> logDose(double dose) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'currentDose': dose});
    // Also store a time-series log entry
    await _db
        .collection('users')
        .doc(uid)
        .collection('doseLog')
        .add({'dose': dose, 'loggedAt': DateTime.now().toIso8601String()});
  }

  static Future<List<Map<String, dynamic>>> fetchDoseLog() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('doseLog')
        .orderBy('loggedAt')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ─── Community posts ──────────────────────────────────────────────────────

  static Future<void> createPost({
    required String nickname,
    required String topicId,
    required String content,
  }) async {
    await _db.collection('communityPosts').add({
      'nickname': nickname,
      'topicId': topicId,
      'content': content,
      'likes': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> fetchPosts({String? topicId}) async {
    Query q = _db
        .collection('communityPosts')
        .orderBy('createdAt', descending: true)
        .limit(50);
    if (topicId != null) {
      q = q.where('topicId', isEqualTo: topicId);
    }
    final snap = await q.get();
    return snap.docs.map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>}).toList();
  }

  static Future<void> likePost(String postId) async {
    await _db.collection('communityPosts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
