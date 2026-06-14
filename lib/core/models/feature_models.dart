class AptitudeQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const AptitudeQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory AptitudeQuestion.fromMap(Map<String, dynamic> map) {
    return AptitudeQuestion(
      text: map['text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}

class CodingProblem {
  final String text;
  final String codeSnippet;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String expectedOutput;

  const CodingProblem({
    required this.text,
    required this.codeSnippet,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.expectedOutput,
  });

  factory CodingProblem.fromMap(Map<String, dynamic> map) {
    return CodingProblem(
      text: map['text'] ?? '',
      codeSnippet: map['codeSnippet'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      expectedOutput: map['expectedOutput'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'codeSnippet': codeSnippet,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': expectedOutput,
      'expectedOutput': expectedOutput,
    };
  }
}
