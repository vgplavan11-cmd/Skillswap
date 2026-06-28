import 'firestore_service.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  /// Calculates matches for [currentUser] against all other users in database.
  Future<List<MatchModel>> generateMatches(UserModel currentUser) async {
    final allUsers = await _firestoreService.getAllUsers();
    final List<MatchModel> matches = [];

    for (var otherUser in allUsers) {
      if (otherUser.uid == currentUser.uid) continue;

      double score = calculateMatchScore(currentUser, otherUser);

      // Only match if there is at least a minimal mutual interest or one-way skill matching
      if (score > 10.0) {
        // Find which skill they want and offer
        String currentUserSkillWanted = '';
        String otherUserSkillWanted = '';

        // Check what otherUser offers that currentUser wants
        for (var wanted in currentUser.skillsWanted) {
          final offers = otherUser.skillsOffered.where((o) => o.skillName.toLowerCase() == wanted.skillName.toLowerCase());
          if (offers.isNotEmpty) {
            currentUserSkillWanted = offers.first.skillName;
            break;
          }
        }

        // Check what currentUser offers that otherUser wants
        for (var wanted in otherUser.skillsWanted) {
          final offers = currentUser.skillsOffered.where((o) => o.skillName.toLowerCase() == wanted.skillName.toLowerCase());
          if (offers.isNotEmpty) {
            otherUserSkillWanted = offers.first.skillName;
            break;
          }
        }

        // If no mutual match is found, just use the first offered/wanted skill values
        if (currentUserSkillWanted.isEmpty && otherUser.skillsOffered.isNotEmpty) {
          currentUserSkillWanted = otherUser.skillsOffered.first.skillName;
        }
        if (otherUserSkillWanted.isEmpty && currentUser.skillsOffered.isNotEmpty) {
          otherUserSkillWanted = currentUser.skillsOffered.first.skillName;
        }

        matches.add(MatchModel(
          id: 'match_${currentUser.uid}_${otherUser.uid}',
          userOneId: currentUser.uid,
          userTwoId: otherUser.uid,
          userOneName: currentUser.fullName,
          userTwoName: otherUser.fullName,
          userOneProfilePic: currentUser.profilePicture,
          userTwoProfilePic: otherUser.profilePicture,
          userOneSkillWanted: currentUserSkillWanted,
          userTwoSkillWanted: otherUserSkillWanted,
          matchPercentage: score,
          status: 'pending',
          timestamp: DateTime.now(),
        ));
      }
    }

    // Sort matches descending by percentage
    matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return matches;
  }

  /// Score Calculation Algorithm:
  /// 1. Mutual Skill Swap (A wants B's skill && B wants A's skill) -> +60% base
  /// 2. One-way Skill Match (A wants B's skill || B wants A's skill) -> +30% base
  /// 3. Experience Match (Aligning Beginner to Intermediate or Expert mentors) -> up to +15%
  /// 4. Rating Match (Higher ratings get higher match ranks) -> up to +15%
  /// 5. Availability Overlap (Flexible or matching timeframes) -> up to +10%
  double calculateMatchScore(UserModel userA, UserModel userB) {
    double score = 0.0;
    bool aWantsB = false;
    bool bWantsA = false;

    // 1. Check if userA wants what userB offers
    for (var wanted in userA.skillsWanted) {
      if (userB.skillsOffered.any((o) => o.skillName.toLowerCase() == wanted.skillName.toLowerCase())) {
        aWantsB = true;
        break;
      }
    }

    // 2. Check if userB wants what userA offers
    for (var wanted in userB.skillsWanted) {
      if (userA.skillsOffered.any((o) => o.skillName.toLowerCase() == wanted.skillName.toLowerCase())) {
        bWantsA = true;
        break;
      }
    }

    // Compute base skill swap compatibility
    if (aWantsB && bWantsA) {
      score += 60.0; // Complete reciprocal match
    } else if (aWantsB || bWantsA) {
      score += 30.0; // One-way interest match
    } else {
      return 0.0; // No match potential
    }

    // 3. Add Rating Adjustments (Max 15%)
    // Base: higher rating equals up to 15 points
    score += (userB.averageRating / 5.0) * 15.0;

    // 4. Add Experience Level Adjustments (Max 15%)
    // More experienced mentors give higher confidence score
    if (userB.experienceYears >= 5) {
      score += 15.0;
    } else if (userB.experienceYears >= 3) {
      score += 10.0;
    } else {
      score += 5.0;
    }

    // 5. Add Availability Overlap (Max 10%)
    if (userA.availability.toLowerCase() == 'flexible' || userB.availability.toLowerCase() == 'flexible') {
      score += 10.0;
    } else if (userA.availability.toLowerCase() == userB.availability.toLowerCase()) {
      score += 10.0;
    } else {
      score += 5.0;
    }

    // Cap the score to 100%
    if (score > 100.0) score = 100.0;
    return double.parse(score.toStringAsFixed(1));
  }
}
