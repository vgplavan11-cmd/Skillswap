import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/match_model.dart';
import '../models/session_model.dart';
import '../models/review_model.dart';
import '../models/badge_model.dart';
import '../models/leaderboard_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal() {
    _checkFirebase();
    _initMockData();
  }

  bool _useMock = true;
  FirebaseFirestore? _firestore;

  bool get isMockMode => _useMock;

  // Mock Database In-Memory Collections
  final Map<String, UserModel> _mockUsers = {};
  final List<SkillModel> _mockSkills = [];
  final List<MatchModel> _mockMatches = [];
  final List<SessionModel> _mockSessions = [];
  final List<ReviewModel> _mockReviews = [];
  final List<LeaderboardEntry> _mockLeaderboard = [];

  // Streams controller for real-time mocks
  final StreamController<List<SessionModel>> _sessionsStreamController = StreamController<List<SessionModel>>.broadcast();
  final StreamController<List<MatchModel>> _matchesStreamController = StreamController<List<MatchModel>>.broadcast();

  void _checkFirebase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _useMock = false;
        print("Firestore initialized successfully in live mode.");
      } else {
        _useMock = true;
        print("No Firebase app initialized. Firestore running in MOCK mode.");
      }
    } catch (e) {
      _useMock = true;
      print("Firebase initialization check failed. Firestore running in MOCK mode. Error: $e");
    }
  }

  void _initMockData() {
    if (!_useMock) return;

    // 1. Default Skills
    _mockSkills.addAll(popularSkills);

    // 2. Default Pre-Populated Users (Mentors & Learners)
    final mentor1 = UserModel(
      uid: 'mentor_navin',
      fullName: 'Navin Kumar',
      email: 'navin@skillswap.com',
      phoneNumber: '9876543210',
      collegeName: 'IIT Madras',
      department: 'Computer Science',
      city: 'Chennai',
      profilePicture: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      bio: 'ML Engineer at Google. Passionate about teaching Python, AI, and Machine Learning algorithms.',
      role: UserRole.mentor,
      skillsOffered: [
        OfferedSkill(skillName: 'Python Programming', category: 'Programming', level: 'Expert', experienceYears: 4),
        OfferedSkill(skillName: 'Machine Learning', category: 'AI & ML', level: 'Advanced', experienceYears: 2),
      ],
      skillsWanted: [
        OfferedSkill(skillName: 'Figma UI/UX Design', category: 'UI/UX Design', level: 'Beginner'),
      ],
      averageRating: 4.9,
      totalReviews: 12,
      badges: ['beginner_mentor', 'verified_mentor'],
      isVerifiedMentor: true,
      sessionsConducted: 14,
      availability: 'Weekends & Evenings',
      experienceYears: 4,
    );

    final mentor2 = UserModel(
      uid: 'mentor_priya',
      fullName: 'Priya Sharma',
      email: 'priya@skillswap.com',
      phoneNumber: '9876543211',
      collegeName: 'NID Ahmedabad',
      department: 'Communication Design',
      city: 'Ahmedabad',
      profilePicture: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      bio: 'Product Designer at Figma. Specializes in wireframing, high-fidelity prototypes, and user testing.',
      role: UserRole.mentor,
      skillsOffered: [
        OfferedSkill(skillName: 'Figma UI/UX Design', category: 'UI/UX Design', level: 'Expert', experienceYears: 3),
      ],
      skillsWanted: [
        OfferedSkill(skillName: 'Python Programming', category: 'Programming', level: 'Beginner'),
        OfferedSkill(skillName: 'Business Strategy', category: 'Business', level: 'Beginner'),
      ],
      averageRating: 4.7,
      totalReviews: 8,
      badges: ['beginner_mentor'],
      isVerifiedMentor: true,
      sessionsConducted: 9,
      availability: 'Mon, Wed, Fri Nights',
      experienceYears: 3,
    );

    final learner1 = UserModel(
      uid: 'learner_siddharth',
      fullName: 'Siddharth Roy',
      email: 'sid@skillswap.com',
      phoneNumber: '9876543212',
      collegeName: 'NIT Trichy',
      department: 'Electronics & Communication',
      city: 'Trichy',
      profilePicture: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      bio: 'Electronics student interested in building Embedded Systems. Want to learn Arduino and Microcontrollers.',
      role: UserRole.learner,
      skillsOffered: [
        OfferedSkill(skillName: 'Public Speaking', category: 'Communication', level: 'Intermediate', experienceYears: 1),
      ],
      skillsWanted: [
        OfferedSkill(skillName: 'Arduino Electronics', category: 'Electronics', level: 'Beginner'),
        OfferedSkill(skillName: 'Python Programming', category: 'Programming', level: 'Intermediate'),
      ],
      averageRating: 4.2,
      totalReviews: 2,
      badges: [],
      isVerifiedMentor: false,
      sessionsConducted: 0,
      availability: 'Flexible',
      experienceYears: 1,
    );

    _mockUsers[mentor1.uid] = mentor1;
    _mockUsers[mentor2.uid] = mentor2;
    _mockUsers[learner1.uid] = learner1;

    // 3. Mock Sessions
    _mockSessions.add(SessionModel(
      id: 'session_1',
      mentorId: 'mentor_navin',
      mentorName: 'Navin Kumar',
      mentorProfilePic: mentor1.profilePicture,
      learnerId: 'learner_siddharth',
      learnerName: 'Siddharth Roy',
      learnerProfilePic: learner1.profilePicture,
      skillName: 'Python Programming',
      scheduledDateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      durationMinutes: 60,
      status: 'accepted',
      meetLinkType: 'Google Meet',
      meetLink: 'https://meet.google.com/abc-defg-hij',
    ));

    _mockSessions.add(SessionModel(
      id: 'session_2',
      mentorId: 'mentor_priya',
      mentorName: 'Priya Sharma',
      mentorProfilePic: mentor2.profilePicture,
      learnerId: 'learner_siddharth',
      learnerName: 'Siddharth Roy',
      learnerProfilePic: learner1.profilePicture,
      skillName: 'Figma UI/UX Design',
      scheduledDateTime: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 60,
      status: 'completed',
      meetLinkType: 'Zoom',
      meetLink: 'https://zoom.us/j/1234567890',
      aiSummary: 'Completed core wireframing principles. Learner designed a basic mobile homepage layout.',
    ));

    // 4. Mock Reviews
    _mockReviews.add(ReviewModel(
      id: 'review_1',
      sessionId: 'session_2',
      reviewerId: 'learner_siddharth',
      reviewerName: 'Siddharth Roy',
      revieweeId: 'mentor_priya',
      lectureName: 'Figma UI/UX Design',
      overallRating: 5.0,
      teachingQuality: 5.0,
      communication: 5.0,
      knowledge: 5.0,
      helpfulness: 5.0,
      writtenReview: 'Excellent session! Priya explained auto-layout and component design very clearly. Recommended!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ));

    // 5. Build Mock Leaderboard
    _rebuildLeaderboard();
  }

  void _rebuildLeaderboard() {
    _mockLeaderboard.clear();
    _mockUsers.forEach((uid, user) {
      double score = LeaderboardEntry.calculateScore(
        sessions: user.sessionsConducted,
        rating: user.averageRating,
        badges: user.badges.length,
      );
      _mockLeaderboard.add(LeaderboardEntry(
        userId: uid,
        userName: user.fullName,
        userProfilePic: user.profilePicture,
        role: user.role == UserRole.mentor ? 'mentor' : 'learner',
        sessionsConducted: user.sessionsConducted,
        averageRating: user.averageRating,
        badgeCount: user.badges.length,
        calculatedScore: score,
      ));
    });
    // Sort descending by score
    _mockLeaderboard.sort((a, b) => b.calculatedScore.compareTo(a.calculatedScore));
  }

  // --- USER PROFILE OPERATIONS ---

  Future<void> createUserProfile(UserModel user) async {
    if (_useMock) {
      _mockUsers[user.uid] = user;
      _rebuildLeaderboard();
      return;
    }
    await _firestore!.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (_useMock) {
      return _mockUsers[uid];
    }
    final doc = await _firestore!.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (_useMock) {
      _mockUsers[user.uid] = user;
      _rebuildLeaderboard();
      return;
    }
    await _firestore!.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<List<UserModel>> getAllUsers() async {
    if (_useMock) {
      return _mockUsers.values.toList();
    }
    final snapshot = await _firestore!.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  // --- SKILLS OPERATIONS ---

  Future<List<SkillModel>> getSkills() async {
    if (_useMock) {
      return _mockSkills;
    }
    final snapshot = await _firestore!.collection('skills').get();
    return snapshot.docs.map((doc) => SkillModel.fromMap(doc.data())).toList();
  }

  // --- MATCHES OPERATIONS ---

  Future<void> createMatch(MatchModel match) async {
    if (_useMock) {
      _mockMatches.add(match);
      _matchesStreamController.add(_mockMatches);
      return;
    }
    await _firestore!.collection('matches').doc(match.id).set(match.toMap());
  }

  Stream<List<MatchModel>> streamUserMatches(String userId) {
    if (_useMock) {
      // Return a stream that filters matches involving userId
      Timer.run(() {
        final filtered = _mockMatches
            .where((m) => m.userOneId == userId || m.userTwoId == userId)
            .toList();
        _matchesStreamController.add(filtered);
      });
      return _matchesStreamController.stream.map((list) => list
          .where((m) => m.userOneId == userId || m.userTwoId == userId)
          .toList());
    }
    return _firestore!
        .collection('matches')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MatchModel.fromMap(doc.data()))
            .where((m) => m.userOneId == userId || m.userTwoId == userId)
            .toList());
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    if (_useMock) {
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        final m = _mockMatches[index];
        _mockMatches[index] = MatchModel(
          id: m.id,
          userOneId: m.userOneId,
          userTwoId: m.userTwoId,
          userOneName: m.userOneName,
          userTwoName: m.userTwoName,
          userOneProfilePic: m.userOneProfilePic,
          userTwoProfilePic: m.userTwoProfilePic,
          userOneSkillWanted: m.userOneSkillWanted,
          userTwoSkillWanted: m.userTwoSkillWanted,
          matchPercentage: m.matchPercentage,
          status: status,
          timestamp: m.timestamp,
        );
        _matchesStreamController.add(_mockMatches);
      }
      return;
    }
    await _firestore!.collection('matches').doc(matchId).update({'status': status});
  }

  // --- SESSIONS OPERATIONS ---

  Future<void> createSession(SessionModel session) async {
    if (_useMock) {
      _mockSessions.add(session);
      _sessionsStreamController.add(_mockSessions);
      return;
    }
    await _firestore!.collection('sessions').doc(session.id).set(session.toMap());
  }

  Stream<List<SessionModel>> streamUserSessions(String userId) {
    if (_useMock) {
      Timer.run(() {
        final filtered = _mockSessions
            .where((s) => s.mentorId == userId || s.learnerId == userId)
            .toList();
        _sessionsStreamController.add(filtered);
      });
      return _sessionsStreamController.stream.map((list) => list
          .where((s) => s.mentorId == userId || s.learnerId == userId)
          .toList());
    }
    // Check both roles
    return _firestore!
        .collection('sessions')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SessionModel.fromMap(doc.data()))
            .where((s) => s.mentorId == userId || s.learnerId == userId)
            .toList());
  }

  Future<void> updateSession(SessionModel session) async {
    if (_useMock) {
      final index = _mockSessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _mockSessions[index] = session;
        _sessionsStreamController.add(_mockSessions);
      }
      return;
    }
    await _firestore!.collection('sessions').doc(session.id).update(session.toMap());
  }

  // --- REVIEWS & RATING OPERATIONS ---

  Future<void> submitReview(ReviewModel review) async {
    if (_useMock) {
      _mockReviews.add(review);
      // Recalculate average rating for the reviewee
      final userReviews = _mockReviews.where((r) => r.revieweeId == review.revieweeId).toList();
      double sum = 0.0;
      for (var r in userReviews) {
        sum += r.overallRating;
      }
      double average = userReviews.isEmpty ? 0.0 : sum / userReviews.length;

      final user = _mockUsers[review.revieweeId];
      if (user != null) {
        // Conducted sessions increments if the review is on a mentor session
        int newConducted = user.sessionsConducted;
        if (user.role == UserRole.mentor) {
          newConducted++;
        }

        // Evaluate Badges dynamically
        List<String> userBadges = List.from(user.badges);
        _checkBadgeUnlocks(newConducted, average, userBadges);

        _mockUsers[review.revieweeId] = user.copyWith(
          averageRating: average,
          totalReviews: userReviews.length,
          sessionsConducted: newConducted,
          badges: userBadges,
        );
      }
      _rebuildLeaderboard();
      return;
    }

    // Live Firebase Transaction for atomic rating update
    final docRef = _firestore!.collection('reviews').doc(review.id);
    await docRef.set(review.toMap());

    final userRef = _firestore!.collection('users').doc(review.revieweeId);
    await _firestore!.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (userSnap.exists) {
        final userData = userSnap.data()!;
        int currentTotal = userData['totalReviews'] ?? 0;
        double currentAvg = (userData['averageRating'] ?? 0.0).toDouble();
        int currentSessions = userData['sessionsConducted'] ?? 0;

        int newTotal = currentTotal + 1;
        double newAvg = ((currentAvg * currentTotal) + review.overallRating) / newTotal;
        int newSessions = userData['role'] == 'mentor' ? currentSessions + 1 : currentSessions;

        List<String> badges = List<String>.from(userData['badges'] ?? []);
        _checkBadgeUnlocks(newSessions, newAvg, badges);

        transaction.update(userRef, {
          'totalReviews': newTotal,
          'averageRating': newAvg,
          'sessionsConducted': newSessions,
          'badges': badges,
        });
      }
    });
  }

  static void _checkBadgeUnlocks(int sessions, double rating, List<String> currentBadges) {
    for (var systemBadge in systemBadges) {
      if (currentBadges.contains(systemBadge.id)) continue;

      bool qualifies = false;
      if (systemBadge.id == 'beginner_mentor' && sessions >= 3) {
        qualifies = true;
      } else if (systemBadge.id == 'verified_mentor' && sessions >= 10 && rating >= 4.5) {
        qualifies = true;
      } else if (systemBadge.id == 'top_educator' && sessions >= 50 && rating >= 4.8) {
        qualifies = true;
      } else if (systemBadge.id == 'skill_master' && sessions >= 100) {
        qualifies = true;
      }

      if (qualifies) {
        currentBadges.add(systemBadge.id);
      }
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    if (_useMock) {
      return _mockReviews.where((r) => r.revieweeId == userId).toList();
    }
    final snapshot = await _firestore!
        .collection('reviews')
        .where('revieweeId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
  }

  // --- LEADERBOARD & ANALYTICS ---

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    if (_useMock) {
      return _mockLeaderboard;
    }
    // Query active mentors/learners sorted by score
    // In live Firebase, this can be read from a precalculated 'leaderboard' collection or query sorted users
    final snapshot = await _firestore!
        .collection('users')
        .orderBy('sessionsConducted', descending: true)
        .limit(20)
        .get();

    final entries = snapshot.docs.map((doc) {
      final user = UserModel.fromMap(doc.data());
      final score = LeaderboardEntry.calculateScore(
        sessions: user.sessionsConducted,
        rating: user.averageRating,
        badges: user.badges.length,
      );
      return LeaderboardEntry(
        userId: user.uid,
        userName: user.fullName,
        userProfilePic: user.profilePicture,
        role: user.role.toString().split('.').last,
        sessionsConducted: user.sessionsConducted,
        averageRating: user.averageRating,
        badgeCount: user.badges.length,
        calculatedScore: score,
      );
    }).toList();

    entries.sort((a, b) => b.calculatedScore.compareTo(a.calculatedScore));
    return entries;
  }

  // --- ADMIN ACTIONS ---

  Future<void> toggleUserVerification(String uid, bool isVerified) async {
    if (_useMock) {
      final user = _mockUsers[uid];
      if (user != null) {
        _mockUsers[uid] = user.copyWith(isVerifiedMentor: isVerified);
        _rebuildLeaderboard();
      }
      return;
    }
    await _firestore!.collection('users').doc(uid).update({'isVerifiedMentor': isVerified});
  }

  Future<void> flagReview(String reviewId, bool isFake) async {
    if (_useMock) {
      final index = _mockReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final r = _mockReviews[index];
        _mockReviews[index] = ReviewModel(
          id: r.id,
          sessionId: r.sessionId,
          reviewerId: r.reviewerId,
          reviewerName: r.reviewerName,
          revieweeId: r.revieweeId,
          lectureName: r.lectureName,
          overallRating: r.overallRating,
          teachingQuality: r.teachingQuality,
          communication: r.communication,
          knowledge: r.knowledge,
          helpfulness: r.helpfulness,
          writtenReview: r.writtenReview,
          isFlaggedFake: isFake,
          timestamp: r.timestamp,
        );
      }
      return;
    }
    await _firestore!.collection('reviews').doc(reviewId).update({'isFlaggedFake': isFake});
  }

  Future<void> deleteUserAccount(String uid) async {
    if (_useMock) {
      _mockUsers.remove(uid);
      _rebuildLeaderboard();
      return;
    }
    await _firestore!.collection('users').doc(uid).delete();
  }
}
