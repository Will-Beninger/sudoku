import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';

import 'package:sudoku/core/data/repositories/i_puzzle_repository.dart';

class PuzzleRepository implements IPuzzleRepository {
  final SharedPreferences? _prefs;

  PuzzleRepository([this._prefs]);

  static Future<PuzzleRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PuzzleRepository(prefs);
  }

  // In a real app, this might load all JSONs from assets/puzzles/
  // For PoC, we will simulate loading a "Standard Pack" with hardcoded data + our previous mock.
  @override
  Future<List<PuzzlePack>> loadPacks() async {
    try {
      // Hardcoded list of packs to ensure offline availability without relying on Manifest interaction which can be flaky
      final puzzlePaths = [
        'assets/puzzles/easy_pack.json',
        'assets/puzzles/medium_pack.json',
        'assets/puzzles/hard_pack.json',
      ];

      final List<PuzzlePack> packs = [];

      for (final path in puzzlePaths) {
        try {
          final jsonString = await rootBundle.loadString(path);
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          final pack = PuzzlePack.fromJson(jsonMap);
          packs.add(pack);
        } catch (e) {
          debugPrint('Error loading puzzle pack at $path: $e');
        }
      }

      return packs;
    } catch (e) {
      debugPrint('Error discovery puzzles: $e');
      return [];
    }
  }

  @override
  Future<Puzzle?> getNextPuzzle(String currentPuzzleId) async {
    final packs = await loadPacks();
    final allPuzzles = packs.expand((p) => p.puzzles).toList();

    final currentIndex = allPuzzles.indexWhere((p) => p.id == currentPuzzleId);
    if (currentIndex != -1 && currentIndex < allPuzzles.length - 1) {
      final next = allPuzzles[currentIndex + 1];
      final current = allPuzzles[currentIndex];
      // Only proceed if same difficulty
      if (next.difficulty == current.difficulty) {
        return next;
      }
    }
    return null;
  }

  // --- Persistence ---

  static const String _savedGameKey = 'current_saved_game';

  @override
  Future<void> saveGame(GameState state) async {
    final jsonString = jsonEncode(state.toJson());
    await _prefs?.setString(_savedGameKey, jsonString);
  }

  @override
  Future<GameState?> loadGame() async {
    final jsonString = _prefs?.getString(_savedGameKey);
    if (jsonString == null) return null;
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error loading saved game: $e');
      return null;
    }
  }

  @override
  Future<void> deleteSavedGame() async {
    await _prefs?.remove(_savedGameKey);
  }

  @override
  bool hasSavedGame() {
    return _prefs?.containsKey(_savedGameKey) ?? false;
  }

  @override
  Future<String?> getSavedPuzzleId() async {
    final jsonString = _prefs?.getString(_savedGameKey);
    if (jsonString == null) return null;
    try {
      // Optimized: Just parse the ID if possible, or decode fully
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      // Assuming structure is { 'puzzle': { 'id': '...' } }
      final puzzleMap = jsonMap['puzzle'] as Map<String, dynamic>;
      return puzzleMap['id'] as String?;
    } catch (e) {
      debugPrint('Error getting saved puzzle ID: $e');
      return null;
    }
  }

  @override
  bool isLevelCompleted(String puzzleId) {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    return completed.contains(puzzleId);
  }

  @override
  Duration? getBestTime(String puzzleId) {
    final ms = _prefs?.getInt('best_time_$puzzleId');
    return ms != null ? Duration(milliseconds: ms) : null;
  }

  @override
  Future<void> completeLevel(String puzzleId, Duration timeTaken) async {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    if (!completed.contains(puzzleId)) {
      completed.add(puzzleId);
      await _prefs?.setStringList('completed_levels', completed);
    }

    final currentBest = getBestTime(puzzleId);
    if (currentBest == null || timeTaken < currentBest) {
      await _prefs?.setInt('best_time_$puzzleId', timeTaken.inMilliseconds);
    }

    // Global Stats
    await _incrementStat('games_won');
  }

  Future<void> _incrementStat(String key) async {
    final current = _prefs?.getInt('stat_$key') ?? 0;
    await _prefs?.setInt('stat_$key', current + 1);
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'games_won': _prefs?.getInt('stat_games_won') ?? 0,
      'completed_count':
          (_prefs?.getStringList('completed_levels') ?? []).length,
    };
  }
}
