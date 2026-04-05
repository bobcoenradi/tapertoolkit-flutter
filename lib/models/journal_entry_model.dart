class JournalEntry {
  final String id;
  final String uid;
  final DateTime date;
  final String mood; // 'radiant', 'steady', 'neutral', 'uneasy', 'heavy'
  final String? text;
  final double? doseLogged;
  final List<String> symptoms;

  const JournalEntry({
    required this.id,
    required this.uid,
    required this.date,
    required this.mood,
    this.text,
    this.doseLogged,
    this.symptoms = const [],
  });

  factory JournalEntry.fromMap(Map<String, dynamic> m, String id) {
    return JournalEntry(
      id: id,
      uid: m['uid'] ?? '',
      date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      mood: m['mood'] ?? 'neutral',
      text: m['text'],
      doseLogged: (m['doseLogged'] as num?)?.toDouble(),
      symptoms: List<String>.from(m['symptoms'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'date': date.toIso8601String(),
        'mood': mood,
        if (text != null) 'text': text,
        if (doseLogged != null) 'doseLogged': doseLogged,
        'symptoms': symptoms,
      };

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class Appointment {
  final String id;
  final String uid;
  final String title;
  final String? subtitle; // e.g. "Taper Review"
  final DateTime dateTime;
  final String type; // 'doctor', 'therapy', 'other'

  const Appointment({
    required this.id,
    required this.uid,
    required this.title,
    this.subtitle,
    required this.dateTime,
    this.type = 'doctor',
  });

  factory Appointment.fromMap(Map<String, dynamic> m, String id) {
    return Appointment(
      id: id,
      uid: m['uid'] ?? '',
      title: m['title'] ?? '',
      subtitle: m['subtitle'],
      dateTime: DateTime.tryParse(m['dateTime'] ?? '') ?? DateTime.now(),
      type: m['type'] ?? 'doctor',
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        'dateTime': dateTime.toIso8601String(),
        'type': type,
      };
}

class MedReminder {
  final String id;
  final String uid;
  final String name;
  final String? dosage;
  final bool ordered;
  final DateTime? refillNeededBy;
  final String? status; // 'ordered', 'arriving', 'needed'

  const MedReminder({
    required this.id,
    required this.uid,
    required this.name,
    this.dosage,
    this.ordered = false,
    this.refillNeededBy,
    this.status,
  });

  factory MedReminder.fromMap(Map<String, dynamic> m, String id) {
    return MedReminder(
      id: id,
      uid: m['uid'] ?? '',
      name: m['name'] ?? '',
      dosage: m['dosage'],
      ordered: m['ordered'] ?? false,
      refillNeededBy: m['refillNeededBy'] != null
          ? DateTime.tryParse(m['refillNeededBy'])
          : null,
      status: m['status'],
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        if (dosage != null) 'dosage': dosage,
        'ordered': ordered,
        if (refillNeededBy != null) 'refillNeededBy': refillNeededBy!.toIso8601String(),
        if (status != null) 'status': status,
      };
}
