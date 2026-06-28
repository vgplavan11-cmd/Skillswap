import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/badge_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';
import 'edit_profile_screen.dart';
import '../../widgets/skill_tag.dart';
import '../../widgets/neumorphic_container.dart';
import '../../widgets/avatar_helper.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ReviewModel> _userReviews = [];
  bool _loadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() => _loadingReviews = true);
    final reviews = await _firestoreService.getUserReviews(user.uid);
    setState(() {
      _userReviews = reviews;
      _loadingReviews = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadReviews();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Bio Header Card
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    buildSafeAvatar(imagePath: user.profilePicture, radius: 36.0),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${user.department} • ${user.collegeName}',
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6.0),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16.0),
                              const SizedBox(width: 2.0),
                              Text(
                                user.averageRating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                '${user.sessionsConducted} classes taught',
                                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Edit Profile Button
              NeumorphicContainer(
                borderRadius: 18.0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ).then((_) => _loadReviews());
                },
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 18.0, color: theme.colorScheme.primary),
                    const SizedBox(width: 8.0),
                    Text(
                      'Edit Profile & Skills',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 15.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // 2. Biography
              Text('Biography', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Text(
                user.bio.isNotEmpty ? user.bio : 'No bio added yet. Click edit profile to add bio details.',
                style: TextStyle(fontSize: 14.0, height: 1.4, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 24.0),

              // Platform Access Preference
              Text('Platform Access', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              NeumorphicContainer(
                borderRadius: 20.0,
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.class_outlined, color: theme.colorScheme.primary),
                  title: Text(
                    user.classAccessPreference == 'Free Live Classes Only'
                        ? 'Free Live Classes Only'
                        : 'All Classes & Peer Matchmaking',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.classAccessPreference == 'Free Live Classes Only'
                        ? 'Access to live streams only.'
                        : 'Full access to 1-on-1 swaps, scheduling, and live rooms.',
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 3. Skills Offered and Wanted
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teaching:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        user.skillsOffered.isEmpty
                            ? const Text('None', style: TextStyle(fontSize: 12.0, color: Colors.grey))
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 6.0,
                                children: user.skillsOffered.map((s) => SkillTag(label: s.skillName, level: s.level)).toList(),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Learning:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        user.skillsWanted.isEmpty
                            ? const Text('None', style: TextStyle(fontSize: 12.0, color: Colors.grey))
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 6.0,
                                children: user.skillsWanted.map((s) => SkillTag(label: s.skillName, level: s.level)).toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // 4. Badges Section
              Text('Earned Badges', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              _buildBadgesGrid(user.badges, theme),
              const SizedBox(height: 24.0),

              // 5. Reviews Received
              Text('Reviews & Feedback', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              _buildReviewsSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(List<String> userBadges, ThemeData theme) {
    final activeBadges = systemBadges.where((b) => userBadges.contains(b.id)).toList();
    if (activeBadges.isEmpty) {
      return const Text('Complete classes and receive ratings above 4.5 to earn verified mentor badges!', style: TextStyle(color: Colors.grey, fontSize: 13.0));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 2.2,
      ),
      itemCount: activeBadges.length,
      itemBuilder: (context, index) {
        final badge = activeBadges[index];
        return NeumorphicContainer(
          borderRadius: 12.0,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(_getBadgeIcon(badge.iconCode), color: const Color(0xFFF59E0B), size: 30.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(badge.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0), maxLines: 1),
                    Text(badge.description, style: const TextStyle(fontSize: 8.0, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getBadgeIcon(String key) {
    switch (key) {
      case 'verified_user':
        return Icons.verified_user;
      case 'school':
        return Icons.school;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'award_star_bronze':
      default:
        return Icons.stars;
    }
  }

  Widget _buildReviewsSection(ThemeData theme) {
    if (_loadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_userReviews.isEmpty) {
      return const Text('No reviews submitted yet.', style: TextStyle(color: Colors.grey, fontSize: 13.0));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        final review = _userReviews[index];
        return NeumorphicContainer(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(12.0),
          borderRadius: 16.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 14.0,
                        color: i < review.overallRating.toInt() ? const Color(0xFFF59E0B) : Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              if (review.lectureName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                     color: theme.colorScheme.primary.withValues(alpha: 0.08),
                     borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, size: 12.0, color: theme.colorScheme.primary),
                      const SizedBox(width: 4.0),
                      Text(
                        'Class: ${review.lectureName}',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
              Text(
                review.writtenReview,
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  _buildSubScoreChip('Teaching: ${review.teachingQuality.toInt()}'),
                  const SizedBox(width: 6.0),
                  _buildSubScoreChip('Comm: ${review.communication.toInt()}'),
                  const SizedBox(width: 6.0),
                  _buildSubScoreChip('Knowledge: ${review.knowledge.toInt()}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubScoreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(label, style: const TextStyle(fontSize: 8.0, color: Colors.grey)),
    );
  }
}
