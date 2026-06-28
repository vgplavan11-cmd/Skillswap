class ReviewModel {
  final String id;
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String lectureName;
  final double overallRating;
  final double teachingQuality; // 1 to 5
  final double communication;    // 1 to 5
  final double knowledge;        // 1 to 5
  final double helpfulness;      // 1 to 5
  final String writtenReview;
  final bool isFlaggedFake;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.sessionId,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.lectureName,
    required this.overallRating,
    required this.teachingQuality,
    required this.communication,
    required this.knowledge,
    required this.helpfulness,
    required this.writtenReview,
    this.isFlaggedFake = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'lectureName': lectureName,
      'overallRating': overallRating,
      'teachingQuality': teachingQuality,
      'communication': communication,
      'knowledge': knowledge,
      'helpfulness': helpfulness,
      'writtenReview': writtenReview,
      'isFlaggedFake': isFlaggedFake,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      lectureName: map['lectureName'] ?? '',
      overallRating: (map['overallRating'] ?? 0.0).toDouble(),
      teachingQuality: (map['teachingQuality'] ?? 0.0).toDouble(),
      communication: (map['communication'] ?? 0.0).toDouble(),
      knowledge: (map['knowledge'] ?? 0.0).toDouble(),
      helpfulness: (map['helpfulness'] ?? 0.0).toDouble(),
      writtenReview: map['writtenReview'] ?? '',
      isFlaggedFake: map['isFlaggedFake'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
