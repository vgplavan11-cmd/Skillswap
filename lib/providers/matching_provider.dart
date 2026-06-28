import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/leaderboard_model.dart';
import '../services/matching_service.dart';
import '../services/firestore_service.dart';

class MatchingProvider extends ChangeNotifier {
  final MatchingService _matchingService = MatchingService();
  final FirestoreService _firestoreService = FirestoreService();

  List<MatchModel> _matches = [];
  List<MatchModel> _dbMatches = [];
  List<UserModel> _allMentors = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Active sub-streams
  StreamSubscription<List<MatchModel>>? _matchesSubscription;

  // Marketplace filter inputs
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<MatchModel> get matches {
    // Merge generated recommendations with actual requested/accepted database state
    return _matches.map((generated) {
      try {
        final dbMatch = _dbMatches.firstWhere(
          (m) => (m.userOneId == generated.userOneId && m.userTwoId == generated.userTwoId) ||
                 (m.userOneId == generated.userTwoId && m.userTwoId == generated.userOneId),
        );
        return dbMatch;
      } catch (_) {
        return generated;
      }
    }).toList();
  }

  List<MatchModel> get incomingRequests {
    if (_currentUserId == null) return [];
    return _dbMatches.where((m) => m.userTwoId == _currentUserId && m.status == 'requested').toList();
  }

  List<MatchModel> get outgoingRequests {
    if (_currentUserId == null) return [];
    return _dbMatches.where((m) => m.userOneId == _currentUserId && m.status == 'requested').toList();
  }

  List<MatchModel> get activeConnections {
    return _dbMatches.where((m) => m.status == 'accepted').toList();
  }

  List<UserModel> get allMentors => _allMentors;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadMatches(UserModel currentUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _matches = await _matchingService.generateMatches(currentUser);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllMentors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final allUsers = await _firestoreService.getAllUsers();
      _allMentors = allUsers.where((u) => u.uid != _currentUserId).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _leaderboard = await _firestoreService.getLeaderboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UserModel> getFilteredMentors() {
    return _allMentors.where((mentor) {
      // Filter by category
      bool categoryMatch = _selectedCategory == 'All';
      if (!categoryMatch) {
        categoryMatch = mentor.skillsOffered.any((skill) =>
            skill.skillName.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
            _selectedCategory.toLowerCase().contains(skill.skillName.toLowerCase()));
      }

      // Filter by search query
      bool queryMatch = _searchQuery.isEmpty;
      if (!queryMatch) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = mentor.fullName.toLowerCase().contains(query);
        final skillMatch = mentor.skillsOffered.any((skill) => skill.skillName.toLowerCase().contains(query));
        final collegeMatch = mentor.collegeName.toLowerCase().contains(query);
        queryMatch = nameMatch || skillMatch || collegeMatch;
      }

      return categoryMatch && queryMatch;
    }).toList();
  }

  void subscribeToUserMatches(String userId) {
    _currentUserId = userId;
    _matchesSubscription?.cancel();
    _matchesSubscription = _firestoreService.streamUserMatches(userId).listen((list) {
      _dbMatches = list;
      notifyListeners();
    }, onError: (err) {
      _error = err.toString();
      notifyListeners();
    });
  }

  Future<void> sendSwapRequest(MatchModel match) async {
    try {
      final updatedMatch = MatchModel(
        id: match.id,
        userOneId: match.userOneId,
        userTwoId: match.userTwoId,
        userOneName: match.userOneName,
        userTwoName: match.userTwoName,
        userOneProfilePic: match.userOneProfilePic,
        userTwoProfilePic: match.userTwoProfilePic,
        userOneSkillWanted: match.userOneSkillWanted,
        userTwoSkillWanted: match.userTwoSkillWanted,
        matchPercentage: match.matchPercentage,
        status: 'requested',
        timestamp: DateTime.now(),
      );
      await _firestoreService.createMatch(updatedMatch);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> acceptSwapRequest(MatchModel match) async {
    try {
      await _firestoreService.updateMatchStatus(match.id, 'accepted');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectSwapRequest(MatchModel match) async {
    try {
      await _firestoreService.updateMatchStatus(match.id, 'rejected');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }
}
