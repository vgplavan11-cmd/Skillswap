import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/matching_provider.dart';
import '../../models/match_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'chat_screen.dart';
import '../../widgets/custom_button.dart';

class MatchingScreen extends StatefulWidget {
  final MatchModel match;

  const MatchingScreen({super.key, required this.match});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _peerProfile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPeerProfile();
  }

  void _loadPeerProfile() async {
    setState(() => _loading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final peerId = widget.match.userOneId == authProv.currentUser?.uid
        ? widget.match.userTwoId
        : widget.match.userOneId;
    final profile = await _firestoreService.getUserProfile(peerId);
    setState(() {
      _peerProfile = profile;
      _loading = false;
    });
  }

  void _connectAndChat() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    if (authProv.currentUser == null || _peerProfile == null) return;

    // Create or retrieve chat session ID
    final chatId = await chatProv.startChat(authProv.currentUser!, _peerProfile!);

    if (mounted) {
      // Route directly to chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            peerId: _peerProfile!.uid,
            peerName: _peerProfile!.fullName,
            peerPic: _peerProfile!.profilePicture,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final match = widget.match;

    final authProv = Provider.of<AuthProvider>(context);
    final matchingProv = Provider.of<MatchingProvider>(context);

    // Get current DB status of this match if present
    final activeMatch = matchingProv.matches.firstWhere(
      (m) => m.id == match.id,
      orElse: () => match,
    );

    final isUserOne = activeMatch.userOneId == authProv.currentUser?.uid;
    final peerPic = isUserOne ? activeMatch.userTwoProfilePic : activeMatch.userOneProfilePic;
    final peerName = isUserOne ? activeMatch.userTwoName : activeMatch.userOneName;
    final learnSkill = isUserOne ? activeMatch.userOneSkillWanted : activeMatch.userTwoSkillWanted;
    final teachSkill = isUserOne ? activeMatch.userTwoSkillWanted : activeMatch.userOneSkillWanted;
    final currentUserPic = authProv.currentUser?.profilePicture ?? (isUserOne ? activeMatch.userOneProfilePic : activeMatch.userTwoProfilePic);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Match Details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _peerProfile == null
              ? const Center(child: Text('Failed to load peer details.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Dual Profile Circle Layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Current User Pic
                          CircleAvatar(
                            radius: 36.0,
                            backgroundImage: NetworkImage(currentUserPic),
                          ),
                          const SizedBox(width: 12.0),
                          // Overlay Percentage Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981), // Emerald green
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${activeMatch.matchPercentage.toInt()}% Match',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Peer User Pic
                          CircleAvatar(
                            radius: 36.0,
                            backgroundImage: NetworkImage(peerPic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      Text(
                        'Swap Match with $peerName',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${_peerProfile!.department} • ${_peerProfile!.collegeName}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13.0),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 36.0),

                      // 2. Breakdown criteria lists
                      _buildCriteriaRow(
                        theme,
                        title: 'Exchange compatibility',
                        description: 'A perfect reciprocal match! You learn "$learnSkill" and teach "$teachSkill".',
                        icon: Icons.swap_horiz,
                        isCheck: true,
                      ),
                      _buildCriteriaRow(
                        theme,
                        title: 'Peer availability',
                        description: 'Both slots overlap on: ${_peerProfile!.availability}.',
                        icon: Icons.calendar_today,
                        isCheck: true,
                      ),
                      _buildCriteriaRow(
                        theme,
                        title: 'Tutor Rating',
                        description: 'Expert holds an average of ${_peerProfile!.averageRating.toStringAsFixed(1)} stars out of ${_peerProfile!.totalReviews} reviews.',
                        icon: Icons.star,
                        isCheck: true,
                      ),
                      _buildCriteriaRow(
                        theme,
                        title: 'Teaching Experience',
                        description: '${_peerProfile!.experienceYears} years of engineering experience.',
                        icon: Icons.work,
                        isCheck: true,
                      ),
                      const SizedBox(height: 48.0),

                      // 3. CTA Buttons
                      _buildActionButton(context, activeMatch, isUserOne, matchingProv),
                      const SizedBox(height: 12.0),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCriteriaRow(
    ThemeData theme, {
    required String title,
    required String description,
    required IconData icon,
    required bool isCheck,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                const SizedBox(height: 4.0),
                Text(description, style: const TextStyle(fontSize: 12.0, color: Colors.grey, height: 1.3)),
              ],
            ),
          ),
          Icon(
            isCheck ? Icons.check_circle : Icons.error_outline,
            color: isCheck ? const Color(0xFF14B8A6) : Colors.grey,
            size: 20.0,
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton(BuildContext context, MatchModel match, bool isUserOne, MatchingProvider provider) {
    if (match.status == 'accepted') {
      return CustomButton(
        text: 'Connect & Chat Now',
        icon: Icons.chat,
        onPressed: _connectAndChat,
      );
    } else if (match.status == 'requested') {
      if (isUserOne) {
        return CustomButton(
          text: 'Swap Request Pending...',
          icon: Icons.hourglass_empty,
          onPressed: null,
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48.0),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                icon: const Icon(Icons.close),
                label: const Text('Decline'),
                onPressed: () {
                  provider.rejectSwapRequest(match);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: CustomButton(
                text: 'Accept Swap',
                icon: Icons.check,
                onPressed: () async {
                  await provider.acceptSwapRequest(match);
                  _connectAndChat();
                },
              ),
            ),
          ],
        );
      }
    } else {
      return CustomButton(
        text: 'Send Swap Request',
        icon: Icons.send,
        onPressed: () => provider.sendSwapRequest(match),
      );
    }
  }
}
