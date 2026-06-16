import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';
import 'firebase_service.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Profile data
  String _uid = '';
  int _coins = 120;
  int _xp = 180;
  int _streak = 3;
  String _lastActiveDate = '';
  bool _isPremium = false;
  String _username = 'Guest Explorer';
  String _email = 'guest@skillarena.com';
  bool _isLoggedIn = false;

  // Stats
  int _completedQuizCount = 8;
  int _totalAnswersCorrect = 32;
  int _totalAnswersSelected = 40;
  int _completedCodingProblems = 5;
  int _totalGamesWon = 12;

  // Daily Challenge checklists
  bool _dailyCompletedAptitude = false;
  bool _dailyCompletedCoding = false;
  bool _dailyCompletedWord = false;
  bool _dailyCompletedMemory = false;

  // Badges unlocked
  List<String> _unlockedBadges = ['Aptitude Rookie', 'Quick Learner'];

  // Resume builder data
  List<Map<String, dynamic>> _savedResumes = [];

  // Theme settings
  String _selectedTheme = 'cyberpunk';
  String get selectedTheme => _selectedTheme;

  // Application Settings
  bool _soundEffectsEnabled = true;
  bool _hapticsEnabled = true;
  bool _liveSyncEnabled = true;
  int _quizTimeLimit = 20;
  String _interviewRigor = 'Standard';
  String _adFrequency = 'Standard';
  bool _mpinEnabled = false;
  String _mpinValue = '';
  bool _isDarkMode = true;
  String _language = 'English';

  // Getters
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get liveSyncEnabled => _liveSyncEnabled;
  int get quizTimeLimit => _quizTimeLimit;
  String get interviewRigor => _interviewRigor;
  String get adFrequency => _adFrequency;
  bool get mpinEnabled => _mpinEnabled;
  String get mpinValue => _mpinValue;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  // Logs for visual Firebase DB simulation
  final List<String> _dbSyncLogs = [];
  
  // Persistent user history logs
  List<Map<String, dynamic>> _historyLogs = [];

  // Getters
  String get uid => _uid;
  int get coins => _coins;
  int get xp => _xp;
  int get streak => _streak;
  bool get isPremium => _isPremium;
  String get username => _username;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  int get level => 1 + (_xp ~/ 300);
  double get xpProgressPercent => (_xp % 300) / 300.0;

  int get completedQuizCount => _completedQuizCount;
  int get totalAnswersCorrect => _totalAnswersCorrect;
  int get totalAnswersSelected => _totalAnswersSelected;
  int get completedCodingProblems => _completedCodingProblems;
  int get totalGamesWon => _totalGamesWon;

  double get quizAccuracy => _totalAnswersSelected == 0 
      ? 0.0 
      : (_totalAnswersCorrect / _totalAnswersSelected);

  bool get dailyCompletedAptitude => _dailyCompletedAptitude;
  bool get dailyCompletedCoding => _dailyCompletedCoding;
  bool get dailyCompletedWord => _dailyCompletedWord;
  bool get dailyCompletedMemory => _dailyCompletedMemory;

  bool get isDailyChallengeCompleted => 
      _dailyCompletedAptitude && 
      _dailyCompletedCoding && 
      _dailyCompletedWord && 
      _dailyCompletedMemory;

  List<String> get unlockedBadges => _unlockedBadges;
  List<Map<String, dynamic>> get savedResumes => _savedResumes;
  List<String> get dbSyncLogs => _dbSyncLogs.reversed.toList();
  List<Map<String, dynamic>> get historyLogs => _historyLogs;

  AppState(this._prefs) {
    _initPrefs();
  }

  void _initPrefs() {
    _uid = _prefs.getString('uid') ?? '';
    _coins = _prefs.getInt('coins') ?? 120;
    _xp = _prefs.getInt('xp') ?? 180;
    _streak = _prefs.getInt('streak') ?? 3;
    _lastActiveDate = _prefs.getString('lastActiveDate') ?? '';
    _isPremium = _prefs.getBool('isPremium') ?? false;
    _username = _prefs.getString('username') ?? 'Guest Explorer';
    _email = _prefs.getString('email') ?? 'guest@skillarena.com';
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    _selectedTheme = _prefs.getString('selectedTheme') ?? 'cyberpunk';
    AppColors.activeTheme = _selectedTheme;

    _soundEffectsEnabled = _prefs.getBool('soundEffectsEnabled') ?? true;
    _hapticsEnabled = _prefs.getBool('hapticsEnabled') ?? true;
    _liveSyncEnabled = _prefs.getBool('liveSyncEnabled') ?? true;
    _quizTimeLimit = _prefs.getInt('quizTimeLimit') ?? 20;
    _interviewRigor = _prefs.getString('interviewRigor') ?? 'Standard';
    _adFrequency = _prefs.getString('adFrequency') ?? 'Standard';
    _mpinEnabled = _prefs.getBool('mpinEnabled') ?? false;
    _mpinValue = _prefs.getString('mpinValue') ?? '';
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    AppColors.isDarkMode = _isDarkMode;
    _language = _prefs.getString('language') ?? 'English';

    _completedQuizCount = _prefs.getInt('completedQuizCount') ?? 8;
    _totalAnswersCorrect = _prefs.getInt('totalAnswersCorrect') ?? 32;
    _totalAnswersSelected = _prefs.getInt('totalAnswersSelected') ?? 40;
    _completedCodingProblems = _prefs.getInt('completedCodingProblems') ?? 5;
    _totalGamesWon = _prefs.getInt('totalGamesWon') ?? 12;

    _dailyCompletedAptitude = _prefs.getBool('dailyCompletedAptitude') ?? false;
    _dailyCompletedCoding = _prefs.getBool('dailyCompletedCoding') ?? false;
    _dailyCompletedWord = _prefs.getBool('dailyCompletedWord') ?? false;
    _dailyCompletedMemory = _prefs.getBool('dailyCompletedMemory') ?? false;

    _unlockedBadges = _prefs.getStringList('unlockedBadges') ?? ['Aptitude Rookie', 'Quick Learner'];

    final resumesJson = _prefs.getString('savedResumes') ?? '[]';
    try {
      _savedResumes = List<Map<String, dynamic>>.from(json.decode(resumesJson));
    } catch (_) {
      _savedResumes = [];
    }

    final historyJson = _prefs.getString('historyLogs') ?? '[]';
    try {
      _historyLogs = List<Map<String, dynamic>>.from(json.decode(historyJson));
    } catch (_) {
      _historyLogs = [];
    }

    _checkStreakReset();
    _isInitialized = true;
    _logDbSync('Initialized app state from local cache.');
    if (FirebaseService.isConfigured) {
      _logDbSync('Connected to Live Firebase Database. Sync active.');
      if (_isLoggedIn && _uid.isNotEmpty) {
        FirebaseService.fetchUserData(_uid).then((data) {
          if (data != null) {
            restoreUserData(data);
          }
        });
      }
    } else {
      _logDbSync('Firebase config not found. Local offline replica active.');
    }
  }

  void _checkStreakReset() {
    final today = _getTodayString();
    if (_lastActiveDate.isNotEmpty && _lastActiveDate != today) {
      // If it's the day after last active, streak is fine. If missed more than 1 day, reset.
      try {
        final lastDate = DateTime.parse(_lastActiveDate);
        final currentDate = DateTime.parse(today);
        final difference = currentDate.difference(lastDate).inDays;
        
        if (difference > 1) {
          _streak = 0;
          _prefs.setInt('streak', 0);
          _logDbSync('Streak reset due to inactivity.');
        }
      } catch (_) {}
      
      // Reset daily challenges on new day
      _dailyCompletedAptitude = false;
      _dailyCompletedCoding = false;
      _dailyCompletedWord = false;
      _dailyCompletedMemory = false;
      _prefs.setBool('dailyCompletedAptitude', false);
      _prefs.setBool('dailyCompletedCoding', false);
      _prefs.setBool('dailyCompletedWord', false);
      _prefs.setBool('dailyCompletedMemory', false);
      _logDbSync('New day: Daily challenges reset.');
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _logDbSync(String description) {
    final timeStr = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);
    final logMessage = '[$timeStr] Firebase Sync: $description';
    _dbSyncLogs.add(logMessage);
    if (_dbSyncLogs.length > 20) {
      _dbSyncLogs.removeAt(0);
    }
    notifyListeners();
  }

  // Setters & Actions
  Future<void> login({
    required String uid,
    required String username,
    required String email,
    bool syncData = true,
  }) async {
    _uid = uid;
    _username = username;
    _email = email;
    _isLoggedIn = true;
    
    await _prefs.setString('uid', uid);
    await _prefs.setString('username', username);
    await _prefs.setString('email', email);
    await _prefs.setBool('isLoggedIn', true);
    
    _logDbSync('User Logged In ($username). Created record path `/users/$uid`.');
    
    if (FirebaseService.isConfigured) {
      FirebaseService.fetchUserData(uid).then((data) {
        if (data != null) {
          restoreUserData(data);
        }
      });
    }

    // Add login badge if not exists
    unlockBadge('Pioneer');
    await recordHistory(
      feature: '🔑 Security & Login',
      details: 'User logged in to SkillArena',
      result: 'Logged In',
    );
    if (syncData) {
      _syncWithFirebase();
      _syncSettingsWithFirebase();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _uid = '';
    _username = 'Guest Explorer';
    _email = 'guest@skillarena.com';
    _isLoggedIn = false;
    _coins = 120;
    _xp = 180;
    _streak = 3;
    _completedQuizCount = 8;
    _totalAnswersCorrect = 32;
    _totalAnswersSelected = 40;
    _completedCodingProblems = 5;
    _totalGamesWon = 12;
    _dailyCompletedAptitude = false;
    _dailyCompletedCoding = false;
    _dailyCompletedWord = false;
    _dailyCompletedMemory = false;
    _unlockedBadges = ['Aptitude Rookie', 'Quick Learner'];
    _savedResumes = [];
    _historyLogs = [];
    
    await _prefs.setString('uid', '');
    await _prefs.setString('username', _username);
    await _prefs.setString('email', _email);
    await _prefs.setBool('isLoggedIn', false);
    await _prefs.setInt('coins', _coins);
    await _prefs.setInt('xp', _xp);
    await _prefs.setInt('streak', _streak);
    await _prefs.setInt('completedQuizCount', _completedQuizCount);
    await _prefs.setInt('totalAnswersCorrect', _totalAnswersCorrect);
    await _prefs.setInt('totalAnswersSelected', _totalAnswersSelected);
    await _prefs.setInt('completedCodingProblems', _completedCodingProblems);
    await _prefs.setInt('totalGamesWon', _totalGamesWon);
    await _prefs.setBool('dailyCompletedAptitude', false);
    await _prefs.setBool('dailyCompletedCoding', false);
    await _prefs.setBool('dailyCompletedWord', false);
    await _prefs.setBool('dailyCompletedMemory', false);
    await _prefs.setStringList('unlockedBadges', _unlockedBadges);
    await _prefs.setString('savedResumes', '[]');
    await _prefs.setString('historyLogs', '[]');
    
    if (FirebaseService.isConfigured) {
      await FirebaseService.logout();
    }
    
    _logDbSync('User Logged Out. Listening on local workspace cache.');
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _prefs.setInt('coins', _coins);
    _logDbSync('Updated coins count (+ $amount). Path `/users/$_uid/coins`: $_coins');
    _syncWithFirebase();
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      await _prefs.setInt('coins', _coins);
      _logDbSync('Subtracted coins (- $amount). Path `/users/$_uid/coins`: $_coins');
      _syncWithFirebase();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> addXp(int amount) async {
    final oldLevel = level;
    _xp += amount;
    await _prefs.setInt('xp', _xp);
    _logDbSync('Updated XP (+ $amount). Path `/users/$_uid/xp`: $_xp');
    
    if (level > oldLevel) {
      _logDbSync('LEVEL UP! Unlocked Level $level. Path `/users/$_uid/level`: $level');
      unlockBadge('Level $level Achiever');
      addCoins(level * 25);
    } else {
      _syncWithFirebase();
    }
    notifyListeners();
  }

  Future<void> recordQuizResult(int correct, int total, {List<Map<String, dynamic>>? questionsHistory}) async {
    _completedQuizCount += 1;
    _totalAnswersCorrect += correct;
    _totalAnswersSelected += total;

    await _prefs.setInt('completedQuizCount', _completedQuizCount);
    await _prefs.setInt('totalAnswersCorrect', _totalAnswersCorrect);
    await _prefs.setInt('totalAnswersSelected', _totalAnswersSelected);

    _logDbSync('Quiz record submitted. Accuracy is now ${(quizAccuracy * 100).toStringAsFixed(1)}%.');
    await recordHistory(
      feature: '🧠 Aptitude Quiz',
      details: 'Completed quantitative/logical aptitude quiz',
      result: '$correct/$total correct',
      questionsHistory: questionsHistory,
    );
    
    if (_completedQuizCount >= 10) {
      unlockBadge('Quiz Marathoner');
    } else {
      _syncWithFirebase();
    }
    
    notifyListeners();
  }

  Future<void> recordCodingProblemSolved({List<Map<String, dynamic>>? questionsHistory}) async {
    _completedCodingProblems += 1;
    await _prefs.setInt('completedCodingProblems', _completedCodingProblems);
    _logDbSync('Coding Problem Solved. Path `/users/$_uid/stats/coding`: $_completedCodingProblems');
    await recordHistory(
      feature: '💻 Coding challenge',
      details: 'Solved practice coding problem',
      result: 'Success',
      questionsHistory: questionsHistory,
    );
    
    if (_completedCodingProblems >= 5) {
      unlockBadge('DSA Ninja');
    } else {
      _syncWithFirebase();
    }
    notifyListeners();
  }

  Future<void> recordGameWon() async {
    _totalGamesWon += 1;
    await _prefs.setInt('totalGamesWon', _totalGamesWon);
    _logDbSync('Multiplayer Game Won. Total games won: $_totalGamesWon');
    await recordHistory(
      feature: '🎮 Multiplayer game',
      details: 'Won multiplayer duel',
      result: 'Won',
    );
    
    if (_totalGamesWon >= 15) {
      unlockBadge('Arena Champion');
    } else {
      _syncWithFirebase();
    }
    notifyListeners();
  }

  Future<void> unlockBadge(String badge) async {
    if (!_unlockedBadges.contains(badge)) {
      _unlockedBadges.add(badge);
      await _prefs.setStringList('unlockedBadges', _unlockedBadges);
      _logDbSync('New Achievement! Unlocked Badge: $badge. Path `/users/$_uid/badges`');
      addCoins(50); // reward for badge will trigger sync
      notifyListeners();
    }
  }

  // Daily challenges completion
  Future<void> completeDailyAptitude() async {
    if (!_dailyCompletedAptitude) {
      _dailyCompletedAptitude = true;
      await _prefs.setBool('dailyCompletedAptitude', true);
      _logDbSync('Daily challenge part (Aptitude) completed.');
      await recordHistory(
        feature: '🧠 Daily Aptitude',
        details: 'Completed Daily Aptitude Challenge',
        result: 'Success',
      );
      _checkAllDailyCompleted();
      _syncDailyChallenges();
      notifyListeners();
    }
  }

  Future<void> completeDailyCoding() async {
    if (!_dailyCompletedCoding) {
      _dailyCompletedCoding = true;
      await _prefs.setBool('dailyCompletedCoding', true);
      _logDbSync('Daily challenge part (Coding) completed.');
      await recordHistory(
        feature: '💻 Daily Coding',
        details: 'Completed Daily Coding Challenge',
        result: 'Success',
      );
      _checkAllDailyCompleted();
      _syncDailyChallenges();
      notifyListeners();
    }
  }

  Future<void> completeDailyWord() async {
    if (!_dailyCompletedWord) {
      _dailyCompletedWord = true;
      await _prefs.setBool('dailyCompletedWord', true);
      _logDbSync('Daily challenge part (Word Puzzle) completed.');
      await recordHistory(
        feature: '🔤 Daily Word Puzzle',
        details: 'Completed Daily Word Search Challenge',
        result: 'Success',
      );
      _checkAllDailyCompleted();
      _syncDailyChallenges();
      notifyListeners();
    }
  }

  Future<void> completeDailyMemory() async {
    if (!_dailyCompletedMemory) {
      _dailyCompletedMemory = true;
      await _prefs.setBool('dailyCompletedMemory', true);
      _logDbSync('Daily challenge part (Brain Game) completed.');
      await recordHistory(
        feature: '🎯 Daily Memory Match',
        details: 'Completed Daily Memory Match Challenge',
        result: 'Success',
      );
      _checkAllDailyCompleted();
      _syncDailyChallenges();
      notifyListeners();
    }
  }

  void _checkAllDailyCompleted() {
    if (isDailyChallengeCompleted) {
      final today = _getTodayString();
      if (_lastActiveDate != today) {
        _streak += 1;
        _lastActiveDate = today;
        _prefs.setInt('streak', _streak);
        _prefs.setString('lastActiveDate', today);
        _logDbSync('Streak incremented to $_streak! Path `/users/$_uid/streak`: $_streak');
        unlockBadge('Streak Master');
      }
      addCoins(50);
      addXp(100);
      _logDbSync('All Daily Challenges Completed! Received 50 Coins and 100 XP.');
    }
  }

  // Resume builder actions
  Future<void> saveResume(Map<String, dynamic> resume) async {
    String? firebaseKey;
    if (FirebaseService.isConfigured && _isLoggedIn) {
      firebaseKey = await FirebaseService.uploadResume(_uid, resume);
    }
    final localResume = Map<String, dynamic>.from(resume);
    if (firebaseKey != null) {
      localResume['firebaseKey'] = firebaseKey;
    }
    _savedResumes.add(localResume);
    await _prefs.setString('savedResumes', json.encode(_savedResumes));
    _logDbSync('Saved Resume: ${resume['name']}. Path `/users/$_uid/resumes`');
    await recordHistory(
      feature: '📝 Resume Builder',
      details: 'Created and saved resume: ${resume['name']}',
      result: 'Saved',
    );
    notifyListeners();
  }

  Future<void> deleteResume(int index) async {
    if (index >= 0 && index < _savedResumes.length) {
      final name = _savedResumes[index]['name'];
      final key = _savedResumes[index]['firebaseKey'];
      _savedResumes.removeAt(index);
      await _prefs.setString('savedResumes', json.encode(_savedResumes));
      _logDbSync('Deleted Resume: $name. Path `/users/$_uid/resumes`');
      await recordHistory(
        feature: '📝 Resume Builder',
        details: 'Deleted resume profile: $name',
        result: 'Deleted',
      );
      if (FirebaseService.isConfigured && _isLoggedIn && key != null) {
        FirebaseService.removeResume(_uid, key);
      }
      notifyListeners();
    }
  }

  // Simulated premium checkout
  Future<void> buyPremium() async {
    _isPremium = true;
    await _prefs.setBool('isPremium', true);
    _logDbSync('Premium subscription purchased successfully via simulated gateway. Path `/users/$_uid/profile/data/isPremium`: true');
    unlockBadge('VIP Pass');
    _syncWithFirebase();
    notifyListeners();
  }

  Future<void> cancelPremium() async {
    _isPremium = false;
    await _prefs.setBool('isPremium', false);
    _logDbSync('Premium subscription cancelled. Returning to free membership. Path `/users/$_uid/profile/data/isPremium`: false');
    _syncWithFirebase();
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    _selectedTheme = themeName;
    AppColors.activeTheme = themeName;
    await _prefs.setString('selectedTheme', themeName);
    _logDbSync('Theme changed to $themeName.');
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    AppColors.isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    _logDbSync('Dark mode toggled: $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _prefs.setString('language', value);
    _logDbSync('Language changed to $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundEffectsEnabled = value;
    await _prefs.setBool('soundEffectsEnabled', value);
    _logDbSync('Sound effects toggled: $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> toggleHaptics(bool value) async {
    _hapticsEnabled = value;
    await _prefs.setBool('hapticsEnabled', value);
    _logDbSync('Haptics simulation toggled: $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> toggleLiveSync(bool value) async {
    _liveSyncEnabled = value;
    await _prefs.setBool('liveSyncEnabled', value);
    _logDbSync('Live Cloud Sync toggled: $value.');
    if (value) {
      _syncWithFirebase();
      _syncSettingsWithFirebase();
    }
    notifyListeners();
  }

  Future<void> setQuizTimeLimit(int value) async {
    _quizTimeLimit = value;
    await _prefs.setInt('quizTimeLimit', value);
    _logDbSync('Quiz time limit set to $value seconds.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> setInterviewRigor(String value) async {
    _interviewRigor = value;
    await _prefs.setString('interviewRigor', value);
    _logDbSync('Mock Interview rigor set to $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> setAdFrequency(String value) async {
    _adFrequency = value;
    await _prefs.setString('adFrequency', value);
    _logDbSync('Simulated ad frequency set to $value.');
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> enableMpin(String pin) async {
    _mpinValue = pin;
    _mpinEnabled = true;
    await _prefs.setString('mpinValue', pin);
    await _prefs.setBool('mpinEnabled', true);
    _logDbSync('MPIN Security Lock enabled successfully.');
    await recordHistory(
      feature: '🔐 MPIN Security',
      details: 'Enabled MPIN security code lock',
      result: 'Enabled',
    );
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> disableMpin() async {
    _mpinValue = '';
    _mpinEnabled = false;
    await _prefs.setString('mpinValue', '');
    await _prefs.setBool('mpinEnabled', false);
    _logDbSync('MPIN Security Lock disabled.');
    await recordHistory(
      feature: '🔐 MPIN Security',
      details: 'Disabled MPIN security code lock',
      result: 'Disabled',
    );
    _syncSettingsWithFirebase();
    notifyListeners();
  }

  Future<void> clearSyncLogs() async {
    _dbSyncLogs.clear();
    _logDbSync('Sync logs cleared by user.');
    notifyListeners();
  }

  Future<void> resetProfileStats() async {
    _coins = 120;
    _xp = 180;
    _streak = 0;
    _completedQuizCount = 0;
    _totalAnswersCorrect = 0;
    _totalAnswersSelected = 0;
    _completedCodingProblems = 0;
    _totalGamesWon = 0;
    _dailyCompletedAptitude = false;
    _dailyCompletedCoding = false;
    _dailyCompletedWord = false;
    _dailyCompletedMemory = false;
    _unlockedBadges = ['Aptitude Rookie'];
    _savedResumes = [];
    
    await _prefs.setInt('coins', _coins);
    await _prefs.setInt('xp', _xp);
    await _prefs.setInt('streak', _streak);
    await _prefs.setInt('completedQuizCount', _completedQuizCount);
    await _prefs.setInt('totalAnswersCorrect', _totalAnswersCorrect);
    await _prefs.setInt('totalAnswersSelected', _totalAnswersSelected);
    await _prefs.setInt('completedCodingProblems', _completedCodingProblems);
    await _prefs.setInt('totalGamesWon', _totalGamesWon);
    await _prefs.setBool('dailyCompletedAptitude', false);
    await _prefs.setBool('dailyCompletedCoding', false);
    await _prefs.setBool('dailyCompletedWord', false);
    await _prefs.setBool('dailyCompletedMemory', false);
    await _prefs.setStringList('unlockedBadges', _unlockedBadges);
    await _prefs.setString('savedResumes', '[]');
    
    _logDbSync('Profile stats reset to default settings.');
    notifyListeners();
  }

  Future<void> restoreUserData(Map<String, dynamic> data) async {
    // profile
    if (data.containsKey('profile')) {
      final profile = data['profile'];
      if (profile is Map) {
        _username = profile['username'] ?? _username;
        _email = profile['email'] ?? _email;
        _coins = profile['coins'] ?? _coins;
        _xp = profile['xp'] ?? _xp;
        _streak = profile['streak'] ?? _streak;
        _isPremium = profile['isPremium'] ?? _isPremium;
        
        await _prefs.setString('username', _username);
        await _prefs.setString('email', _email);
        await _prefs.setInt('coins', _coins);
        await _prefs.setInt('xp', _xp);
        await _prefs.setInt('streak', _streak);
        await _prefs.setBool('isPremium', _isPremium);
      }
    }
    
    // statistics
    if (data.containsKey('statistics')) {
      final stats = data['statistics'];
      if (stats is Map) {
        _completedQuizCount = stats['completedQuizCount'] ?? _completedQuizCount;
        _totalAnswersCorrect = stats['totalAnswersCorrect'] ?? _totalAnswersCorrect;
        _totalAnswersSelected = stats['totalAnswersSelected'] ?? _totalAnswersSelected;
        _completedCodingProblems = stats['completedCodingProblems'] ?? _completedCodingProblems;
        _totalGamesWon = stats['totalGamesWon'] ?? _totalGamesWon;
        
        await _prefs.setInt('completedQuizCount', _completedQuizCount);
        await _prefs.setInt('totalAnswersCorrect', _totalAnswersCorrect);
        await _prefs.setInt('totalAnswersSelected', _totalAnswersSelected);
        await _prefs.setInt('completedCodingProblems', _completedCodingProblems);
        await _prefs.setInt('totalGamesWon', _totalGamesWon);
      }
    }
    
    // badges
    if (data.containsKey('badges')) {
      final badgesVal = data['badges'];
      if (badgesVal is List) {
        _unlockedBadges = List<String>.from(badgesVal.map((e) => e.toString()));
      } else if (badgesVal is Map) {
        _unlockedBadges = List<String>.from(badgesVal.values.map((e) => e.toString()));
      }
      await _prefs.setStringList('unlockedBadges', _unlockedBadges);
    }
    
    // daily_challenges
    if (data.containsKey('daily_challenges')) {
      final daily = data['daily_challenges'];
      if (daily is Map) {
        _dailyCompletedAptitude = daily['aptitude'] ?? _dailyCompletedAptitude;
        _dailyCompletedCoding = daily['coding'] ?? _dailyCompletedCoding;
        _dailyCompletedWord = daily['word'] ?? _dailyCompletedWord;
        _dailyCompletedMemory = daily['memory'] ?? _dailyCompletedMemory;
        
        await _prefs.setBool('dailyCompletedAptitude', _dailyCompletedAptitude);
        await _prefs.setBool('dailyCompletedCoding', _dailyCompletedCoding);
        await _prefs.setBool('dailyCompletedWord', _dailyCompletedWord);
        await _prefs.setBool('dailyCompletedMemory', _dailyCompletedMemory);
      }
    }

    // settings
    if (data.containsKey('settings')) {
      final settings = data['settings'];
      if (settings is Map) {
        _soundEffectsEnabled = settings['soundEffectsEnabled'] ?? _soundEffectsEnabled;
        _hapticsEnabled = settings['hapticsEnabled'] ?? _hapticsEnabled;
        _liveSyncEnabled = settings['liveSyncEnabled'] ?? _liveSyncEnabled;
        _quizTimeLimit = settings['quizTimeLimit'] ?? _quizTimeLimit;
        _interviewRigor = settings['interviewRigor'] ?? _interviewRigor;
        _adFrequency = settings['adFrequency'] ?? _adFrequency;
        _mpinEnabled = settings['mpinEnabled'] ?? _mpinEnabled;
        _mpinValue = settings['mpinValue'] ?? _mpinValue;
        _isDarkMode = settings['isDarkMode'] ?? _isDarkMode;
        AppColors.isDarkMode = _isDarkMode;
        _language = settings['language'] ?? _language;
        
        await _prefs.setBool('soundEffectsEnabled', _soundEffectsEnabled);
        await _prefs.setBool('hapticsEnabled', _hapticsEnabled);
        await _prefs.setBool('liveSyncEnabled', _liveSyncEnabled);
        await _prefs.setInt('quizTimeLimit', _quizTimeLimit);
        await _prefs.setString('interviewRigor', _interviewRigor);
        await _prefs.setString('adFrequency', _adFrequency);
        await _prefs.setBool('mpinEnabled', _mpinEnabled);
        await _prefs.setString('mpinValue', _mpinValue);
        await _prefs.setBool('isDarkMode', _isDarkMode);
        await _prefs.setString('language', _language);
      }
    }
    
    // resumes
    if (data.containsKey('resumes')) {
      final resumesVal = data['resumes'];
      List<Map<String, dynamic>> parsedResumes = [];
      if (resumesVal is Map) {
        resumesVal.forEach((key, val) {
          if (val is Map) {
            final Map<String, dynamic> res = Map<String, dynamic>.from(val);
            res['firebaseKey'] = key;
            parsedResumes.add(res);
          }
        });
      } else if (resumesVal is List) {
        for (var item in resumesVal) {
          if (item is Map) {
            parsedResumes.add(Map<String, dynamic>.from(item));
          }
        }
      }
      _savedResumes = parsedResumes;
      await _prefs.setString('savedResumes', json.encode(_savedResumes));
    }

    // history
    if (data.containsKey('history')) {
      final historyVal = data['history'];
      if (historyVal is List) {
        _historyLogs = List<Map<String, dynamic>>.from(
          historyVal.map((e) => Map<String, dynamic>.from(e))
        );
        await _prefs.setString('historyLogs', json.encode(_historyLogs));
      }
    }
    
    _logDbSync('Restored user data successfully from Firebase Cloud.');
    notifyListeners();
  }

  // Firebase Sync helper methods
  void _syncWithFirebase() {
    if (_liveSyncEnabled && FirebaseService.isConfigured && _isLoggedIn) {
      FirebaseService.syncUserProfile(
        _uid,
        username: _username,
        email: _email,
        xp: _xp,
        coins: _coins,
        streak: _streak,
        isPremium: _isPremium,
      );
      FirebaseService.syncUserStats(
        _uid,
        completedQuizCount: _completedQuizCount,
        totalAnswersCorrect: _totalAnswersCorrect,
        totalAnswersSelected: _totalAnswersSelected,
        completedCodingProblems: _completedCodingProblems,
        totalGamesWon: _totalGamesWon,
      );
      FirebaseService.syncUserBadges(
        _uid,
        _unlockedBadges,
      );
      FirebaseService.syncUserHistory(_uid, _historyLogs);
    }
  }

  void _syncDailyChallenges() {
    if (_liveSyncEnabled && FirebaseService.isConfigured && _isLoggedIn) {
      FirebaseService.syncDailyChallenges(
        _uid,
        dailyCompletedAptitude: _dailyCompletedAptitude,
        dailyCompletedCoding: _dailyCompletedCoding,
        dailyCompletedWord: _dailyCompletedWord,
        dailyCompletedMemory: _dailyCompletedMemory,
      );
    }
  }

  bool _testNotificationTriggered = false;
  bool get testNotificationTriggered => _testNotificationTriggered;

  void testStreakNotification() {
    _testNotificationTriggered = true;
    notifyListeners();
    _testNotificationTriggered = false;
  }

  // Real Persistence History & Settings Syncer Methods
  Future<void> recordHistory({
    required String feature,
    required String details,
    required String result,
    List<Map<String, dynamic>>? questionsHistory,
  }) async {
    final historyItem = {
      'feature': feature,
      'details': details,
      'result': result,
      'date': DateTime.now().toIso8601String(),
      if (questionsHistory != null) 'questions': questionsHistory,
    };
    
    _historyLogs.insert(0, historyItem);
    if (_historyLogs.length > 50) {
      _historyLogs.removeLast();
    }
    await _prefs.setString('historyLogs', json.encode(_historyLogs));
    _logDbSync('Activity recorded: $feature - $details ($result)');
    
    if (_liveSyncEnabled && FirebaseService.isConfigured && _isLoggedIn) {
      FirebaseService.syncUserHistory(_uid, _historyLogs);
    }
    notifyListeners();
  }

  void _syncSettingsWithFirebase() {
    if (_liveSyncEnabled && FirebaseService.isConfigured && _isLoggedIn) {
      FirebaseService.syncUserSettings(_uid, {
        'soundEffectsEnabled': _soundEffectsEnabled,
        'hapticsEnabled': _hapticsEnabled,
        'liveSyncEnabled': _liveSyncEnabled,
        'quizTimeLimit': _quizTimeLimit,
        'interviewRigor': _interviewRigor,
        'adFrequency': _adFrequency,
        'mpinEnabled': _mpinEnabled,
        'mpinValue': _mpinValue,
        'isDarkMode': _isDarkMode,
        'language': _language,
      });
    }
  }
}
