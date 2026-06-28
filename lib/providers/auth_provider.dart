import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _isLoading = true;
    notifyListeners();

    _authService.onAuthStateChanged.listen((user) {
      _currentUser = user;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> initCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String collegeName,
    required String department,
    required String city,
    required String bio,
    required List<OfferedSkill> skillsOffered,
    required List<OfferedSkill> skillsWanted,
    required String availability,
    required String profilePicture,
    required UserRole role,
    required String classAccessPreference,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.registerWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        collegeName: collegeName,
        department: department,
        city: city,
        bio: bio,
        skillsOffered: skillsOffered,
        skillsWanted: skillsWanted,
        availability: availability,
        profilePicture: profilePicture,
        role: role,
        classAccessPreference: classAccessPreference,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendForgotPasswordEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // --- PROFILE UPDATE SUB-ROUTINES ---

  Future<void> updateBio(String bio) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = _currentUser!.copyWith(bio: bio);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCollegeAndDepartment(String college, String dept) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = _currentUser!.copyWith(collegeName: college, department: dept);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture(String path) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      String profileUrl = path;
      if (!_authService.isMockMode && path.isNotEmpty && !path.startsWith('http')) {
        try {
          final ref = FirebaseStorage.instance.ref().child('profiles').child('${_currentUser!.uid}.jpg');
          await ref.putFile(File(path));
          profileUrl = await ref.getDownloadURL();
        } catch (e) {
          print("Error uploading profile pic to storage: $e");
        }
      }
      final updated = _currentUser!.copyWith(profilePicture: profileUrl);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOfferedSkill(String skillName, String level) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final offered = List<OfferedSkill>.from(_currentUser!.skillsOffered);
      offered.removeWhere((s) => s.skillName.toLowerCase() == skillName.toLowerCase());
      offered.add(OfferedSkill(skillName: skillName, level: level));

      final updated = _currentUser!.copyWith(skillsOffered: offered);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWantedSkill(String skillName, String level) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final wanted = List<OfferedSkill>.from(_currentUser!.skillsWanted);
      wanted.removeWhere((s) => s.skillName.toLowerCase() == skillName.toLowerCase());
      wanted.add(OfferedSkill(skillName: skillName, level: level));

      final updated = _currentUser!.copyWith(skillsWanted: wanted);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSkill(String skillName, bool isOffered) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      if (isOffered) {
        final offered = List<OfferedSkill>.from(_currentUser!.skillsOffered);
        offered.removeWhere((s) => s.skillName.toLowerCase() == skillName.toLowerCase());
        final updated = _currentUser!.copyWith(skillsOffered: offered);
        await _firestoreService.updateUserProfile(updated);
        _currentUser = updated;
      } else {
        final wanted = List<OfferedSkill>.from(_currentUser!.skillsWanted);
        wanted.removeWhere((s) => s.skillName.toLowerCase() == skillName.toLowerCase());
        final updated = _currentUser!.copyWith(skillsWanted: wanted);
        await _firestoreService.updateUserProfile(updated);
        _currentUser = updated;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClassAccessPreference(String preference) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = _currentUser!.copyWith(classAccessPreference: preference);
      await _firestoreService.updateUserProfile(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
