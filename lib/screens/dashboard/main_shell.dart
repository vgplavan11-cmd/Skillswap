import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/notification_service.dart';
import 'home_dashboard.dart';
import 'skills_marketplace.dart';
import 'chat_list_screen.dart';
import 'sessions_screen.dart';
import 'profile_screen.dart';
import '../../widgets/neumorphic_container.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeDashboard(),
      const SkillsMarketplace(),
      const ChatListScreen(),
      const SessionsScreen(),
      const ProfileScreen(),
    ];

    // Initialize real-time listeners for authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<ChatProvider>(context, listen: false).subscribeToChats(user.uid);
        Provider.of<SessionProvider>(context, listen: false).subscribeToSessions(user.uid);
        _notificationService.initialize(user.uid);

        // Listen for in-app alert banner popups
        _notificationService.inAppNotifications.listen((notif) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      notif.type == 'new_message' ? Icons.chat : Icons.notifications_active,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                          Text(notif.body, style: const TextStyle(fontSize: 11.0)),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    // Calculate total unread chats
    int totalUnreads = 0;
    if (user != null) {
      for (var chat in chatProvider.chats) {
        totalUnreads += chat.unreadCounts[user.uid] ?? 0;
      }
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 84.0, // Constrain container height to prevent any vertical stretching
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
        child: NeumorphicContainer(
          height: 60.0, // Constrain the neumorphic capsule height
          borderRadius: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.explore_outlined, Icons.explore, 'Discover'),
              _buildNavItem(3, Icons.calendar_month_outlined, Icons.calendar_month, 'Sessions'),
              _buildNavItem(2, Icons.chat_outlined, Icons.chat, 'Chat', badgeCount: totalUnreads),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label, {int badgeCount = 0}) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: isSelected
            ? BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.0),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey[500],
                    size: 22.0,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 8.0 : 0.0,
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Text(
                        label,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
