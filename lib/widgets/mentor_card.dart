import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'skill_tag.dart';
import 'neumorphic_container.dart';

class MentorCard extends StatelessWidget {
  final UserModel mentor;
  final VoidCallback onTap;
  final VoidCallback onRequestTap;

  const MentorCard({
    super.key,
    required this.mentor,
    required this.onTap,
    required this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NeumorphicContainer(
      margin: const EdgeInsets.only(bottom: 16.0),
      borderRadius: 20.0,
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28.0,
                backgroundImage: NetworkImage(mentor.profilePicture),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  mentor.fullName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (mentor.isVerifiedMentor) ...[
                                const SizedBox(width: 4.0),
                                const Icon(
                                  Icons.verified_user,
                                  color: Color(0xFF14B8A6), // Teal accent
                                  size: 16.0,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: mentor.role == UserRole.mentor 
                                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                : theme.colorScheme.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            mentor.role == UserRole.mentor ? 'Mentor' : 'Learner',
                            style: TextStyle(
                              color: mentor.role == UserRole.mentor 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${mentor.department} • ${mentor.collegeName}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16.0),
                        const SizedBox(width: 2.0),
                        Text(
                          mentor.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '(${mentor.totalReviews} reviews)',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (mentor.bio.isNotEmpty) ...[
            Text(
              mentor.bio,
              style: TextStyle(
                fontSize: 13.0,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12.0),
          ],
          if (mentor.skillsOffered.isNotEmpty) ...[
            const Text(
              'Teaches / Offers:',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: mentor.skillsOffered.map((s) => SkillTag(label: s.skillName, level: s.level)).toList(),
            ),
            const SizedBox(height: 12.0),
          ],
          if (mentor.skillsWanted.isNotEmpty) ...[
            const Text(
              'Wants / Learns:',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: mentor.skillsWanted.map((s) => SkillTag(label: s.skillName, level: s.level)).toList(),
            ),
          ],
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exp: ${mentor.experienceYears} yrs • ${mentor.availability}',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              NeumorphicContainer(
                borderRadius: 12.0,
                color: theme.colorScheme.primary,
                onTap: onRequestTap,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: const Text(
                  'Request Swap',
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
