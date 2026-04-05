class UserProfile {
  final String uid;
  final String email;
  final String nickname;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final int? age;
  final String? avatarUrl;

  // Taper path
  final String purpose; // 'tapering', 'helping', 'looking'
  final String? taperDuration; // 'less_than_6m', '6m_to_1y', 'over_1y'
  final String? medication;
  final String? reasonForTapering;
  final double? startDose;
  final double? currentDose;
  final DateTime? taperStartDate;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.nickname,
    this.firstName,
    this.lastName,
    this.gender,
    this.age,
    this.avatarUrl,
    this.purpose = 'tapering',
    this.taperDuration,
    this.medication,
    this.reasonForTapering,
    this.startDose,
    this.currentDose,
    this.taperStartDate,
  });

  int get daysSinceStart {
    if (taperStartDate == null) return 0;
    return DateTime.now().difference(taperStartDate!).inDays;
  }

  factory UserProfile.fromMap(Map<String, dynamic> m, String uid) {
    return UserProfile(
      uid: uid,
      email: m['email'] ?? '',
      nickname: m['nickname'] ?? 'Journeyer',
      firstName: m['firstName'],
      lastName: m['lastName'],
      gender: m['gender'],
      age: m['age'],
      avatarUrl: m['avatarUrl'],
      purpose: m['purpose'] ?? 'tapering',
      taperDuration: m['taperDuration'],
      medication: m['medication'],
      reasonForTapering: m['reasonForTapering'],
      startDose: (m['startDose'] as num?)?.toDouble(),
      currentDose: (m['currentDose'] as num?)?.toDouble(),
      taperStartDate: m['taperStartDate'] != null
          ? DateTime.tryParse(m['taperStartDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'nickname': nickname,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (gender != null) 'gender': gender,
        if (age != null) 'age': age,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'purpose': purpose,
        if (taperDuration != null) 'taperDuration': taperDuration,
        if (medication != null) 'medication': medication,
        if (reasonForTapering != null) 'reasonForTapering': reasonForTapering,
        if (startDose != null) 'startDose': startDose,
        if (currentDose != null) 'currentDose': currentDose,
        if (taperStartDate != null) 'taperStartDate': taperStartDate!.toIso8601String(),
      };

  UserProfile copyWith({
    String? nickname,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? avatarUrl,
    String? purpose,
    String? taperDuration,
    String? medication,
    String? reasonForTapering,
    double? startDose,
    double? currentDose,
    DateTime? taperStartDate,
  }) =>
      UserProfile(
        uid: uid,
        email: email,
        nickname: nickname ?? this.nickname,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender ?? this.gender,
        age: age ?? this.age,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        purpose: purpose ?? this.purpose,
        taperDuration: taperDuration ?? this.taperDuration,
        medication: medication ?? this.medication,
        reasonForTapering: reasonForTapering ?? this.reasonForTapering,
        startDose: startDose ?? this.startDose,
        currentDose: currentDose ?? this.currentDose,
        taperStartDate: taperStartDate ?? this.taperStartDate,
      );
}
