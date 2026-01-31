enum Difficulty {
  beginner,
  easy,
  medium,
  hard,
  expert,
}

class Puzzle {
  final String id;
  final String initialBoard; // 81 chars, 0 for empty
  final String solutionBoard; // 81 chars
  final Difficulty difficulty;

  const Puzzle({
    required this.id,
    required this.initialBoard,
    required this.solutionBoard,
    required this.difficulty,
  });

  // Helper to convert 81-char string to List<List<int>>
  List<List<int>> get initialGrid {
    return _stringToGrid(initialBoard);
  }

  List<List<int>> get solutionGrid {
    return _stringToGrid(solutionBoard);
  }

  static List<List<int>> _stringToGrid(String s) {
    List<List<int>> rows = [];
    for (int i = 0; i < 9; i++) {
      List<int> row = [];
      for (int j = 0; j < 9; j++) {
        final char = s[i * 9 + j];
        row.add(int.tryParse(char) ?? 0);
      }
      rows.add(row);
    }
    return rows;
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      initialBoard: json['initial'] as String,
      solutionBoard: json['solution'] as String,
      difficulty: _parseDifficulty(json['difficulty'] as String),
    );
  }

  static Difficulty _parseDifficulty(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('expert')) return Difficulty.expert;
    if (lower.contains('hard')) return Difficulty.hard;
    if (lower.contains('medium')) return Difficulty.medium;
    if (lower.contains('easy')) return Difficulty.easy;

    return Difficulty.values.firstWhere(
      (e) => e.name == lower,
      orElse: () => Difficulty.easy,
    );
  }
}

class PuzzlePack {
  final String id;
  final String name;
  final List<Puzzle> puzzles;

  const PuzzlePack({
    required this.id,
    required this.name,
    required this.puzzles,
  });

  factory PuzzlePack.fromJson(Map<String, dynamic> json) {
    return PuzzlePack(
      id: json['packId'] as String,
      name: json['name'] as String? ?? 'Standard Pack',
      puzzles: (json['puzzles'] as List)
          .map((e) => Puzzle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
