import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matching_provider.dart';
import '../../providers/session_provider.dart';
import '../../models/user_model.dart';
import '../../models/skill_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/mentor_card.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neumorphic_container.dart';

class SkillsMarketplace extends StatefulWidget {
  const SkillsMarketplace({super.key});

  @override
  State<SkillsMarketplace> createState() => _SkillsMarketplaceState();
}

class _SkillsMarketplaceState extends State<SkillsMarketplace> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MatchingProvider>(context, listen: false).loadAllMentors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSwapDialog(UserModel mentor) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    if (user.skillsOffered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must add at least one offered skill in your Profile first to make a swap request!'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    // Try to find what you teach that matching peer wants (opposite matching)
    String selectedUserOffer = user.skillsOffered.first.skillName;
    for (var offer in user.skillsOffered) {
      if (mentor.skillsWanted.any((w) => w.skillName.toLowerCase() == offer.skillName.toLowerCase())) {
        selectedUserOffer = offer.skillName;
        break;
      }
    }

    // Try to find what you learn that matching peer offers (opposite matching)
    String selectedMentorOffer = mentor.skillsOffered.isNotEmpty ? mentor.skillsOffered.first.skillName : '';
    for (var offer in mentor.skillsOffered) {
      if (user.skillsWanted.any((w) => w.skillName.toLowerCase() == offer.skillName.toLowerCase())) {
        selectedMentorOffer = offer.skillName;
        break;
      }
    }

    DateTime selectedDateTime = DateTime.now().add(const Duration(days: 1));
    String selectedMeetType = 'Chat Room Only';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              title: Text('Request Skill Swap', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Propose exchange details with ${mentor.fullName}:', style: const TextStyle(fontSize: 13.0)),
                    const SizedBox(height: 16.0),
                    const Text('Select what you teach:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedUserOffer,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: user.skillsOffered.map((s) {
                            return DropdownMenuItem<String>(
                              value: s.skillName,
                              child: Text(s.skillName, style: TextStyle(color: theme.colorScheme.onSurface)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedUserOffer = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text('Select what you learn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    mentor.skillsOffered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('This user offers no skills yet.', style: TextStyle(color: Colors.grey, fontSize: 13.0)),
                          )
                        : NeumorphicContainer(
                            isInset: true,
                            borderRadius: 12.0,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedMentorOffer.isEmpty && mentor.skillsOffered.isNotEmpty 
                                    ? mentor.skillsOffered.first.skillName 
                                    : selectedMentorOffer,
                                isExpanded: true,
                                dropdownColor: theme.scaffoldBackgroundColor,
                                items: mentor.skillsOffered.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s.skillName,
                                    child: Text(s.skillName, style: TextStyle(color: theme.colorScheme.onSurface)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedMentorOffer = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 12.0),
                    const Text('Meeting Platform:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      isInset: true,
                      borderRadius: 12.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMeetType,
                          isExpanded: true,
                          dropdownColor: theme.scaffoldBackgroundColor,
                          items: ['Chat Room Only', 'Google Meet', 'Zoom', 'MS Teams'].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type, style: TextStyle(color: theme.colorScheme.onSurface)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMeetType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text('Class date & time:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                    const SizedBox(height: 6.0),
                    NeumorphicContainer(
                      borderRadius: 12.0,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, size: 18.0, color: theme.colorScheme.primary),
                          const SizedBox(width: 8.0),
                          Text(
                            '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} at ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                NeumorphicContainer(
                  borderRadius: 12.0,
                  color: theme.colorScheme.primary,
                  onTap: () async {
                    final sessionProv = Provider.of<SessionProvider>(context, listen: false);
                    final success = await sessionProv.bookSession(
                      mentorId: mentor.uid,
                      mentorName: mentor.fullName,
                      mentorProfilePic: mentor.profilePicture,
                      learnerId: user.uid,
                      learnerName: user.fullName,
                      learnerProfilePic: user.profilePicture,
                      skillName: selectedMentorOffer,
                      scheduledDateTime: selectedDateTime,
                      meetLinkType: selectedMeetType,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Swap request sent successfully! You can chat with the mentor in the Chat tab.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchingProv = Provider.of<MatchingProvider>(context);
    final filteredMentors = matchingProv.getFilteredMentors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: NeumorphicContainer(
              isInset: true,
              borderRadius: 18.0,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => matchingProv.updateSearchQuery(val),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search skills, topics, or mentors...',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            matchingProv.updateSearchQuery('');
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),

          // 2. Categories selector
          SizedBox(
            height: 48.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: ['All', ...skillCategories].length,
              itemBuilder: (context, index) {
                final category = ['All', ...skillCategories][index];
                final isSelected = matchingProv.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                  child: NeumorphicContainer(
                    borderRadius: 20.0,
                    isInset: isSelected,
                    color: isSelected 
                        ? theme.colorScheme.primary.withValues(alpha: 0.15) 
                        : null,
                    onTap: () {
                      matchingProv.updateSelectedCategory(category);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),

          // 3. Mentors List
          Expanded(
            child: matchingProv.isLoading
                ? const MentorListSkeleton()
                : filteredMentors.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No Mentors Found',
                        description: 'Try searching other terms or selecting different category filters.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredMentors.length,
                        itemBuilder: (context, index) {
                          final mentor = filteredMentors[index];
                          return MentorCard(
                            mentor: mentor,
                            onTap: () {
                              // View Profile Modal
                              _showProfileModal(mentor);
                            },
                            onRequestTap: () => _showSwapDialog(mentor),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showProfileModal(UserModel mentor) {
    final FirestoreService firestoreService = FirestoreService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.0, height: 4.0, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2.0)))),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  CircleAvatar(radius: 36.0, backgroundImage: NetworkImage(mentor.profilePicture)),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mentor.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('${mentor.department} • ${mentor.collegeName}', style: const TextStyle(fontSize: 13.0, color: Colors.grey)),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18.0),
                            const SizedBox(width: 2.0),
                            Text(mentor.averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4.0),
                            Text('(${mentor.totalReviews} reviews)', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Biography', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      const SizedBox(height: 8.0),
                      Text(mentor.bio.isNotEmpty ? mentor.bio : 'No biography added yet.', style: const TextStyle(fontSize: 13.0, height: 1.4, color: Colors.grey)),
                      const SizedBox(height: 20.0),
                      const Text('Skills Offered to Teach', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: mentor.skillsOffered.map((s) => NeumorphicContainer(
                          borderRadius: 12.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          child: Text('${s.skillName} (${s.level})', style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 20.0),
                      const Text('Skills Wanted to Learn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: mentor.skillsWanted.map((s) => NeumorphicContainer(
                          borderRadius: 12.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          child: Text('${s.skillName} (${s.level})', style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 24.0),
                      const Text('Reviews & Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                      const SizedBox(height: 12.0),
                      FutureBuilder<List<ReviewModel>>(
                        future: firestoreService.getUserReviews(mentor.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading reviews: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                          }
                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text('No reviews submitted yet.', style: TextStyle(color: Colors.grey, fontSize: 13.0)),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
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
                                    if (review.lectureName.isNotEmpty) ...[
                                      const SizedBox(height: 6.0),
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
                                    ],
                                    const SizedBox(height: 8.0),
                                    Text(
                                      review.writtenReview,
                                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text('Teaching: ${review.teachingQuality.toInt()}', style: const TextStyle(fontSize: 8.0, color: Colors.grey)),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text('Comm: ${review.communication.toInt()}', style: const TextStyle(fontSize: 8.0, color: Colors.grey)),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text('Knowledge: ${review.knowledge.toInt()}', style: const TextStyle(fontSize: 8.0, color: Colors.grey)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              NeumorphicContainer(
                borderRadius: 18.0,
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showSwapDialog(mentor);
                },
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: const Center(
                  child: Text('Send Swap Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
