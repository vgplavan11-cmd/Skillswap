class MatchModel {
  final String id;
  final String userOneId; // Learner/Mentor A
  final String userTwoId; // Learner/Mentor B
  final String userOneName;
  final String userTwoName;
  final String userOneProfilePic;
  final String userTwoProfilePic;
  final String userOneSkillWanted; // Skill A wanted (offered by B)
  final String userTwoSkillWanted; // Skill B wanted (offered by A)
  final double matchPercentage;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime timestamp;

  MatchModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.userOneName,
    required this.userTwoName,
    required this.userOneProfilePic,
    required this.userTwoProfilePic,
    required this.userOneSkillWanted,
    required this.userTwoSkillWanted,
    required this.matchPercentage,
    this.status = 'pending',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userOneId': userOneId,
      'userTwoId': userTwoId,
      'userOneName': userOneName,
      'userTwoName': userTwoName,
      'userOneProfilePic': userOneProfilePic,
      'userTwoProfilePic': userTwoProfilePic,
      'userOneSkillWanted': userOneSkillWanted,
      'userTwoSkillWanted': userTwoSkillWanted,
      'matchPercentage': matchPercentage,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      userOneId: map['userOneId'] ?? '',
      userTwoId: map['userTwoId'] ?? '',
      userOneName: map['userOneName'] ?? '',
      userTwoName: map['userTwoName'] ?? '',
      userOneProfilePic: map['userOneProfilePic'] ?? '',
      userTwoProfilePic: map['userTwoProfilePic'] ?? '',
      userOneSkillWanted: map['userOneSkillWanted'] ?? '',
      userTwoSkillWanted: map['userTwoSkillWanted'] ?? '',
      matchPercentage: (map['matchPercentage'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
