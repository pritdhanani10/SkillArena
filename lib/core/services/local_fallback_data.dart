class LocalFallbackData {
  static const Map<String, List<String>> domainTopics = {
    'Quantitative': ['Profit Loss', 'Percentage', 'Time Work', 'Speed Distance', 'Ratio'],
    'Logical': ['Blood Relations', 'Seating Arrangement', 'Coding Decoding'],
    'Verbal': ['Synonyms', 'Antonyms', 'Grammar'],
  };

  static const Map<String, List<Map<String, dynamic>>> aptitudeQuestions = {
    'Percentage': [
      {
        'text': "If 20% of a number is 120, then 120% of that number is:",
        'options': ["480", "720", "360", "240"],
        'correctIndex': 1,
        'explanation': "Let the number be x. 20% of x = 120 => (20/100)*x = 120 => x = 600. Therefore, 120% of x = (120/100)*600 = 720.",
      },
      {
        'text': "A student has to secure 40% marks to pass. He gets 178 marks and fails by 22 marks. The maximum marks are:",
        'options': ["500", "400", "600", "800"],
        'correctIndex': 0,
        'explanation': "Passing marks = 178 + 22 = 200. Since 40% of maximum marks = 200, Max Marks = 200 * (100/40) = 500.",
      },
      {
        'text': "If the price of a book is first decreased by 25% and then increased by 20%, the net change in the price will be:",
        'options': ["No change", "10% decrease", "5% decrease", "8% increase"],
        'correctIndex': 1,
        'explanation': "Let original price be 100. Decreased by 25% = 75. Increased by 20% = 75 + (20% of 75) = 75 + 15 = 90. Net change = 100 to 90 (10% decrease).",
      },
    ],
    'Profit Loss': [
      {
        'text': "A shopkeeper sells a refrigerator for ₹22,000 at a profit of 10%. If he sells it for ₹18,000, what is his loss percentage?",
        'options': ["5%", "8%", "10%", "12%"],
        'correctIndex': 2,
        'explanation': "Selling Price (SP) = ₹22,000. Profit = 10%. Cost Price (CP) = SP * 100 / (100+Profit%) = 22000 * 100/110 = ₹20,000. New SP = ₹18,000. Loss = 20000 - 18000 = 2000. Loss% = (2000/20000)*100 = 10%.",
      },
      {
        'text': "If cost price of 15 articles is equal to the selling price of 12 articles, find the gain percentage.",
        'options': ["20%", "25%", "30%", "15%"],
        'correctIndex': 1,
        'explanation': "Let CP of each article be ₹1. CP of 15 articles = ₹15. SP of 12 articles = CP of 15 articles = ₹15. CP of 12 articles = ₹12. Gain = SP - CP = 15 - 12 = 3. Gain% = (3/12)*100 = 25%.",
      },
    ],
    'Time Work': [
      {
        'text': "A can do a piece of work in 10 days and B in 15 days. Working together, in how many days can they complete the work?",
        'options': ["5 days", "6 days", "8 days", "7 days"],
        'correctIndex': 1,
        'explanation': "A's 1 day work = 1/10. B's 1 day work = 1/15. Together 1 day work = 1/10 + 1/15 = 5/30 = 1/6. Hence, they complete in 6 days.",
      },
    ],
    'Blood Relations': [
      {
        'text': "Pointing to a photograph of a boy, Suresh said, 'He is the son of the only son of my mother.' How Suresh is related to that boy?",
        'options': ["Brother", "Uncle", "Father", "Cousin"],
        'correctIndex': 2,
        'explanation': "The 'only son of Suresh's mother' is Suresh himself. Therefore, the boy in the photo is the son of Suresh. Suresh is the father.",
      },
    ],
    'Synonyms': [
      {
        'text': "Choose the correct synonym of the word: DILIGENT",
        'options': ["Lazy", "Intelligent", "Hard-working", "Clever"],
        'correctIndex': 2,
        'explanation': "Diligent means having or showing care and conscientiousness in one's work. Synonym is hard-working.",
      },
    ],
  };

  static const Map<String, List<Map<String, dynamic>>> codingProblems = {
    'Arrays': [
      {
        'text': "What will be the output of the following Java program regarding array indexing?",
        'codeSnippet': "public class ArrayTest {\n    public static void main(String[] args) {\n        int[] arr = new int[5];\n        System.out.println(arr[4]);\n    }\n}",
        'options': ["0", "NullPointerException", "ArrayIndexOutOfBoundsException", "Garbage value"],
        'correctIndex': 0,
        'expectedOutput': "0",
        'explanation': "In Java, primitive int arrays are automatically initialized to their default value, which is 0. Since arr has a size of 5, indexes are 0 to 4. Printing arr[4] outputs 0.",
      },
      {
        'text': "Find the time complexity of the binary search algorithm on a sorted array of size N.",
        'codeSnippet': "int binarySearch(int arr[], int l, int r, int x) {\n    while (l <= r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] == x) return m;\n        if (arr[m] < x) l = m + 1;\n        else r = m - 1;\n    }\n    return -1;\n}",
        'options': ["O(N)", "O(log N)", "O(N log N)", "O(1)"],
        'correctIndex': 1,
        'expectedOutput': "O(log N)",
        'explanation': "Binary search repeatedly divides the search space in half. Hence, the time complexity is logarithmic, or O(log N).",
      },
    ],
    'Strings': [
      {
        'text': "What does the following C++ code return when matching strings?",
        'codeSnippet': "#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s1 = \"Skill\";\n    string s2 = \"Arena\";\n    cout << (s1 + s2).length();\n    return 0;\n}",
        'options': ["5", "10", "SkillArena", "Compilation error"],
        'correctIndex': 1,
        'expectedOutput': "10",
        'explanation': "s1 has length 5 ('Skill') and s2 has length 5 ('Arena'). Concatenating them (s1 + s2) yields 'SkillArena', which has length 10.",
      },
    ],
    'SQL': [
      {
        'text': "Which SQL clause is used to filter group results after applying an aggregate function?",
        'codeSnippet': "SELECT department, AVG(salary)\nFROM employees\nGROUP BY department\n??? AVG(salary) > 50000;",
        'options': ["WHERE", "HAVING", "FILTER", "ORDER BY"],
        'correctIndex': 1,
        'expectedOutput': "HAVING",
        'explanation': "The HAVING clause was added to SQL because the WHERE keyword could not be used with aggregate functions.",
      },
    ],
  };

  static const List<Map<String, String>> dailyWords = [
    {
      'word': 'Perseverance',
      'meaning': 'Persistence in doing something despite difficulty or delay in achieving success.',
      'example': 'Preparing for placements requires consistency and perseverance.',
      'synonyms': 'Persistence, tenacity, determination',
      'antonyms': 'Apathy, laziness, weakness',
    },
    {
      'word': 'Cognitive',
      'meaning': 'Relating to, being, or involving conscious intellectual activity (such as thinking, reasoning, or remembering).',
      'example': 'Brain training games improve cognitive adaptability and reasoning speeds.',
      'synonyms': 'Mental, intellectual, analytical',
      'antonyms': 'Physical, visceral',
    },
    {
      'word': 'Optimistic',
      'meaning': 'Hopeful and confident about the future or the success of something.',
      'example': 'Remain optimistic during interview sessions; confidence is key.',
      'synonyms': 'Hopeful, positive, confident',
      'antonyms': 'Pessimistic, gloomy',
    }
  ];

  static const List<Map<String, dynamic>> vocabularyQuizQuestions = [
    {
      'question': 'Which word matches the definition: "Persistence despite difficulty or delay"?',
      'options': ['Cognitive', 'Perseverance', 'Optimistic', 'Apathy'],
      'correct': 1,
    },
    {
      'question': 'What is a direct antonym of "Optimistic"?',
      'options': ['Pessimistic', 'Hopeful', 'Diligent', 'Tenacious'],
      'correct': 0,
    }
  ];

  static const Map<String, dynamic> wordSearchData = {
    'grid': [
      'FLUTTERP',
      'DXMCODEK',
      'AQBIVNDL',
      'RUSQLWQA',
      'TPROGRAMM',
      'HOSTFCMN',
      'STACKYBQ',
      'LJNUXPAT',
    ],
    'wordsToFind': ["FLUTTER", "CODE", "DART", "STACK", "SQL"],
  };

  static const List<String> memoryCardEmojis = ["🍎", "🍌", "🍉", "🍇", "🍓", "🍒", "🍍", "🥑", "🍑", "🍋", "🍊", "🥝"];

  static const List<Map<String, dynamic>> leaderboardGlobal = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'Alex_Dev', 'xp': 2100, 'coins': 690, 'avatar': '⚡', 'rank': 2},
    {'name': 'CodeMaster', 'xp': 1950, 'coins': 520, 'avatar': '🚀', 'rank': 3},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 4},
    {'name': 'Amit_Raj', 'xp': 950, 'coins': 280, 'avatar': '🦁', 'rank': 5},
  ];

  static const List<Map<String, dynamic>> leaderboardCountry = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'CodeMaster', 'xp': 1950, 'coins': 520, 'avatar': '🚀', 'rank': 2},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 3},
  ];

  static const List<Map<String, dynamic>> leaderboardFriends = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 2},
  ];
}
