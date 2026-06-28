import 'dart:async';
import 'firestore_service.dart';
import '../models/session_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> requestSession({
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
    // Generate typical virtual link
    String meetLink = '';
    if (meetLinkType == 'Google Meet') {
      meetLink = 'https://meet.google.com/qsw-hxrd-uvb';
    } else if (meetLinkType == 'Zoom') {
      meetLink = 'https://zoom.us/j/9876543210';
    } else if (meetLinkType == 'MS Teams') {
      meetLink = 'https://teams.microsoft.com/l/meetup-join/19%3ameeting_xyz';
    } else {
      meetLink = '';
    }

    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = SessionModel(
      id: id,
      mentorId: mentorId,
      mentorName: mentorName,
      mentorProfilePic: mentorProfilePic,
      learnerId: learnerId,
      learnerName: learnerName,
      learnerProfilePic: learnerProfilePic,
      skillName: skillName,
      scheduledDateTime: scheduledDateTime,
      status: 'requested',
      meetLinkType: meetLinkType,
      meetLink: meetLink,
    );

    await _firestoreService.createSession(session);
  }

  Future<void> acceptSession(SessionModel session) async {
    final updatedSession = session.copyWith(status: 'accepted');
    await _firestoreService.updateSession(updatedSession);
  }

  Future<void> rejectSession(SessionModel session) async {
    final updatedSession = session.copyWith(status: 'rejected');
    await _firestoreService.updateSession(updatedSession);
  }

  Future<void> rescheduleSession(SessionModel session, DateTime newDateTime, String requestedBy) async {
    final updatedSession = session.copyWith(
      status: 'rescheduled',
      rescheduledDateTime: newDateTime,
      rescheduledBy: requestedBy,
    );
    await _firestoreService.updateSession(updatedSession);
  }

  Future<void> acceptReschedule(SessionModel session) async {
    if (session.rescheduledDateTime == null) return;
    final updatedSession = session.copyWith(
      status: 'accepted',
      scheduledDateTime: session.rescheduledDateTime!,
      rescheduledDateTime: null,
      rescheduledBy: null,
    );
    await _firestoreService.updateSession(updatedSession);
  }

  Future<void> completeSession(SessionModel session, {String? aiSummary}) async {
    final updatedSession = session.copyWith(
      status: 'completed',
      aiSummary: aiSummary ?? 'AI Summary: The peer exchange was highly interactive, covering core objectives and next learning milestones.',
    );
    await _firestoreService.updateSession(updatedSession);
  }

  Stream<List<SessionModel>> getSessionsStream(String userId) {
    return _firestoreService.streamUserSessions(userId);
  }
}
