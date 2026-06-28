import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final _uuid = const Uuid();

  List<ChatModel> _chats = [];
  final Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  String? _error;

  // Active sub-streams
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  final Map<String, StreamSubscription<List<MessageModel>>> _messagesSubscriptions = {};

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MessageModel> getMessagesForChat(String chatId) {
    return _messages[chatId] ?? [];
  }

  void subscribeToChats(String userId) {
    _chatsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _chatsSubscription = _chatService.streamChats(userId).listen((chatList) {
      _chats = chatList;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void subscribeToMessages(String chatId) {
    if (_messagesSubscriptions.containsKey(chatId)) return;

    _messagesSubscriptions[chatId] = _chatService.streamMessages(chatId).listen((msgList) {
      _messages[chatId] = msgList;
      notifyListeners();
    }, onError: (err) {
      _error = err.toString();
      notifyListeners();
    });
  }

  Future<String> startChat(UserModel currentUser, UserModel otherUser) async {
    final chatId = await _chatService.getOrCreateChat(currentUser, otherUser);
    subscribeToMessages(chatId);
    return chatId;
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final message = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(chatId, message);
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String imageUrl,
  }) async {
    final message = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      text: '📷 Photo Shared',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(chatId, message);
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _chatService.markAsRead(chatId, userId);
  }

  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    await _chatService.updateTypingStatus(chatId, userId, isTyping);
  }

  Future<void> updateOnlineStatus(String chatId, String userId, bool isOnline) async {
    await _chatService.updateOnlineStatus(chatId, userId, isOnline);
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _messagesSubscriptions.forEach((key, sub) => sub.cancel());
    super.dispose();
  }
}
