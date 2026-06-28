import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/matching_provider.dart';
import '../../models/leaderboard_model.dart';
import '../../widgets/neumorphic_container.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchingProvider>(context, listen: false).loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchingProv = Provider.of<MatchingProvider>(context);

    // Filter mentors vs learners
    final mentors = matchingProv.leaderboard.where((e) => e.role == 'mentor').toList();
    final learners = matchingProv.leaderboard.where((e) => e.role == 'learner').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillSwap Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Top Mentors'),
            Tab(text: 'Top Learners'),
          ],
        ),
      ),
      body: matchingProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderList(mentors, theme),
                _buildLeaderList(learners, theme),
              ],
            ),
    );
  }

  Widget _buildLeaderList(List<LeaderboardEntry> list, ThemeData theme) {
    if (list.isEmpty) {
      return const Center(child: Text('No entries on the leaderboard yet.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.take(10).length, // Top 10 Limit
      itemBuilder: (context, index) {
        final entry = list[index];
        final rank = index + 1;

        return NeumorphicContainer(
          margin: const EdgeInsets.only(bottom: 12.0),
          borderRadius: 16.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: 32.0,
                alignment: Alignment.center,
                child: _buildRankBadge(rank, theme),
              ),
              const SizedBox(width: 12.0),
              CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(entry.userProfilePic),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${entry.calculatedScore.toInt()} points • ${entry.averageRating.toStringAsFixed(1)} stars',
                      style: const TextStyle(fontSize: 11.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Weight Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Text('rank', style: TextStyle(fontSize: 8.0, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank, ThemeData theme) {
    if (rank == 1) {
      return const Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 28.0); // Gold Medal
    } else if (rank == 2) {
      return const Icon(Icons.workspace_premium, color: Color(0xFF94A3B8), size: 26.0); // Silver Medal
    } else if (rank == 3) {
      return const Icon(Icons.workspace_premium, color: Color(0xFFB45309), size: 24.0); // Bronze Medal
    }
    return Text(
      '#$rank',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.grey),
    );
  }
}
