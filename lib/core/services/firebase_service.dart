import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isConfigured = false;
  static bool get isConfigured => _isConfigured;

  static FirebaseAuth? _auth;
  static FirebaseFirestore? _db;

  static Future<void> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.isEmpty || options.apiKey.contains('_YOUR_') || options.apiKey.contains('PLACEHOLDER')) {
        throw Exception("Firebase API Key is empty or placeholder. Deferring connection.");
      }
      try {
        await Firebase.initializeApp(
          options: options,
        );
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          debugPrint("Firebase already initialized (duplicate-app). Using existing instance.");
        } else {
          rethrow;
        }
      }
      _auth = FirebaseAuth.instance;
      _db = FirebaseFirestore.instance;
      _isConfigured = true;
      debugPrint("Firebase Initialized successfully.");
    } catch (e) {
      _isConfigured = false;
      debugPrint("Firebase connection deferred: Config options not found. Offline replica active. Error: $e");
    }
  }

  // Authentication Handlers
  static Future<UserCredential?> signUp(String email, String password) async {
    if (!_isConfigured) return null;
    try {
      return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Firebase Auth Error: $e");
      rethrow;
    }
  }

  static Future<UserCredential?> login(String email, String password) async {
    if (!_isConfigured) return null;
    try {
      return await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Firebase Auth Error: $e");
      rethrow;
    }
  }

  static Future<void> logout() async {
    if (!_isConfigured) return;
    await _auth!.signOut();
  }

  // Sync utilities using Firestore collections
  static Future<void> syncUserProfile(String userId, {
    required String username,
    required String email,
    required int xp,
    required int coins,
    required int streak,
    required bool isPremium,
  }) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId);
      await ref.set({
        'profile': {
          'username': username,
          'email': email,
          'xp': xp,
          'coins': coins,
          'streak': streak,
          'isPremium': isPremium,
          'lastSynced': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<void> syncUserStats(String userId, {
    required int completedQuizCount,
    required int totalAnswersCorrect,
    required int totalAnswersSelected,
    required int completedCodingProblems,
    required int totalGamesWon,
  }) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId);
      await ref.set({
        'statistics': {
          'completedQuizCount': completedQuizCount,
          'totalAnswersCorrect': totalAnswersCorrect,
          'totalAnswersSelected': totalAnswersSelected,
          'completedCodingProblems': completedCodingProblems,
          'totalGamesWon': totalGamesWon,
          'lastSynced': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<void> syncUserBadges(String userId, List<String> badges) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId);
      await ref.set({
        'badges': badges,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<void> syncDailyChallenges(String userId, {
    required bool dailyCompletedAptitude,
    required bool dailyCompletedCoding,
    required bool dailyCompletedWord,
    required bool dailyCompletedMemory,
  }) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId);
      await ref.set({
        'daily_challenges': {
          'aptitude': dailyCompletedAptitude,
          'coding': dailyCompletedCoding,
          'word': dailyCompletedWord,
          'memory': dailyCompletedMemory,
          'allCompleted': dailyCompletedAptitude && dailyCompletedCoding && dailyCompletedWord && dailyCompletedMemory,
          'lastSynced': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<String?> uploadResume(String userId, Map<String, dynamic> resume) async {
    if (!_isConfigured) return null;
    try {
      final ref = _db!.collection('users').doc(userId).collection('resumes').doc();
      await ref.set(resume);
      return ref.id;
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
      return null;
    }
  }

  static Future<void> removeResume(String userId, String resumeKey) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId).collection('resumes').doc(resumeKey);
      await ref.delete();
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<Map<String, dynamic>?> fetchUserData(String userId, {bool rethrowError = false}) async {
    if (!_isConfigured) return null;
    try {
      final profileDoc = await _db!.collection('users').doc(userId).get();
      if (!profileDoc.exists) return null;

      final Map<String, dynamic> result = {};
      final userData = profileDoc.data();
      
      if (userData != null) {
        if (userData.containsKey('profile')) {
          result['profile'] = userData['profile'];
        }
        if (userData.containsKey('statistics')) {
          result['statistics'] = userData['statistics'];
        }
        if (userData.containsKey('badges')) {
          result['badges'] = userData['badges'];
        }
        if (userData.containsKey('daily_challenges')) {
          result['daily_challenges'] = userData['daily_challenges'];
        }
      }

      // Fetch resumes
      final resumesDocs = await _db!.collection('users').doc(userId).collection('resumes').get();
      if (resumesDocs.docs.isNotEmpty) {
        final Map<String, dynamic> resumesMap = {};
        for (var doc in resumesDocs.docs) {
          resumesMap[doc.id] = doc.data();
        }
        result['resumes'] = resumesMap;
      }

      return result;
    } catch (e) {
      debugPrint("Firestore Database Fetch Error: $e");
      if (rethrowError) rethrow;
      return null;
    }
  }
}
