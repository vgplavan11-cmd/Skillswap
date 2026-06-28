class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconCode; // key for UI to show appropriate icon
  final int requiredSessions;
  final double requiredRating;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCode,
    required this.requiredSessions,
    required this.requiredRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'requiredSessions': requiredSessions,
      'requiredRating': requiredRating,
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconCode: map['iconCode'] ?? '',
      requiredSessions: map['requiredSessions'] ?? 0,
      requiredRating: (map['requiredRating'] ?? 0.0).toDouble(),
    );
  }
}

// Global list of badges available in system
final List<BadgeModel> systemBadges = [
  BadgeModel(
    id: 'beginner_mentor',
    name: 'Beginner Mentor',
    description: 'Conducted at least 3 teaching sessions.',
    iconCode: 'award_star_bronze',
    requiredSessions: 3,
    requiredRating: 0.0,
  ),
  BadgeModel(
    id: 'verified_mentor',
    name: 'Verified Mentor',
    description: 'Conducted at least 10 sessions with average rating above 4.5.',
    iconCode: 'verified_user',
    requiredSessions: 10,
    requiredRating: 4.5,
  ),
  BadgeModel(
    id: 'top_educator',
    name: 'Top Educator',
    description: 'Conducted at least 50 sessions with average rating above 4.8.',
    iconCode: 'school',
    requiredSessions: 50,
    requiredRating: 4.8,
  ),
  BadgeModel(
    id: 'skill_master',
    name: 'Skill Master',
    description: 'Conducted at least 100 sessions in total.',
    iconCode: 'workspace_premium',
    requiredSessions: 100,
    requiredRating: 0.0,
  ),
];
