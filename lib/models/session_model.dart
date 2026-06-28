class SessionModel {
  final String id;
  final String mentorId;
  final String mentorName;
  final String mentorProfilePic;
  final String learnerId;
  final String learnerName;
  final String learnerProfilePic;
  final String skillName;
  final DateTime scheduledDateTime;
  final int durationMinutes;
  final String status; // 'requested', 'accepted', 'rejected', 'rescheduled', 'completed'
  final String meetLinkType; // 'Google Meet', 'Zoom', 'MS Teams'
  final String meetLink;
  final DateTime? rescheduledDateTime;
  final String? rescheduledBy;
  final String? aiSummary;

  SessionModel({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.mentorProfilePic,
    required this.learnerId,
    required this.learnerName,
    required this.learnerProfilePic,
    required this.skillName,
    required this.scheduledDateTime,
    this.durationMinutes = 60,
    this.status = 'requested',
    required this.meetLinkType,
    required this.meetLink,
    this.rescheduledDateTime,
    this.rescheduledBy,
    this.aiSummary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'mentorProfilePic': mentorProfilePic,
      'learnerId': learnerId,
      'learnerName': learnerName,
      'learnerProfilePic': learnerProfilePic,
      'skillName': skillName,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status,
      'meetLinkType': meetLinkType,
      'meetLink': meetLink,
      'rescheduledDateTime': rescheduledDateTime?.toIso8601String(),
      'rescheduledBy': rescheduledBy,
      'aiSummary': aiSummary,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] ?? '',
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      mentorProfilePic: map['mentorProfilePic'] ?? '',
      learnerId: map['learnerId'] ?? '',
      learnerName: map['learnerName'] ?? '',
      learnerProfilePic: map['learnerProfilePic'] ?? '',
      skillName: map['skillName'] ?? '',
      scheduledDateTime: map['scheduledDateTime'] != null
          ? DateTime.parse(map['scheduledDateTime'])
          : DateTime.now(),
      durationMinutes: map['durationMinutes'] ?? 60,
      status: map['status'] ?? 'requested',
      meetLinkType: map['meetLinkType'] ?? 'Google Meet',
      meetLink: map['meetLink'] ?? '',
      rescheduledDateTime: map['rescheduledDateTime'] != null
          ? DateTime.parse(map['rescheduledDateTime'])
          : null,
      rescheduledBy: map['rescheduledBy'],
      aiSummary: map['aiSummary'],
    );
  }

  SessionModel copyWith({
    String? id,
    String? mentorId,
    String? mentorName,
    String? mentorProfilePic,
    String? learnerId,
    String? learnerName,
    String? learnerProfilePic,
    String? skillName,
    DateTime? scheduledDateTime,
    int? durationMinutes,
    String? status,
    String? meetLinkType,
    String? meetLink,
    DateTime? rescheduledDateTime,
    String? rescheduledBy,
    String? aiSummary,
  }) {
    return SessionModel(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      mentorProfilePic: mentorProfilePic ?? this.mentorProfilePic,
      learnerId: learnerId ?? this.learnerId,
      learnerName: learnerName ?? this.learnerName,
      learnerProfilePic: learnerProfilePic ?? this.learnerProfilePic,
      skillName: skillName ?? this.skillName,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      meetLinkType: meetLinkType ?? this.meetLinkType,
      meetLink: meetLink ?? this.meetLink,
      rescheduledDateTime: rescheduledDateTime ?? this.rescheduledDateTime,
      rescheduledBy: rescheduledBy ?? this.rescheduledBy,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }
}
