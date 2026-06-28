import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/ai_provider.dart';
import '../../models/session_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/neumorphic_container.dart';

class ReviewScreen extends StatefulWidget {
  final SessionModel session;

  const ReviewScreen({super.key, required this.session});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _reviewController = TextEditingController();

  double _teachingQuality = 5.0;
  double _communication = 5.0;
  double _knowledge = 5.0;
  double _helpfulness = 5.0;

  bool _isCheckingSpam = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a brief feedback comment.'), backgroundColor: Colors.amber),
      );
      return;
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final sessionProv = Provider.of<SessionProvider>(context, listen: false);
    final aiProv = Provider.of<AiProvider>(context, listen: false);

    if (authProv.currentUser == null) return;

    // 1. AI Fake/Spam Review Check
    setState(() => _isCheckingSpam = true);
    final isSpam = await aiProv.checkSpamReview(text);
    setState(() => _isCheckingSpam = false);

    if (isSpam && mounted) {
      // Spam Flagged Warning
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8.0),
                Text('Feedback Flagged!'),
              ],
            ),
            content: const Text(
              'Our AI moderator flagged your review as spam or containing restricted terms (like promotions, fast money links, ads). Please revise your comments to focus strictly on class learnings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Edit Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
      return;
    }

    // 2. Submit Review
    final revieweeId = widget.session.mentorId == authProv.currentUser!.uid
        ? widget.session.learnerId
        : widget.session.mentorId;
    final reviewerName = authProv.currentUser!.fullName;

    final success = await sessionProv.submitSessionReview(
      sessionId: widget.session.id,
      reviewerId: authProv.currentUser!.uid,
      reviewerName: reviewerName,
      revieweeId: revieweeId,
      lectureName: widget.session.skillName,
      teachingQuality: _teachingQuality,
      communication: _communication,
      knowledge: _knowledge,
      helpfulness: _helpfulness,
      writtenReview: text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted! Thank you for helping the peer community.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sessionProv.error ?? 'Error submitting review'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionProv = Provider.of<SessionProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Leave Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate class on "${widget.session.skillName}"',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Submitted reviews update the mentor/learner global rating average.',
              style: TextStyle(fontSize: 12.0, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const Divider(height: 32.0),

            // Rating console card
            NeumorphicContainer(
              borderRadius: 20.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildRatingSection(
                    title: 'Teaching Quality',
                    rating: _teachingQuality,
                    onRatingChanged: (val) => setState(() => _teachingQuality = val),
                  ),
                  _buildRatingSection(
                    title: 'Communication',
                    rating: _communication,
                    onRatingChanged: (val) => setState(() => _communication = val),
                  ),
                  _buildRatingSection(
                    title: 'Knowledge Depth',
                    rating: _knowledge,
                    onRatingChanged: (val) => setState(() => _knowledge = val),
                  ),
                  _buildRatingSection(
                    title: 'Helpfulness',
                    rating: _helpfulness,
                    onRatingChanged: (val) => setState(() => _helpfulness = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),
            Text('Written Comments', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 16.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What went well? What could be improved in the next swap session...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 36.0),

            CustomButton(
              text: 'Submit Feedback',
              isLoading: sessionProv.isLoading || _isCheckingSpam,
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required double rating,
    required Function(double) onRatingChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0)),
          Row(
            children: List.generate(5, (index) {
              final starVal = index + 1.0;
              return GestureDetector(
                onTap: () => onRatingChanged(starVal),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.star,
                    color: starVal <= rating ? const Color(0xFFF59E0B) : Colors.grey[300],
                    size: 28.0,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
