import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'dynamic_data_service.dart';

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
      try {
        _db!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint("Firestore offline persistence enabled.");
      } catch (e) {
        debugPrint("Failed to set Firestore settings (likely already initialized): $e");
      }
      _isConfigured = true;
      debugPrint("Firebase Initialized successfully.");
      
      // Async seed call in background
      DynamicDataService.initializeCollectionsIfEmpty();
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
      final ref = _db!.collection('users').doc(userId).collection('profile').doc('data');
      await ref.set({
        'username': username,
        'email': email,
        'xp': xp,
        'coins': coins,
        'streak': streak,
        'isPremium': isPremium,
        'lastSynced': FieldValue.serverTimestamp(),
      });
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
      final ref = _db!.collection('users').doc(userId).collection('statistics').doc('data');
      await ref.set({
        'completedQuizCount': completedQuizCount,
        'totalAnswersCorrect': totalAnswersCorrect,
        'totalAnswersSelected': totalAnswersSelected,
        'completedCodingProblems': completedCodingProblems,
        'totalGamesWon': totalGamesWon,
        'lastSynced': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore Database Error: $e");
    }
  }

  static Future<void> syncUserBadges(String userId, List<String> badges) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId).collection('badges').doc('data');
      await ref.set({
        'badges': badges,
        'lastSynced': FieldValue.serverTimestamp(),
      });
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
      final ref = _db!.collection('users').doc(userId).collection('daily_challenges').doc('data');
      await ref.set({
        'aptitude': dailyCompletedAptitude,
        'coding': dailyCompletedCoding,
        'word': dailyCompletedWord,
        'memory': dailyCompletedMemory,
        'allCompleted': dailyCompletedAptitude && dailyCompletedCoding && dailyCompletedWord && dailyCompletedMemory,
        'lastSynced': FieldValue.serverTimestamp(),
      });
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
      final profileFuture = _db!.collection('users').doc(userId).collection('profile').doc('data').get().timeout(const Duration(seconds: 3));
      final statsFuture = _db!.collection('users').doc(userId).collection('statistics').doc('data').get().timeout(const Duration(seconds: 3));
      final badgesFuture = _db!.collection('users').doc(userId).collection('badges').doc('data').get().timeout(const Duration(seconds: 3));
      final settingsFuture = _db!.collection('users').doc(userId).collection('settings').doc('data').get().timeout(const Duration(seconds: 3));
      final dailyFuture = _db!.collection('users').doc(userId).collection('daily_challenges').doc('data').get().timeout(const Duration(seconds: 3));
      final historyFuture = _db!.collection('users').doc(userId).collection('history').orderBy('date', descending: true).limit(50).get().timeout(const Duration(seconds: 3));
      final resumesFuture = _db!.collection('users').doc(userId).collection('resumes').get().timeout(const Duration(seconds: 3));

      final results = await Future.wait([
        profileFuture,
        statsFuture,
        badgesFuture,
        settingsFuture,
        dailyFuture,
        historyFuture,
        resumesFuture,
      ]);

      final profileDoc = results[0] as DocumentSnapshot;
      final statsDoc = results[1] as DocumentSnapshot;
      final badgesDoc = results[2] as DocumentSnapshot;
      final settingsDoc = results[3] as DocumentSnapshot;
      final dailyDoc = results[4] as DocumentSnapshot;
      final historySnapshot = results[5] as QuerySnapshot;
      final resumesSnapshot = results[6] as QuerySnapshot;

      if (!profileDoc.exists) return null;

      final Map<String, dynamic> result = {};
      
      // profile
      result['profile'] = profileDoc.data();

      // statistics
      if (statsDoc.exists) {
        result['statistics'] = statsDoc.data();
      }

      // badges
      if (badgesDoc.exists && badgesDoc.data() != null) {
        final data = badgesDoc.data() as Map<String, dynamic>;
        if (data.containsKey('badges')) {
          result['badges'] = data['badges'];
        }
      }

      // settings
      if (settingsDoc.exists) {
        result['settings'] = settingsDoc.data();
      }

      // daily challenges
      if (dailyDoc.exists) {
        result['daily_challenges'] = dailyDoc.data();
      }

      // history
      if (historySnapshot.docs.isNotEmpty) {
        result['history'] = historySnapshot.docs.map((doc) => doc.data()).toList();
      }

      // resumes
      if (resumesSnapshot.docs.isNotEmpty) {
        final Map<String, dynamic> resumesMap = {};
        for (var doc in resumesSnapshot.docs) {
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

  // Activity History Handlers (Stored in nested subcollection)
  static Future<void> syncUserHistory(String userId, List<Map<String, dynamic>> historyLogs) async {
    if (!_isConfigured) return;
    try {
      final batch = _db!.batch();
      for (var log in historyLogs) {
        if (log.containsKey('date')) {
          // Use the date timestamp string safely formatted as document ID to prevent duplicate items
          final docId = log['date'].toString().replaceAll('.', '_').replaceAll(':', '_').replaceAll('/', '_');
          final ref = _db!.collection('users').doc(userId).collection('history').doc(docId);
          batch.set(ref, log);
        }
      }
      await batch.commit().timeout(const Duration(seconds: 4));
      debugPrint("[FirebaseService] History synced successfully inside subcollection.");
    } catch (e) {
      debugPrint("[FirebaseService] Firestore History Sync Error: $e");
    }
  }

  // App Settings Sync
  static Future<void> syncUserSettings(String userId, Map<String, dynamic> settings) async {
    if (!_isConfigured) return;
    try {
      final ref = _db!.collection('users').doc(userId).collection('settings').doc('data');
      await ref.set({
        ...settings,
        'lastSynced': FieldValue.serverTimestamp(),
      });
      debugPrint("[FirebaseService] Settings synced successfully for user $userId.");
    } catch (e) {
      debugPrint("[FirebaseService] Firestore Settings Sync Error: $e");
    }
  }
}
