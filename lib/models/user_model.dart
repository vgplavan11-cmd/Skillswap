enum UserRole { learner, mentor, admin }

class OfferedSkill {
  final String skillName;
  final String category;
  final String level; // Beginner, Intermediate, Advanced, Expert
  final int? experienceYears;

  OfferedSkill({
    required this.skillName,
    this.category = 'General',
    required this.level,
    this.experienceYears,
  });

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'category': category,
      'level': level,
      'experienceYears': experienceYears,
    };
  }

  factory OfferedSkill.fromMap(Map<String, dynamic> map) {
    return OfferedSkill(
      skillName: map['skillName'] ?? '',
      category: map['category'] ?? 'General',
      level: map['level'] ?? 'Beginner',
      experienceYears: map['experienceYears'],
    );
  }
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String collegeName;
  final String department;
  final String city;
  final String profilePicture;
  final String bio;
  final UserRole role;
  final List<OfferedSkill> skillsOffered;
  final List<OfferedSkill> skillsWanted;
  final double averageRating;
  final int totalReviews;
  final List<String> badges;
  final bool isVerifiedMentor;
  final int sessionsConducted;
  final String availability; // e.g. "Weekends", "Evenings", "Mon-Wed"
  final int experienceYears;
  final String classAccessPreference; // "Free Live Classes Only" or "All Classes"

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.collegeName,
    required this.department,
    this.city = '',
    required this.profilePicture,
    required this.bio,
    required this.role,
    required this.skillsOffered,
    required this.skillsWanted,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.badges = const [],
    this.isVerifiedMentor = false,
    this.sessionsConducted = 0,
    this.availability = 'Flexible',
    this.experienceYears = 0,
    this.classAccessPreference = 'All Classes',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'collegeName': collegeName,
      'department': department,
      'city': city,
      'profilePicture': profilePicture,
      'bio': bio,
      'role': role.toString().split('.').last,
      'skillsOffered': skillsOffered.map((e) => e.toMap()).toList(),
      'skillsWanted': skillsWanted.map((e) => e.toMap()).toList(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'badges': badges,
      'isVerifiedMentor': isVerifiedMentor,
      'sessionsConducted': sessionsConducted,
      'availability': availability,
      'experienceYears': experienceYears,
      'classAccessPreference': classAccessPreference,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      collegeName: map['collegeName'] ?? '',
      department: map['department'] ?? '',
      city: map['city'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      bio: map['bio'] ?? '',
      role: _parseRole(map['role']),
      skillsOffered: (map['skillsOffered'] as List?)
              ?.map((e) => OfferedSkill.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      skillsWanted: (map['skillsWanted'] as List?)
              ?.map((e) => OfferedSkill.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      isVerifiedMentor: map['isVerifiedMentor'] ?? false,
      sessionsConducted: map['sessionsConducted'] ?? 0,
      availability: map['availability'] ?? 'Flexible',
      experienceYears: map['experienceYears'] ?? 0,
      classAccessPreference: map['classAccessPreference'] ?? 'All Classes',
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'mentor':
        return UserRole.mentor;
      case 'admin':
        return UserRole.admin;
      case 'learner':
      default:
        return UserRole.learner;
    }
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? collegeName,
    String? department,
    String? city,
    String? profilePicture,
    String? bio,
    UserRole? role,
    List<OfferedSkill>? skillsOffered,
    List<OfferedSkill>? skillsWanted,
    double? averageRating,
    int? totalReviews,
    List<String>? badges,
    bool? isVerifiedMentor,
    int? sessionsConducted,
    String? availability,
    int? experienceYears,
    String? classAccessPreference,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      collegeName: collegeName ?? this.collegeName,
      department: department ?? this.department,
      city: city ?? this.city,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      skillsOffered: skillsOffered ?? this.skillsOffered,
      skillsWanted: skillsWanted ?? this.skillsWanted,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      badges: badges ?? this.badges,
      isVerifiedMentor: isVerifiedMentor ?? this.isVerifiedMentor,
      sessionsConducted: sessionsConducted ?? this.sessionsConducted,
      availability: availability ?? this.availability,
      experienceYears: experienceYears ?? this.experienceYears,
      classAccessPreference: classAccessPreference ?? this.classAccessPreference,
    );
  }
}
