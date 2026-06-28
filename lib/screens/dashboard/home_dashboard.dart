import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../models/skill_model.dart';
import 'matching_screen.dart';
import 'leaderboard_screen.dart';
import 'ai_features_screen.dart';
import 'live_classes_screen.dart';
import 'edit_profile_screen.dart';
import '../admin/admin_dashboard.dart';
import '../../widgets/session_card.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/avatar_helper.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        final matchingProv = Provider.of<MatchingProvider>(context, listen: false);
        matchingProv.loadMatches(user);
        matchingProv.subscribeToUserMatches(user.uid);
        matchingProv.loadAllMentors();
        matchingProv.loadLeaderboard();
      }
    });
  }

  void _refresh() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      final matchingProv = Provider.of<MatchingProvider>(context, listen: false);
      matchingProv.loadMatches(user);
      matchingProv.subscribeToUserMatches(user.uid);
      Provider.of<SessionProvider>(context, listen: false).subscribeToSessions(user.uid);
    }
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final mockNotifications = [
      {
        'title': 'New Swap Connection',
        'body': 'Priya Sharma accepted your swap request. Start chatting now!',
        'time': '10 mins ago',
        'icon': Icons.handshake,
        'color': Colors.green,
      },
      {
        'title': 'Session Booked Successfully',
        'body': 'Your Python Programming session with Navin Kumar is scheduled for tomorrow at 6:00 PM.',
        'time': '1 hour ago',
        'icon': Icons.event_available,
        'color': Colors.blue,
      },
      {
        'title': 'New Rating & Feedback',
        'body': 'Siddharth Roy gave you a 5-star review for the Arduino Electronics class.',
        'time': '3 hours ago',
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'title': 'Live Class Started',
        'body': 'Siddharth Roy is live right now teaching Auto-Layout in Figma!',
        'time': 'Yesterday',
        'icon': Icons.live_tv,
        'color': Colors.red,
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Notifications', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Icon(Icons.notifications_active, color: Colors.blue),
                ],
              ),
              const Divider(height: 24.0),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mockNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = mockNotifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: (notif['color'] as Color).withValues(alpha: 0.12),
                        child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                      ),
                      title: Text(notif['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                      subtitle: Text(notif['body'] as String, style: const TextStyle(fontSize: 11.0)),
                      trailing: Text(notif['time'] as String, style: const TextStyle(fontSize: 9.0, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final matchingProv = Provider.of<MatchingProvider>(context);
    final sessionProv = Provider.of<SessionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFreeOnly = user.classAccessPreference == 'Free Live Classes Only';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 24.0, height: 24.0),
            const SizedBox(width: 8.0),
            const Text('SkillSwap', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          // AI Features Shortcut
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF14B8A6)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiFeaturesScreen()),
              );
            },
          ),
          // Admin Panel Shortcut (Visible to Admin role)
          if (user.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFEF4444)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              },
            ),
          // Notifications Bell Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationsBottomSheet(context),
          ),
          // Light/Dark Toggle
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.fullName} 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      user.role == UserRole.mentor ? 'Verified Expert Mentor' : 'Active Skill Explorer',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      '${user.collegeName} • ${user.department}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              if (isFreeOnly) ...[
                // Upgrade Account Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Upgrade to Premium Access!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                            const SizedBox(height: 2.0),
                            Text(
                              'Unlock 1-on-1 peer matching, calendar scheduling, and reviews.',
                              style: TextStyle(fontSize: 11.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Upcoming Live Classes carousel
                _buildLiveClassesPreview(theme),

                // Popular Skills list
                Text('Trending Skills', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12.0),
                _buildTrendingSkills(theme),
              ] else ...[
                // Incoming Swap Requests List
                if (matchingProv.incomingRequests.isNotEmpty) ...[
                  _buildIncomingRequestsList(matchingProv, theme, user),
                  const SizedBox(height: 24.0),
                ],

                // Outgoing Swap Requests List (My Sent Requests)
                _buildOutgoingRequestsList(matchingProv, theme, user),

                // 2. Skill Swap Matches Carousel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recommended Matches', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Icon(Icons.bolt, color: Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 12.0),
                _buildMatchesCarousel(matchingProv, theme, user),
                const SizedBox(height: 24.0),

                // Nearby Users in same City
                _buildNearbyUsersList(matchingProv, theme, user),

                // 3. Upcoming Booked Sessions
                Text('Upcoming Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12.0),
                _buildSessionsList(sessionProv, user.uid),
                const SizedBox(height: 24.0),

                // Upcoming Live Classes carousel
                _buildLiveClassesPreview(theme),

                // 4. Leaderboard Shortcut Card
                _buildLeaderboardPreview(matchingProv, theme),
                const SizedBox(height: 24.0),

                // 5. Popular Skills list
                Text('Trending Skills', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12.0),
                _buildTrendingSkills(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesCarousel(MatchingProvider provider, ThemeData theme, UserModel currentUser) {
    if (provider.isLoading) {
      return const SkeletonCard(height: 140.0);
    }
    if (provider.matches.isEmpty) {
      return Container(
        height: 140.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No matches found yet. Add more offered and wanted skills in your profile to trigger swap matches!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.0, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.matches.length,
        itemBuilder: (context, index) {
          final match = provider.matches[index];
          final isUserOne = match.userOneId == currentUser.uid;
          final peerName = isUserOne ? match.userTwoName : match.userOneName;
          final peerPic = isUserOne ? match.userTwoProfilePic : match.userOneProfilePic;
          final learnSkill = isUserOne ? match.userOneSkillWanted : match.userTwoSkillWanted;
          final teachSkill = isUserOne ? match.userTwoSkillWanted : match.userOneSkillWanted;

          return NeumorphicContainer(
            width: 280.0,
            margin: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchingScreen(match: match),
                ),
              );
            },
            child: Row(
              children: [
                buildSafeAvatar(imagePath: peerPic, radius: 28.0),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        peerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Wants: $teachSkill',
                        style: TextStyle(fontSize: 11.0, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                      ),
                      Text(
                        'Offers: $learnSkill',
                        style: TextStyle(fontSize: 11.0, color: theme.colorScheme.secondary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${match.matchPercentage.toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w900,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyUsersList(MatchingProvider provider, ThemeData theme, UserModel currentUser) {
    if (currentUser.city.isEmpty) return const SizedBox.shrink();
    
    final nearby = provider.allMentors
        .where((u) => u.city.toLowerCase() == currentUser.city.toLowerCase() && u.uid != currentUser.uid)
        .toList();
        
    if (nearby.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nearby Users in ${currentUser.city}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 20.0),
          ],
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 130.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nearby.length,
            itemBuilder: (context, index) {
              final peer = nearby[index];
              return NeumorphicContainer(
                width: 260.0,
                margin: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    buildSafeAvatar(imagePath: peer.profilePicture, radius: 24.0),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(peer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2.0),
                          Text('${peer.department} • ${peer.collegeName}', style: const TextStyle(fontSize: 10.0, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4.0),
                          Text(
                            peer.skillsOffered.isNotEmpty ? 'Teaches: ${peer.skillsOffered.first.skillName}' : 'Learner',
                            style: TextStyle(fontSize: 10.0, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildOutgoingRequestsList(MatchingProvider provider, ThemeData theme, UserModel currentUser) {
    final outgoing = provider.outgoingRequests;
    if (outgoing.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Sent Swap Requests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: outgoing.length,
          itemBuilder: (context, index) {
            final request = outgoing[index];
            final isUserOne = request.userOneId == currentUser.uid;
            final peerName = isUserOne ? request.userTwoName : request.userOneName;
            final peerPic = isUserOne ? request.userTwoProfilePic : request.userOneProfilePic;
            final learnSkill = isUserOne ? request.userOneSkillWanted : request.userTwoSkillWanted;
            
            return NeumorphicContainer(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                dense: true,
                leading: buildSafeAvatar(imagePath: peerPic, radius: 20.0),
                title: Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Proposing to learn: $learnSkill'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(color: Colors.blue, fontSize: 10.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildLiveClassesPreview(ThemeData theme) {
    final mockClasses = [
      {
        'title': 'React JS Components & Hooks',
        'host': 'Priya Sharma',
        'category': 'Programming',
        'time': 'Live Now',
        'participants': '24 joined',
      },
      {
        'title': 'Figma Advanced Auto-Layout',
        'host': 'Siddharth Roy',
        'category': 'UI/UX Design',
        'time': 'Live Now',
        'participants': '18 joined',
      },
      {
        'title': 'Introduction to Data Models',
        'host': 'Navin Kumar',
        'category': 'Data Science',
        'time': 'June 28, 11:00 AM',
        'participants': '42 joined',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Live Classes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiveClassesScreen()),
                );
              },
              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 150.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mockClasses.length,
            itemBuilder: (context, index) {
              final c = mockClasses[index];
              return NeumorphicContainer(
                width: 280.0,
                margin: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            c['category']!,
                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 9.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 12.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text(c['participants']!, style: const TextStyle(fontSize: 10.0, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      c['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text('Host: ${c['host']!}', style: const TextStyle(fontSize: 11.0, color: Colors.grey)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c['time']!,
                          style: TextStyle(fontSize: 11.0, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LiveClassesScreen()),
                            );
                          },
                          child: const Text('Join', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildSessionsList(SessionProvider provider, String currentUserId) {
    final upcoming = provider.upcomingSessions;
    if (provider.isLoading) {
      return const SkeletonCard(height: 100.0);
    }
    if (upcoming.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No upcoming scheduled classes. Request a swap from the marketplace to schedule meetings.', style: TextStyle(color: Colors.grey, fontSize: 13.0)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcoming.take(2).length,
      itemBuilder: (context, index) {
        final session = upcoming[index];
        return SessionCard(
          session: session,
          currentUserId: currentUserId,
          onAccept: () => provider.acceptSessionRequest(session),
          onReject: () => provider.rejectSessionRequest(session),
          onComplete: () => provider.completeActiveSession(session),
          onReschedule: (newTime) => provider.requestReschedule(session, newTime, currentUserId),
        );
      },
    );
  }

  Widget _buildLeaderboardPreview(MatchingProvider provider, ThemeData theme) {
    if (provider.leaderboard.isEmpty) return const SizedBox.shrink();

    final topUser = provider.leaderboard.first;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.leaderboard, color: Color(0xFFF59E0B), size: 36.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Leaderboard Top Rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                const SizedBox(height: 2.0),
                Text('Leader: ${topUser.userName} (Score: ${topUser.calculatedScore.toInt()})', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
            child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSkills(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 2.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final skill = popularSkills[index];
        return NeumorphicContainer(
          padding: const EdgeInsets.all(12.0),
          borderRadius: 12.0,
          child: Row(
            children: [
              Icon(Icons.bolt, color: theme.colorScheme.primary, size: 20.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(skill.category, style: const TextStyle(fontSize: 10.0, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomingRequestsList(MatchingProvider provider, ThemeData theme, UserModel currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Incoming Swap Requests',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '${provider.incomingRequests.length} Pending',
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.incomingRequests.length,
          itemBuilder: (context, index) {
            final match = provider.incomingRequests[index];
            final isUserOne = match.userOneId == currentUser.uid;
            
            // Align details correctly depending on viewer role
            final peerName = isUserOne ? match.userTwoName : match.userOneName;
            final peerPic = isUserOne ? match.userTwoProfilePic : match.userOneProfilePic;
            final learnSkill = isUserOne ? match.userOneSkillWanted : match.userTwoSkillWanted;
            final teachSkill = isUserOne ? match.userTwoSkillWanted : match.userOneSkillWanted;

            return NeumorphicContainer(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  buildSafeAvatar(imagePath: peerPic, radius: 26.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          peerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Wants: $teachSkill',
                          style: TextStyle(fontSize: 12.0, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Offers: $learnSkill',
                          style: TextStyle(fontSize: 12.0, color: theme.colorScheme.secondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => provider.acceptSwapRequest(match),
                        child: const Text('Accept', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6.0),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => provider.rejectSwapRequest(match),
                        child: const Text('Decline', style: TextStyle(fontSize: 11.0)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
