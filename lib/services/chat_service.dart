import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal() {
    _checkFirebase();
    _initMockChats();
  }

  bool _useMock = true;
  FirebaseFirestore? _firestore;

  // Mock chats store
  final List<ChatModel> _mockChats = [];
  final Map<String, List<MessageModel>> _mockMessages = {}; // chatId -> List of messages

  // Stream controllers
  final StreamController<List<ChatModel>> _chatsStreamController = StreamController<List<ChatModel>>.broadcast();
  final Map<String, StreamController<List<MessageModel>>> _messageStreamControllers = {};

  void _checkFirebase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _useMock = false;
      }
    } catch (_) {}
  }

  void _initMockChats() {
    // Populate some default chat entries
    final chat1 = ChatModel(
      id: 'chat_1',
      participantIds: ['learner_siddharth', 'mentor_navin'],
      participantNames: {
        'learner_siddharth': 'Siddharth Roy',
        'mentor_navin': 'Navin Kumar',
      },
      participantProfilePics: {
        'learner_siddharth': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
        'mentor_navin': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      },
      lastMessage: 'Hi Siddharth, our Python session is scheduled for tomorrow!',
      lastMessageSenderId: 'mentor_navin',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCounts: {'learner_siddharth': 1, 'mentor_navin': 0},
      onlineStatus: {'learner_siddharth': true, 'mentor_navin': false},
      typingStatus: {'learner_siddharth': false, 'mentor_navin': false},
    );

    _mockChats.add(chat1);

    _mockMessages[chat1.id] = [
      MessageModel(
        id: 'msg_1',
        senderId: 'learner_siddharth',
        senderName: 'Siddharth Roy',
        text: 'Hello Navin, looking forward to learning Python fundamentals.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_2',
        senderId: 'mentor_navin',
        senderName: 'Navin Kumar',
        text: 'Hi Siddharth, our Python session is scheduled for tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ];
  }

  // --- STREAM USER CONVERSATIONS ---

  Stream<List<ChatModel>> streamChats(String userId) {
    if (_useMock) {
      Timer.run(() {
        final userChats = _mockChats.where((c) => c.participantIds.contains(userId)).toList();
        _chatsStreamController.add(userChats);
      });
      return _chatsStreamController.stream.map((list) =>
          list.where((c) => c.participantIds.contains(userId)).toList());
    }
    return _firestore!
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatModel.fromMap(doc.data())).toList());
  }

  // --- STREAM MESSAGES IN A CONVERSATION ---

  Stream<List<MessageModel>> streamMessages(String chatId) {
    if (_useMock) {
      if (!_messageStreamControllers.containsKey(chatId)) {
        _messageStreamControllers[chatId] = StreamController<List<MessageModel>>.broadcast();
      }
      Timer.run(() {
        final msgs = _mockMessages[chatId] ?? [];
        _messageStreamControllers[chatId]!.add(msgs);
      });
      return _messageStreamControllers[chatId]!.stream;
    }
    return _firestore!
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MessageModel.fromMap(doc.data())).toList());
  }

  // --- SEND MESSAGE ---

  Future<void> sendMessage(String chatId, MessageModel message) async {
    if (_useMock) {
      // Append message
      _mockMessages.putIfAbsent(chatId, () => []);
      _mockMessages[chatId]!.add(message);

      // Update chat last message
      final index = _mockChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final c = _mockChats[index];
        final Map<String, int> unreads = Map.from(c.unreadCounts);
        // Increment unread count for other participants
        for (var pId in c.participantIds) {
          if (pId != message.senderId) {
            unreads[pId] = (unreads[pId] ?? 0) + 1;
          }
        }

        _mockChats[index] = ChatModel(
          id: c.id,
          participantIds: c.participantIds,
          participantNames: c.participantNames,
          participantProfilePics: c.participantProfilePics,
          lastMessage: message.text,
          lastMessageSenderId: message.senderId,
          lastMessageTime: message.timestamp,
          unreadCounts: unreads,
          onlineStatus: c.onlineStatus,
          typingStatus: c.typingStatus,
        );
      }

      // Broadcast updates
      _chatsStreamController.add(_mockChats);
      if (_messageStreamControllers.containsKey(chatId)) {
        _messageStreamControllers[chatId]!.add(_mockMessages[chatId]!);
      }

      // Simulate a quick AI response if sending a message to Navin Kumar
      if (chatId == 'chat_1' && message.senderId == 'learner_siddharth') {
        _simulateMentorReply(chatId, 'mentor_navin', 'Navin Kumar');
      }
      return;
    }

    final batch = _firestore!.batch();
    final msgDoc = _firestore!
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id);

    batch.set(msgDoc, message.toMap());

    // Update parent chat doc
    final chatDoc = _firestore!.collection('chats').doc(chatId);
    batch.update(chatDoc, {
      'lastMessage': message.text,
      'lastMessageSenderId': message.senderId,
      'lastMessageTime': message.timestamp.toIso8601String(),
    });

    await batch.commit();
  }

  void _simulateMentorReply(String chatId, String mentorId, String mentorName) {
    Future.delayed(const Duration(seconds: 2), () {
      final reply = MessageModel(
        id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
        senderId: mentorId,
        senderName: mentorName,
        text: 'Awesome, I am ready. See you tomorrow at the Google Meet link in our Session schedules!',
        timestamp: DateTime.now(),
      );
      _mockMessages[chatId]!.add(reply);

      String recipientId = 'learner_siddharth';
      final index = _mockChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final c = _mockChats[index];
        recipientId = c.participantIds.firstWhere((id) => id != mentorId, orElse: () => recipientId);
        final Map<String, int> unreads = Map.from(c.unreadCounts);
        unreads[recipientId] = (unreads[recipientId] ?? 0) + 1;

        _mockChats[index] = ChatModel(
          id: c.id,
          participantIds: c.participantIds,
          participantNames: c.participantNames,
          participantProfilePics: c.participantProfilePics,
          lastMessage: reply.text,
          lastMessageSenderId: reply.senderId,
          lastMessageTime: reply.timestamp,
          unreadCounts: unreads,
          onlineStatus: c.onlineStatus,
          typingStatus: c.typingStatus,
        );
      }

      _chatsStreamController.add(_mockChats);
      if (_messageStreamControllers.containsKey(chatId)) {
        _messageStreamControllers[chatId]!.add(_mockMessages[chatId]!);
      }

      // Trigger foreground/local notification banner
      NotificationService().triggerLocalNotification(
        recipientId,
        'New message from $mentorName',
        reply.text,
        'new_message',
      );
    });
  }

  // --- ACTIONS ---

  Future<void> markAsRead(String chatId, String userId) async {
    if (_useMock) {
      final index = _mockChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final c = _mockChats[index];
        final unreads = Map<String, int>.from(c.unreadCounts);
        unreads[userId] = 0;

        _mockChats[index] = ChatModel(
          id: c.id,
          participantIds: c.participantIds,
          participantNames: c.participantNames,
          participantProfilePics: c.participantProfilePics,
          lastMessage: c.lastMessage,
          lastMessageSenderId: c.lastMessageSenderId,
          lastMessageTime: c.lastMessageTime,
          unreadCounts: unreads,
          onlineStatus: c.onlineStatus,
          typingStatus: c.typingStatus,
        );
        _chatsStreamController.add(_mockChats);
      }
      return;
    }
    // Update unread count for this user to 0
    await _firestore!.collection('chats').doc(chatId).update({
      'unreadCounts.$userId': 0,
    });
  }

  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) async {
    if (_useMock) {
      final index = _mockChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final c = _mockChats[index];
        final typings = Map<String, bool>.from(c.typingStatus);
        typings[userId] = isTyping;

        _mockChats[index] = ChatModel(
          id: c.id,
          participantIds: c.participantIds,
          participantNames: c.participantNames,
          participantProfilePics: c.participantProfilePics,
          lastMessage: c.lastMessage,
          lastMessageSenderId: c.lastMessageSenderId,
          lastMessageTime: c.lastMessageTime,
          unreadCounts: c.unreadCounts,
          onlineStatus: c.onlineStatus,
          typingStatus: typings,
        );
        _chatsStreamController.add(_mockChats);
      }
      return;
    }
    await _firestore!.collection('chats').doc(chatId).update({
      'typingStatus.$userId': isTyping,
    });
  }

  Future<void> updateOnlineStatus(String chatId, String userId, bool isOnline) async {
    if (_useMock) {
      final index = _mockChats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        final c = _mockChats[index];
        final onlines = Map<String, bool>.from(c.onlineStatus);
        onlines[userId] = isOnline;

        _mockChats[index] = ChatModel(
          id: c.id,
          participantIds: c.participantIds,
          participantNames: c.participantNames,
          participantProfilePics: c.participantProfilePics,
          lastMessage: c.lastMessage,
          lastMessageSenderId: c.lastMessageSenderId,
          lastMessageTime: c.lastMessageTime,
          unreadCounts: c.unreadCounts,
          onlineStatus: onlines,
          typingStatus: c.typingStatus,
        );
        _chatsStreamController.add(_mockChats);
      }
      return;
    }
    await _firestore!.collection('chats').doc(chatId).update({
      'onlineStatus.$userId': isOnline,
    });
  }

  Future<String> getOrCreateChat(UserModel userOne, UserModel userTwo) async {
    final chatId = '${userOne.uid}_${userTwo.uid}';
    final reversedChatId = '${userTwo.uid}_${userOne.uid}';

    if (_useMock) {
      final existIndex = _mockChats.indexWhere((c) => c.id == chatId || c.id == reversedChatId);
      if (existIndex != -1) {
        return _mockChats[existIndex].id;
      }
      final newChat = ChatModel(
        id: chatId,
        participantIds: [userOne.uid, userTwo.uid],
        participantNames: {
          userOne.uid: userOne.fullName,
          userTwo.uid: userTwo.fullName,
        },
        participantProfilePics: {
          userOne.uid: userOne.profilePicture,
          userTwo.uid: userTwo.profilePicture,
        },
        lastMessage: 'Chat started.',
        lastMessageSenderId: userOne.uid,
        lastMessageTime: DateTime.now(),
        unreadCounts: {userOne.uid: 0, userTwo.uid: 0},
      );
      _mockChats.add(newChat);
      _mockMessages[chatId] = [];
      _chatsStreamController.add(_mockChats);
      return chatId;
    }

    final doc = await _firestore!.collection('chats').doc(chatId).get();
    if (doc.exists) return chatId;

    final revDoc = await _firestore!.collection('chats').doc(reversedChatId).get();
    if (revDoc.exists) return reversedChatId;

    final newChat = ChatModel(
      id: chatId,
      participantIds: [userOne.uid, userTwo.uid],
      participantNames: {
        userOne.uid: userOne.fullName,
        userTwo.uid: userTwo.fullName,
      },
      participantProfilePics: {
        userOne.uid: userOne.profilePicture,
        userTwo.uid: userTwo.profilePicture,
      },
      lastMessage: 'Chat started.',
      lastMessageSenderId: userOne.uid,
      lastMessageTime: DateTime.now(),
      unreadCounts: {userOne.uid: 0, userTwo.uid: 0},
    );

    await _firestore!.collection('chats').doc(chatId).set(newChat.toMap());
    return chatId;
  }
}
