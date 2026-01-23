import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sudoku_poc/core/sudoku/grid.dart';

class GameProvider extends ChangeNotifier {
  SudokuGrid _grid = SudokuGrid.empty();
  bool _isLoading = true;
  bool _isWon = false;

  // Timer
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // Hint
  Timer? _hintCooldownTimer;
  int _hintCooldownSeconds = 0;

  // Selection
  // Selection
  int? _selectedRow;
  int? _selectedCol;

  // Features
  bool _isNoteMode = false;
  final List<SudokuGrid> _history = [];

  SudokuGrid get grid => _grid;
  bool get isLoading => _isLoading;
  bool get isWon => _isWon;
  Duration get elapsedTime => _elapsedTime;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get isNoteMode => _isNoteMode;
  bool get canUndo => _history.isNotEmpty;

  bool get isHintActive => _hintCooldownSeconds > 0;
  int get hintCooldown => _hintCooldownSeconds;

  GameProvider() {
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _isLoading = true;
    _isWon = false;
    _history.clear();
    notifyListeners();

    // Mock loading a puzzle (Simulation of Async)
    Future.delayed(const Duration(milliseconds: 500), () {
      // Simple Puzzle Mock
      // A full valid solution for testing wins:
      // 5 3 4 | 6 7 8 | 9 1 2
      // 6 7 2 | 1 9 5 | 3 4 8
      // 1 9 8 | 3 4 2 | 5 6 7
      // ---------------------
      // 8 5 9 | 7 6 1 | 4 2 3
      // 4 2 6 | 8 5 3 | 7 9 1
      // 7 1 3 | 9 2 4 | 8 5 6
      // ---------------------
      // 9 6 1 | 5 3 7 | 2 8 4
      // 2 8 7 | 4 1 9 | 6 3 5
      // 3 4 5 | 2 8 6 | 1 7 9

      // We will clear a few cells to make it playable.
      final fullBoard = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 0],
        [3, 4, 5, 2, 8, 6, 1, 7, 0], // Last one empty for quick win test
      ];
      _grid = SudokuGrid.fromIntList(fullBoard);
      _isLoading = false;
      _isWon = false;
      _elapsedTime = Duration.zero;
      _startTimer();
      notifyListeners();
    });
  }

  void restartGame() {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _hintCooldownSeconds = 0;
    _startNewGame();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void toggleNoteMode() {
    _isNoteMode = !_isNoteMode;
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty || _isWon) return;
    _grid = _history.removeLast();
    notifyListeners();
  }

  void _recordHistory() {
    _history.add(_grid);
  }

  void inputNumber(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isWon) return;

    final cell = _grid.rows[_selectedRow!][_selectedCol!];
    if (cell.isFixed) return;

    _recordHistory();

    if (_isNoteMode) {
      final newNotes = Set<int>.from(cell.notes);
      if (newNotes.contains(number)) {
        newNotes.remove(number);
      } else {
        newNotes.add(number);
      }
      _grid = _grid.updateCellNotes(_selectedRow!, _selectedCol!, newNotes);
    } else {
      _grid = _grid.updateCell(_selectedRow!, _selectedCol!, number);

      // Check Win
      if (_grid.isComplete) {
        _handleWin();
      }
    }

    notifyListeners();
  }

  void clearCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isWon) return;
    if (_grid.rows[_selectedRow!][_selectedCol!].isFixed) return;

    _recordHistory();
    // Clearing cell clears both value and notes usually, or just value?
    // Let's assume it clears value.
    // Ideally it should probably clear value if present, else notes?
    // For simplicity, let's clear value.
    _grid = _grid.updateCell(_selectedRow!, _selectedCol!, null);
    notifyListeners();
  }

  void _handleWin() {
    _isWon = true;
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
  }

  void useHint() {
    if (isHintActive || _isWon) return;

    // Find a random empty spot
    final pos = _grid.getRandomEmptyPosition();
    if (pos == null) return; // Full board

    final (r, c) = pos;

    // In a real app, we'd solve the board to find the CORRECT number.
    // Here, since we loaded a pre-solved board with holes, we know the answer
    // based on my mock data above.
    // BUT, wait, I hardcoded the mock data locally in _startNewGame.
    // To make this robust for the PoC, let's just cheat and look at what the
    // hardcoded value SHOULD be.
    // Since I removed (8,8) which was 9.
    // For specific logic, normally the grid would store the "solution" separately.

    // HACK for PoC: Just fill 9 if it's (8,8).
    // Or better, let's just pick a valid number for that spot.
    // Since the board is almost full, there's only one valid number.
    // Let's iterate 1-9 and see which one is valid.

    for (int val = 1; val <= 9; val++) {
      if (_grid.isValidMove(r, c, val)) {
        _grid = _grid.updateCell(r, c, val);
        break;
      }
    }

    _startHintCooldown();

    if (_grid.isComplete) {
      _handleWin();
    }

    notifyListeners();
  }

  void _startHintCooldown() {
    _hintCooldownSeconds = 10;
    _hintCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _hintCooldownSeconds--;
      if (_hintCooldownSeconds <= 0) {
        timer.cancel();
      }
      notifyListeners();
    });
  }
}
