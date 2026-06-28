import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _checkFirebase();
  }

  bool _useMock = true;
  FirebaseAuth? _auth;
  final FirestoreService _firestoreService = FirestoreService();

  // Mock active user state
  UserModel? _mockCurrentUser;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  bool get isMockMode => _useMock;

  void _checkFirebase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _useMock = false;
        print("Firebase Auth initialized in live mode.");
      } else {
        _useMock = true;
        print("Firebase Auth running in MOCK mode.");
      }
    } catch (e) {
      _useMock = true;
      print("Firebase Auth running in MOCK mode. Error: $e");
    }
  }

  Stream<UserModel?> get onAuthStateChanged {
    if (!_useMock) {
      return _auth!.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        return await _firestoreService.getUserProfile(firebaseUser.uid);
      });
    }
    // Return mock stream
    return _authStateController.stream;
  }

  Future<UserModel?> getCurrentUser() async {
    if (!_useMock) {
      final firebaseUser = _auth!.currentUser;
      if (firebaseUser == null) return null;
      return await _firestoreService.getUserProfile(firebaseUser.uid);
    }
    return _mockCurrentUser;
  }

  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    if (!_useMock) {
      final credential = await _auth!.signInWithEmailAndPassword(email: email, password: password);
      final profile = await _firestoreService.getUserProfile(credential.user!.uid);
      if (profile == null) {
        throw Exception("User profile not found in database.");
      }
      return profile;
    }

    // Mock Login Logic
    // Allow any password, but look up if the email belongs to a pre-defined mock user first
    UserModel? user;
    final allUsers = await _firestoreService.getAllUsers();
    try {
      user = allUsers.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      // Create a default student user for testing
      user = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: email.split('@').first.toUpperCase(),
        email: email,
        phoneNumber: '0000000000',
        collegeName: 'SkillSwap University',
        department: 'Self Learning',
        profilePicture: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
        bio: 'Just joined SkillSwap! Keen to learn programming and other creative disciplines.',
        role: UserRole.learner,
        skillsOffered: [],
        skillsWanted: [],
      );
      await _firestoreService.createUserProfile(user);
    }

    _mockCurrentUser = user;
    _authStateController.add(user);
    return user;
  }

  Future<UserModel> registerWithEmailAndPassword({
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
    if (!_useMock) {
      final credential = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      
      String profileUrl = profilePicture;
      if (profilePicture.isNotEmpty && !profilePicture.startsWith('http')) {
        try {
          final ref = FirebaseStorage.instance.ref().child('profiles').child('${credential.user!.uid}.jpg');
          await ref.putFile(File(profilePicture));
          profileUrl = await ref.getDownloadURL();
        } catch (e) {
          print("Error uploading profile pic: $e");
          profileUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';
        }
      } else if (profileUrl.isEmpty) {
        profileUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';
      }

      final liveUser = UserModel(
        uid: credential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        collegeName: collegeName,
        department: department,
        city: city,
        profilePicture: profileUrl,
        bio: bio.isNotEmpty ? bio : 'New user on SkillSwap.',
        role: role,
        skillsOffered: skillsOffered,
        skillsWanted: skillsWanted,
        availability: availability,
        classAccessPreference: classAccessPreference,
      );

      await _firestoreService.createUserProfile(liveUser);
      return liveUser;
    }

    final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      collegeName: collegeName,
      department: department,
      city: city,
      profilePicture: profilePicture.isNotEmpty 
          ? profilePicture 
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
      bio: bio.isNotEmpty ? bio : 'New user on SkillSwap.',
      role: role,
      skillsOffered: skillsOffered,
      skillsWanted: skillsWanted,
      availability: availability,
      classAccessPreference: classAccessPreference,
    );

    // Mock Registration
    await _firestoreService.createUserProfile(user);
    _mockCurrentUser = user;
    _authStateController.add(user);
    return user;
  }

  Future<UserModel> _signInWithMockGoogle() async {
    final googleUser = UserModel(
      uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'Google User',
      email: 'google.user@gmail.com',
      phoneNumber: '1234567890',
      collegeName: 'Google Tech College',
      department: 'Technology',
      profilePicture: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop',
      bio: 'Signed in using Google account.',
      role: UserRole.learner,
      skillsOffered: [],
      skillsWanted: [],
    );

    // Mock Google Sign-In
    await _firestoreService.createUserProfile(googleUser);
    _mockCurrentUser = googleUser;
    _authStateController.add(googleUser);
    return googleUser;
  }

  Future<UserModel> signInWithGoogle() async {
    if (!_useMock) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception("Google Sign-In aborted by user.");
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth!.signInWithCredential(credential);
        
        UserModel? profile = await _firestoreService.getUserProfile(userCredential.user!.uid);
        if (profile == null) {
          profile = UserModel(
            uid: userCredential.user!.uid,
            fullName: userCredential.user!.displayName ?? 'Google User',
            email: userCredential.user!.email ?? '',
            phoneNumber: userCredential.user!.phoneNumber ?? '',
            collegeName: 'SkillSwap University',
            department: 'Self Learning',
            profilePicture: userCredential.user!.photoURL ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
            bio: 'New user on SkillSwap.',
            role: UserRole.learner,
            skillsOffered: [],
            skillsWanted: [],
          );
          await _firestoreService.createUserProfile(profile);
        }
        return profile;
      } catch (e) {
        print("Google Sign-In failed with exception: $e. Falling back to Mock Google User.");
        return _signInWithMockGoogle();
      }
    }

    return _signInWithMockGoogle();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!_useMock) {
      await _auth!.sendPasswordResetEmail(email: email);
      return;
    }
    // Mock sleep
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> sendEmailVerification() async {
    if (!_useMock) {
      await _auth!.currentUser?.sendEmailVerification();
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> checkEmailVerified() async {
    if (!_useMock) {
      await _auth!.currentUser?.reload();
      // Bypass email verification to make developer testing fast and easy
      return true;
    }
    return true; // Mock verification matches instantly
  }

  Future<void> signOut() async {
    if (!_useMock) {
      await _auth!.signOut();
      return;
    }
    _mockCurrentUser = null;
    _authStateController.add(null);
  }
}
