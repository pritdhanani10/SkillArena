import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/feature_models.dart';
import 'firebase_service.dart';
import 'local_fallback_data.dart';

class DynamicDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialize Firestore collections with fallback data if they are empty
  static Future<void> initializeCollectionsIfEmpty() async {
    if (!FirebaseService.isConfigured) {
      debugPrint("[DynamicDataService] Firebase not configured. Seeding bypassed.");
      return;
    }

    try {
      debugPrint("[DynamicDataService] Checking collections for seeding...");
      
      // Seed Aptitude (with 3-second timeout)
      final aptitudeDoc = await _db.collection('challenges').doc('aptitude').get().timeout(const Duration(seconds: 3));
      if (!aptitudeDoc.exists) {
        debugPrint("[DynamicDataService] Seeding challenges/aptitude...");
        await _db.collection('challenges').doc('aptitude').set({
          'domainTopics': LocalFallbackData.domainTopics,
          'questions': LocalFallbackData.aptitudeQuestions,
        });
      }

      // Seed Coding
      final codingDoc = await _db.collection('challenges').doc('coding').get().timeout(const Duration(seconds: 3));
      if (!codingDoc.exists) {
        debugPrint("[DynamicDataService] Seeding challenges/coding...");
        await _db.collection('challenges').doc('coding').set({
          'problems': LocalFallbackData.codingProblems,
        });
      }

      // Seed Vocabulary
      final vocabDoc = await _db.collection('challenges').doc('vocabulary').get().timeout(const Duration(seconds: 3));
      if (!vocabDoc.exists) {
        debugPrint("[DynamicDataService] Seeding challenges/vocabulary...");
        await _db.collection('challenges').doc('vocabulary').set({
          'dailyWords': LocalFallbackData.dailyWords,
          'quiz': LocalFallbackData.vocabularyQuizQuestions,
        });
      }

      // Seed Word Search
      final wordSearchDoc = await _db.collection('challenges').doc('word_search').get().timeout(const Duration(seconds: 3));
      if (!wordSearchDoc.exists) {
        debugPrint("[DynamicDataService] Seeding challenges/word_search...");
        await _db.collection('challenges').doc('word_search').set(
          LocalFallbackData.wordSearchData,
        );
      }

      // Seed Memory Cards
      final memoryDoc = await _db.collection('challenges').doc('memory_cards').get().timeout(const Duration(seconds: 3));
      if (!memoryDoc.exists) {
        debugPrint("[DynamicDataService] Seeding challenges/memory_cards...");
        await _db.collection('challenges').doc('memory_cards').set({
          'emojis': LocalFallbackData.memoryCardEmojis,
        });
      }
      
      debugPrint("[DynamicDataService] Seeding verification completed successfully.");
    } catch (e) {
      debugPrint("[DynamicDataService] Seeding skipped/deferred (client offline or database unreachable): $e");
    }
  }

  // 1. Get Aptitude Topics
  static Future<Map<String, List<String>>> getAptitudeTopics() async {
    if (!FirebaseService.isConfigured) return LocalFallbackData.domainTopics;
    try {
      final doc = await _db.collection('challenges').doc('aptitude').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('domainTopics')) {
          final rawMap = data['domainTopics'] as Map<String, dynamic>;
          return rawMap.map((key, value) => MapEntry(key, List<String>.from(value)));
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading aptitude topics: $e");
    }
    return LocalFallbackData.domainTopics;
  }

  // 2. Get Aptitude Questions by Topic
  static Future<List<AptitudeQuestion>> getAptitudeQuestions(String topic) async {
    final apiQuestions = await fetchAptitudeQuestionsFromApi(topic);
    if (apiQuestions.isNotEmpty) {
      return apiQuestions;
    }

    if (!FirebaseService.isConfigured) {
      return _parseAptitudeFallback(topic);
    }
    try {
      final doc = await _db.collection('challenges').doc('aptitude').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('questions')) {
          final rawQuestionsMap = data['questions'] as Map<String, dynamic>;
          if (rawQuestionsMap.containsKey(topic)) {
            final rawList = rawQuestionsMap[topic] as List<dynamic>;
            return rawList.map((q) => AptitudeQuestion.fromMap(Map<String, dynamic>.from(q))).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading aptitude questions: $e");
    }
    return _parseAptitudeFallback(topic);
  }

  static List<AptitudeQuestion> _parseAptitudeFallback(String topic) {
    final raw = LocalFallbackData.aptitudeQuestions[topic];
    if (raw == null) {
      return [
        AptitudeQuestion(
          text: "Solve this general aptitude puzzle under $topic: What is next in sequence 2, 4, 8, 16, ...?",
          options: const ["32", "24", "64", "48"],
          correctIndex: 0,
          explanation: "The sequence doubles each term. Next is 16 * 2 = 32.",
        ),
      ];
    }
    return raw.map((q) => AptitudeQuestion.fromMap(q)).toList();
  }

  // 3. Get Coding Problems by Topic
  static Future<List<CodingProblem>> getCodingProblems(String topic) async {
    final apiProblems = await fetchCodingProblemsFromApi(topic);
    if (apiProblems.isNotEmpty) {
      return apiProblems;
    }

    if (!FirebaseService.isConfigured) {
      return _parseCodingFallback(topic);
    }
    try {
      final doc = await _db.collection('challenges').doc('coding').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('problems')) {
          final rawProblemsMap = data['problems'] as Map<String, dynamic>;
          if (rawProblemsMap.containsKey(topic)) {
            final rawList = rawProblemsMap[topic] as List<dynamic>;
            return rawList.map((p) => CodingProblem.fromMap(Map<String, dynamic>.from(p))).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading coding problems: $e");
    }
    return _parseCodingFallback(topic);
  }

  static List<CodingProblem> _parseCodingFallback(String topic) {
    final raw = LocalFallbackData.codingProblems[topic];
    if (raw == null) {
      return [
        CodingProblem(
          text: "Select the correct option to complete this $topic code logic:",
          codeSnippet: "// Mock challenge block for $topic\nvoid runChallenge() {\n    int target = 42;\n    print(target);\n}",
          options: const ["Compile Success", "Memory Leak", "Stack Overflow", "Syntax Error"],
          correctIndex: 0,
          expectedOutput: "42",
          explanation: "Simple display statement will print the value of target, which is 42.",
        ),
      ];
    }
    return raw.map((p) => CodingProblem.fromMap(p)).toList();
  }

  // 4. Get Vocabulary Daily Words
  static Future<List<Map<String, String>>> getDailyWords() async {
    if (!FirebaseService.isConfigured) return LocalFallbackData.dailyWords;
    try {
      final doc = await _db.collection('challenges').doc('vocabulary').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('dailyWords')) {
          final rawList = data['dailyWords'] as List<dynamic>;
          return rawList.map((w) => Map<String, String>.from(w)).toList();
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading daily words: $e");
    }
    return LocalFallbackData.dailyWords;
  }

  // 5. Get Vocabulary Retention Quiz
  static Future<List<Map<String, dynamic>>> getVocabularyQuiz() async {
    if (!FirebaseService.isConfigured) return LocalFallbackData.vocabularyQuizQuestions;
    try {
      final doc = await _db.collection('challenges').doc('vocabulary').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('quiz')) {
          final rawList = data['quiz'] as List<dynamic>;
          return rawList.map((q) => Map<String, dynamic>.from(q)).toList();
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading vocabulary quiz: $e");
    }
    return LocalFallbackData.vocabularyQuizQuestions;
  }

  // 6. Get Word Search Grid & Target Words
  static Future<Map<String, dynamic>> getWordSearchPuzzle() async {
    if (!FirebaseService.isConfigured) return LocalFallbackData.wordSearchData;
    try {
      final doc = await _db.collection('challenges').doc('word_search').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading word search puzzle: $e");
    }
    return LocalFallbackData.wordSearchData;
  }

  // 7. Get Memory Card Emojis
  static Future<List<String>> getMemoryCardEmojis() async {
    if (!FirebaseService.isConfigured) return LocalFallbackData.memoryCardEmojis;
    try {
      final doc = await _db.collection('challenges').doc('memory_cards').get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('emojis')) {
          return List<String>.from(data['emojis']);
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Offline/Error loading memory card emojis: $e");
    }
    return LocalFallbackData.memoryCardEmojis;
  }

  // 8. Get Leaderboard Data
  static Future<List<Map<String, dynamic>>> getLeaderboard(String category) async {
    final List<Map<String, dynamic>> users = [];
    if (FirebaseService.isConfigured) {
      try {
        final querySnapshot = await _db.collection('users').limit(30).get().timeout(const Duration(seconds: 3));
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data.containsKey('profile')) {
            final profile = Map<String, dynamic>.from(data['profile']);
            users.add({
              'name': profile['username'] ?? 'User_${doc.id.substring(0, 4)}',
              'xp': profile['xp'] ?? 0,
              'coins': profile['coins'] ?? 0,
              'avatar': profile['isPremium'] == true ? '👑' : '🎓',
            });
          }
        }
      } catch (e) {
        debugPrint("[DynamicDataService] Offline/Error fetching leaderboard: $e");
      }
    }

    // Merge with local leaderboard templates to maintain a premium-looking full list
    final List<Map<String, dynamic>> merged = [];
    final Set<String> namesAdded = {};

    for (var u in users) {
      merged.add(u);
      namesAdded.add(u['name']);
    }

    final defaultList = category == 'Friends'
        ? LocalFallbackData.leaderboardFriends
        : (category == 'Country' ? LocalFallbackData.leaderboardCountry : LocalFallbackData.leaderboardGlobal);

    for (var u in defaultList) {
      if (!namesAdded.contains(u['name'])) {
        merged.add(Map<String, dynamic>.from(u));
        namesAdded.add(u['name']);
      }
    }

    // Sort by XP descending
    merged.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

    // Assign rank values dynamically
    for (int i = 0; i < merged.length; i++) {
      merged[i]['rank'] = i + 1;
    }

    return merged;
  }

  // OTDB API dynamic fetchers
  static Future<List<AptitudeQuestion>> fetchAptitudeQuestionsFromApi(String topic) async {
    try {
      int categoryId = 9; // General Knowledge default
      final normalizedTopic = topic.toLowerCase();
      if (normalizedTopic.contains('profit') || 
          normalizedTopic.contains('percent') || 
          normalizedTopic.contains('time') || 
          normalizedTopic.contains('speed') || 
          normalizedTopic.contains('ratio') ||
          normalizedTopic.contains('math') ||
          normalizedTopic.contains('quant')) {
        categoryId = 19; // Mathematics
      }
      
      final response = await http.get(
        Uri.parse('https://opentdb.com/api.php?amount=10&category=$categoryId&type=multiple')
      ).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] == 0 && data['results'] != null) {
          final results = data['results'] as List;
          final List<AptitudeQuestion> questions = [];
          final random = Random();
          for (var q in results) {
            final questionText = _unescapeHtml(q['question'].toString());
            final correctAnswer = _unescapeHtml(q['correct_answer'].toString());
            final incorrectAnswers = (q['incorrect_answers'] as List)
                .map((e) => _unescapeHtml(e.toString()))
                .toList();
            
            final options = [...incorrectAnswers];
            final correctIndex = random.nextInt(options.length + 1);
            options.insert(correctIndex, correctAnswer);
            
            questions.add(AptitudeQuestion(
              text: questionText,
              options: options,
              correctIndex: correctIndex,
              explanation: "The correct answer is '$correctAnswer'. Fetched dynamically from Open Trivia DB.",
            ));
          }
          return questions;
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Error in fetchAptitudeQuestionsFromApi: $e");
    }
    return [];
  }

  static Future<List<CodingProblem>> fetchCodingProblemsFromApi(String topic) async {
    try {
      final response = await http.get(
        Uri.parse('https://opentdb.com/api.php?amount=5&category=18&type=multiple')
      ).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] == 0 && data['results'] != null) {
          final results = data['results'] as List;
          final List<CodingProblem> problems = [];
          final random = Random();
          for (var q in results) {
            final questionText = _unescapeHtml(q['question'].toString());
            final correctAnswer = _unescapeHtml(q['correct_answer'].toString());
            final incorrectAnswers = (q['incorrect_answers'] as List)
                .map((e) => _unescapeHtml(e.toString()))
                .toList();
            
            final options = [...incorrectAnswers];
            final correctIndex = random.nextInt(options.length + 1);
            options.insert(correctIndex, correctAnswer);
            
            final codeSnippet = """
// Topic: $topic
// CS Trivia: $questionText
class Challenge {
    public static void main(String[] args) {
        String expected = "$correctAnswer";
        System.out.println("Expected value: " + expected);
    }
}""";

            problems.add(CodingProblem(
              text: "Analyze the computer science concept and solve the question: $questionText",
              codeSnippet: codeSnippet,
              options: options,
              correctIndex: correctIndex,
              expectedOutput: correctAnswer,
              explanation: "Correct Answer is '$correctAnswer'. Concept explanation: ${q['question']} is verified in Computer Science systems. Category: ${q['category']}.",
            ));
          }
          return problems;
        }
      }
    } catch (e) {
      debugPrint("[DynamicDataService] Error in fetchCodingProblemsFromApi: $e");
    }
    return [];
  }

  static String _unescapeHtml(String input) {
    var text = input;
    text = text.replaceAll('&amp;', '&'); // Must replace &amp; first to avoid double-unescaping other entities later
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#039;', "'");
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&deg;', '°');
    text = text.replaceAll('&rsquo;', "'");
    text = text.replaceAll('&lsquo;', "'");
    text = text.replaceAll('&rdquo;', '"');
    text = text.replaceAll('&ldquo;', '"');
    text = text.replaceAll('&hellip;', '...');
    text = text.replaceAll('&ntilde;', 'ñ');
    text = text.replaceAll('&aacute;', 'á');
    text = text.replaceAll('&eacute;', 'é');
    text = text.replaceAll('&iacute;', 'í');
    text = text.replaceAll('&oacute;', 'ó');
    text = text.replaceAll('&uacute;', 'ú');
    text = text.replaceAll('&Aacute;', 'Á');
    text = text.replaceAll('&Eacute;', 'É');
    text = text.replaceAll('&Iacute;', 'Í');
    text = text.replaceAll('&Oacute;', 'Ó');
    text = text.replaceAll('&Uacute;', 'Ú');
    text = text.replaceAll('&uuml;', 'ü');
    text = text.replaceAll('&Uuml;', 'Ü');
    text = text.replaceAll('&nbsp;', ' ');
    
    text = text.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final hexCode = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(hexCode);
    });
    
    text = text.replaceAllMapped(RegExp(r'&#([0-9]+);'), (match) {
      final decCode = int.parse(match.group(1)!);
      return String.fromCharCode(decCode);
    });
    
    return text;
  }
}
