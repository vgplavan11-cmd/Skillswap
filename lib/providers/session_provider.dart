import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/review_model.dart';
import '../services/session_service.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _sessionService = SessionService();
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<SessionModel>>? _sessionsSubscription;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SessionModel> get upcomingSessions {
    return _sessions.where((s) => s.status != 'completed' && s.status != 'rejected').toList();
  }

  List<SessionModel> get completedSessions {
    return _sessions.where((s) => s.status == 'completed').toList();
  }

  void subscribeToSessions(String userId) {
    _sessionsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _sessionsSubscription = _sessionService.getSessionsStream(userId).listen((sessionList) {
      _sessions = sessionList;
      _sessions.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> bookSession({
    required String mentorId,
    required String mentorName,
    required String mentorProfilePic,
    required String learnerId,
    required String learnerName,
    required String learnerProfilePic,
    required String skillName,
    required DateTime scheduledDateTime,
    required String meetLinkType,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _sessionService.requestSession(
        mentorId: mentorId,
        mentorName: mentorName,
        mentorProfilePic: mentorProfilePic,
        learnerId: learnerId,
        learnerName: learnerName,
        learnerProfilePic: learnerProfilePic,
        skillName: skillName,
        scheduledDateTime: scheduledDateTime,
        meetLinkType: meetLinkType,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptSessionRequest(SessionModel session) async {
    await _sessionService.acceptSession(session);
  }

  Future<void> rejectSessionRequest(SessionModel session) async {
    await _sessionService.rejectSession(session);
  }

  Future<void> requestReschedule(SessionModel session, DateTime newDateTime, String requestedBy) async {
    await _sessionService.rescheduleSession(session, newDateTime, requestedBy);
  }

  Future<void> acceptRescheduleRequest(SessionModel session) async {
    await _sessionService.acceptReschedule(session);
  }

  Future<void> completeActiveSession(SessionModel session, {String? summary}) async {
    await _sessionService.completeSession(session, aiSummary: summary);
  }

  Future<bool> submitSessionReview({
    required String sessionId,
    required String reviewerId,
    required String reviewerName,
    required String revieweeId,
    required String lectureName,
    required double teachingQuality,
    required double communication,
    required double knowledge,
    required double helpfulness,
    required String writtenReview,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final overall = (teachingQuality + communication + knowledge + helpfulness) / 4.0;
      final review = ReviewModel(
        id: _uuid.v4(),
        sessionId: sessionId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        revieweeId: revieweeId,
        lectureName: lectureName,
        overallRating: double.parse(overall.toStringAsFixed(1)),
        teachingQuality: teachingQuality,
        communication: communication,
        knowledge: knowledge,
        helpfulness: helpfulness,
        writtenReview: writtenReview,
        timestamp: DateTime.now(),
      );

      await _firestoreService.submitReview(review);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
