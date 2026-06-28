import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  String _apiKey = '';
  bool _isLoading = false;
  String? _error;

  // Cached AI generated contents
  final Map<String, String> _roadmaps = {}; // skillName -> markdown roadmap
  final Map<String, String> _careerGuidance = {}; // dreamJob -> markdown career guidance
  List<String> _suggestedSkills = [];

  String get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get suggestedSkills => _suggestedSkills;

  void setApiKey(String key) {
    _apiKey = key;
    _aiService.setApiKey(key);
    notifyListeners();
  }

  String? getRoadmap(String skillName) => _roadmaps[skillName];
  String? getCareerGuidance(String dreamJob) => _careerGuidance[dreamJob];

  Future<void> loadRoadmap(String skillName) async {
    if (_roadmaps.containsKey(skillName)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _aiService.generateLearningRoadmap(skillName);
      _roadmaps[skillName] = res;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCareerGuidance(List<String> skills, String dreamJob) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _aiService.generateCareerGuidance(skills, dreamJob);
      _careerGuidance[dreamJob] = res;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSkillSuggestions(List<String> interests) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _suggestedSkills = await _aiService.getSkillRecommendations(interests);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateSessionSummary(String skillName, String notes) async {
    return await _aiService.generateSessionSummary(skillName, notes);
  }

  Future<bool> checkSpamReview(String review) async {
    return await _aiService.detectFakeReview(review);
  }
}
