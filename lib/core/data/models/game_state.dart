import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/sudoku/grid.dart';

class GameState {
  final Puzzle puzzle;
  final SudokuGrid grid;
  final Duration elapsedTime;
  final DateTime lastPlayed;

  const GameState({
    required this.puzzle,
    required this.grid,
    required this.elapsedTime,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'puzzle': {
        'id': puzzle.id,
        'initial': puzzle.initialBoard,
        'solution': puzzle.solutionBoard,
        'difficulty': puzzle.difficulty.name,
      },
      'grid': grid.toJson(),
      'elapsedTime': elapsedTime.inSeconds,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzle: Puzzle.fromJson(json['puzzle']),
      grid: SudokuGrid.fromJson(json['grid']),
      elapsedTime: Duration(seconds: json['elapsedTime'] as int),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
    );
  }
}
