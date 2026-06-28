import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/neumorphic_container.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String peerId;
  final String peerName;
  final String peerPic;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.peerName,
    required this.peerPic,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser!.uid;
      final chatProv = Provider.of<ChatProvider>(context, listen: false);
      chatProv.subscribeToMessages(widget.chatId);
      
      // Set online status to true
      chatProv.updateOnlineStatus(widget.chatId, _currentUserId, true);
    });
  }

  @override
  void dispose() {
    // Set online status to false
    final chatProv = Provider.of<ChatProvider>(context, listen: false);
    chatProv.updateOnlineStatus(widget.chatId, _currentUserId, false);
    chatProv.setTypingStatus(widget.chatId, _currentUserId, false);

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    chatProv.sendTextMessage(
      chatId: widget.chatId,
      senderId: _currentUserId,
      senderName: authProv.currentUser!.fullName,
      text: text,
    );

    _messageController.clear();
    chatProv.setTypingStatus(widget.chatId, _currentUserId, false);
    _scrollToBottom();
  }

  void _sendMockImage() {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    chatProv.sendImageMessage(
      chatId: widget.chatId,
      senderId: _currentUserId,
      senderName: authProv.currentUser!.fullName,
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProv = Provider.of<ChatProvider>(context);
    final messages = chatProv.getMessagesForChat(widget.chatId);

    // Watch for typing indicator of peer
    bool isPeerTyping = false;
    try {
      final activeChat = chatProv.chats.firstWhere((c) => c.id == widget.chatId);
      isPeerTyping = activeChat.typingStatus[widget.peerId] ?? false;
    } catch (_) {}

    // Auto-scroll on initial load or new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.0,
              backgroundImage: NetworkImage(widget.peerPic),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(
                  isPeerTyping ? 'typing...' : 'Online',
                  style: TextStyle(fontSize: 10.0, color: isPeerTyping ? theme.colorScheme.primary : Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Message Bubble list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == _currentUserId;
                return _buildMessageBubble(message, isMe, theme, isDark);
              },
            ),
          ),

          // Typing Indicator Display
          if (isPeerTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.peerName} is typing...',
                  style: TextStyle(fontSize: 11.0, color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                ),
              ),
            ),

          // 2. Input Box Area (Floating Neumorphic Capsule)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 16.0, top: 8.0),
            child: NeumorphicContainer(
              borderRadius: 24.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo, color: theme.colorScheme.primary),
                    onPressed: _sendMockImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: theme.colorScheme.primary),
                    onPressed: () {
                      // Insert a mock emoji in input
                      _messageController.text += '😊';
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onChanged: (val) {
                        // Toggle typing status
                        chatProv.setTypingStatus(widget.chatId, _currentUserId, val.isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  NeumorphicContainer(
                    borderRadius: 20.0,
                    color: theme.colorScheme.primary,
                    onTap: _sendMessage,
                    padding: const EdgeInsets.all(10.0),
                    child: const Icon(Icons.send, color: Colors.white, size: 18.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, ThemeData theme, bool isDark) {
    final bubbleColor = isMe
        ? theme.colorScheme.primary
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final textColor = isMe 
        ? Colors.white 
        : (isDark ? Colors.white : Colors.black);

    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isMe ? 16.0 : 4.0),
            bottomRight: Radius.circular(isMe ? 4.0 : 16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  message.imageUrl!,
                  height: 150.0,
                  width: double.infinity,
                  fit: fitCover,
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            _buildMessageText(message.text, isMe, theme),
            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 9.0),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    color: Colors.white70,
                    size: 11.0,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(String text, bool isMe, ThemeData theme) {
    final textColor = isMe ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(color: textColor, fontSize: 14.0),
      );
    }

    final List<InlineSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(color: textColor, fontSize: 14.0),
        ));
      }

      final urlString = match.group(0)!;
      spans.add(TextSpan(
        text: urlString,
        style: TextStyle(
          color: isMe ? Colors.lightBlueAccent[100] : theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.tryParse(urlString);
            if (uri != null) {
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  // Fallback: Copy to clipboard
                  Clipboard.setData(ClipboardData(text: urlString));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open link. Copied to clipboard.')),
                    );
                  }
                }
              } catch (_) {
                Clipboard.setData(ClipboardData(text: urlString));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied link to clipboard!')),
                  );
                }
              }
            }
          },
      ));

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: TextStyle(color: textColor, fontSize: 14.0),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  BoxFit get fitCover => BoxFit.cover;
}
