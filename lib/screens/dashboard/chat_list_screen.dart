import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neumorphic_container.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<ChatProvider>(context, listen: false).subscribeToChats(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final chatProv = Provider.of<ChatProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox Chats', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: chatProv.isLoading
          ? const MentorListSkeleton()
          : chatProv.chats.isEmpty
              ? const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No Chats Yet',
                  description: 'Select a mentor in the Skill Marketplace or a match recommendation and request a skill swap to start chatting.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatProv.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatProv.chats[index];
                    
                    // Identify other participant
                    final otherId = chat.participantIds.firstWhere((id) => id != user.uid);
                    final otherName = chat.participantNames[otherId] ?? 'Peer Learner';
                    final otherPic = chat.participantProfilePics[otherId] ?? '';

                    final unreadCount = chat.unreadCounts[user.uid] ?? 0;
                    final isOnline = chat.onlineStatus[otherId] ?? false;
                    final isTyping = chat.typingStatus[otherId] ?? false;

                    return NeumorphicContainer(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      borderRadius: 16.0,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      onTap: () {
                        // Mark as read
                        chatProv.markMessagesAsRead(chat.id, user.uid);
                        // Navigate to chat detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chat.id,
                              peerId: otherId,
                              peerName: otherName,
                              peerPic: otherPic,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 26.0,
                                backgroundImage: NetworkImage(otherPic),
                              ),
                              if (isOnline)
                                Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Container(
                                    height: 12.0,
                                    width: 12.0,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  isTyping 
                                      ? 'typing...' 
                                      : chat.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: isTyping 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(chat.lastMessageTime),
                                style: TextStyle(fontSize: 10.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(height: 6.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
