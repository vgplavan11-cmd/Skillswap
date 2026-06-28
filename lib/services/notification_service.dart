import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _checkFirebase();
  }

  bool _useMock = true;
  FirebaseMessaging? _messaging;

  // Stream for UI notifications banner updates
  final StreamController<NotificationModel> _inAppNotificationStream = StreamController<NotificationModel>.broadcast();
  final List<NotificationModel> _mockNotifications = [];
  final StreamController<List<NotificationModel>> _userNotificationsStream = StreamController<List<NotificationModel>>.broadcast();

  Stream<NotificationModel> get inAppNotifications => _inAppNotificationStream.stream;

  void _checkFirebase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _messaging = FirebaseMessaging.instance;
        _useMock = false;
        _initFirebaseMessaging();
      }
    } catch (_) {}
  }

  Future<void> initialize(String userId) async {
    if (_useMock) {
      print("NotificationService: Running in Mock Mode.");
      // Prepopulate a mock notification
      _mockNotifications.add(NotificationModel(
        id: 'notif_1',
        userId: userId,
        title: 'Welcome to SkillSwap!',
        body: 'Start by updating your offered and wanted skills in the Profile tab to find matches.',
        type: 'general',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ));
      _userNotificationsStream.add(_mockNotifications);
      return;
    }

    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted messaging permission: ${settings.authorizationStatus}');

      // Get FCM token
      String? token = await _messaging!.getToken();
      print("FCM Token: $token");
      // Save this token to the user profile in Firestore
    } catch (e) {
      print("Error initializing FCM messaging: $e");
    }
  }

  void _initFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        final notif = NotificationModel(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current',
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          type: message.data['type'] ?? 'general',
          data: message.data,
          timestamp: DateTime.now(),
        );
        _inAppNotificationStream.add(notif);
        _mockNotifications.insert(0, notif);
        _userNotificationsStream.add(_mockNotifications);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! Type: ${message.data['type']}');
    });
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    // Return stream of notifications for the user
    Timer.run(() {
      _userNotificationsStream.add(_mockNotifications.where((n) => n.userId == userId).toList());
    });
    return _userNotificationsStream.stream;
  }

  Future<void> triggerLocalNotification(String userId, String title, String body, String type) async {
    final notif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
    );
    _mockNotifications.insert(0, notif);
    _userNotificationsStream.add(_mockNotifications.where((n) => n.userId == userId).toList());
    _inAppNotificationStream.add(notif);
  }

  Future<void> scheduleSessionReminders(String userId, String partnerName, DateTime sessionTime) async {
    // Simulate push notification schedule logs
    print("Scheduling session reminders for $partnerName's session at $sessionTime:");
    print("- 24 Hours Before: Notification Scheduled");
    print("- 1 Hour Before: Notification Scheduled");
    print("- 15 Minutes Before: Notification Scheduled");

    // Immediately trigger a test scheduler log alert
    await triggerLocalNotification(
      userId,
      'Session Scheduled!',
      'Your session with $partnerName is booked for ${sessionTime.hour}:${sessionTime.minute}. Reminders are set.',
      'session_reminder',
    );
  }
}
