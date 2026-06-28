import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import 'review_screen.dart';
import '../../widgets/session_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neumorphic_container.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final sessionProv = Provider.of<SessionProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final upcoming = sessionProv.upcomingSessions;
    final completed = sessionProv.completedSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Classes'),
            Tab(text: 'Completed History'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Weekly Calendar Mockup Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getMonthYearString(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                      const Icon(Icons.calendar_month, color: Colors.grey, size: 18.0),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 68.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 14, // Show next 14 days
                    itemBuilder: (context, index) {
                      final day = DateTime.now().add(Duration(days: index - 2));
                      final isSelected = day.day == _selectedDate.day &&
                          day.month == _selectedDate.month &&
                          day.year == _selectedDate.year;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                        child: NeumorphicContainer(
                          width: 48.0,
                          borderRadius: 10.0,
                          isInset: isSelected,
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getWeekdayString(day),
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Tabs List View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Upcoming Sessions
                upcoming.isEmpty
                    ? const EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'No Upcoming Sessions',
                        description: 'Schedule a session from matches or browse instructors in the Skill Marketplace.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: upcoming.length,
                        itemBuilder: (context, index) {
                          final session = upcoming[index];
                          return SessionCard(
                            session: session,
                            currentUserId: user.uid,
                            onAccept: () => sessionProv.acceptSessionRequest(session),
                            onReject: () => sessionProv.rejectSessionRequest(session),
                            onComplete: () {
                              sessionProv.completeActiveSession(session);
                              // Open Review screen automatically after complete
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewScreen(session: session),
                                  ),
                                );
                            },
                            onReschedule: (newTime) =>
                                sessionProv.requestReschedule(session, newTime, user.uid),
                          );
                        },
                      ),

                // Tab 2: Completed History
                completed.isEmpty
                    ? const EmptyState(
                        icon: Icons.history,
                        title: 'No History',
                        description: 'Your completed classes will appear here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: completed.length,
                        itemBuilder: (context, index) {
                          final session = completed[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SessionCard(
                                session: session,
                                currentUserId: user.uid,
                              ),
                              // Show submit review helper button if isLearner and review not submitted
                              if (session.learnerId == user.uid)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
                                  child: NeumorphicContainer(
                                    borderRadius: 12.0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewScreen(session: session),
                                        ),
                                      );
                                    },
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rate_review, size: 16.0, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Leave Review & Feedback',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayString(DateTime date) {
    switch (date.weekday) {
      case 1: return 'MON';
      case 2: return 'TUE';
      case 3: return 'WED';
      case 4: return 'THU';
      case 5: return 'FRI';
      case 6: return 'SAT';
      case 7:
      default: return 'SUN';
    }
  }

  String _getMonthYearString(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}
