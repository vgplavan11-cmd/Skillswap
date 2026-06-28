class LeaderboardEntry {
  final String userId;
  final String userName;
  final String userProfilePic;
  final String role; // mentor, learner
  final int sessionsConducted;
  final double averageRating;
  final int badgeCount;
  final double calculatedScore; // Ranking weight factor

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.role,
    required this.sessionsConducted,
    required this.averageRating,
    required this.badgeCount,
    required this.calculatedScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'role': role,
      'sessionsConducted': sessionsConducted,
      'averageRating': averageRating,
      'badgeCount': badgeCount,
      'calculatedScore': calculatedScore,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      role: map['role'] ?? 'learner',
      sessionsConducted: map['sessionsConducted'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      badgeCount: map['badgeCount'] ?? 0,
      calculatedScore: (map['calculatedScore'] ?? 0.0).toDouble(),
    );
  }

  // Calculate ranking score formula: (Sessions * 10) + (Rating * 20) + (BadgeCount * 15)
  static double calculateScore({
    required int sessions,
    required double rating,
    required int badges,
  }) {
    return (sessions * 10) + (rating * 20) + (badges * 15);
  }
}
