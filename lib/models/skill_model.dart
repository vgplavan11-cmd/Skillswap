class SkillModel {
  final String id;
  final String name;
  final String category;
  final String description;

  SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

// Static skill categories and default popular skills
const List<String> skillCategories = [
  'Programming',
  'UI/UX Design',
  'Electronics',
  'AI & ML',
  'Data Science',
  'Communication',
  'Marketing',
  'Business',
  'Photography',
  'Content Creation',
];

final List<SkillModel> popularSkills = [
  SkillModel(id: '1', name: 'Python Programming', category: 'Programming', description: 'Learn logic, OOPs, and scripting with Python.'),
  SkillModel(id: '2', name: 'Figma UI/UX Design', category: 'UI/UX Design', description: 'Design modern web and mobile application screens.'),
  SkillModel(id: '3', name: 'Machine Learning', category: 'AI & ML', description: 'Implement neural networks and supervised models.'),
  SkillModel(id: '4', name: 'Arduino Electronics', category: 'Electronics', description: 'Build hardware projects using Arduino controllers.'),
  SkillModel(id: '5', name: 'Public Speaking', category: 'Communication', description: 'Master presentation skills and conquer stage fear.'),
  SkillModel(id: '6', name: 'Social Media Marketing', category: 'Marketing', description: 'Grow brands on Instagram, YouTube, and LinkedIn.'),
  SkillModel(id: '7', name: 'Business Strategy', category: 'Business', description: 'Learn financial planning, pitching, and operations.'),
  SkillModel(id: '8', name: 'Video Editing', category: 'Content Creation', description: 'Edit professional cinematic videos with Premiere Pro.'),
];
