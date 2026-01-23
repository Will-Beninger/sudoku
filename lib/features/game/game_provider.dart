import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sudoku_poc/core/data/models/puzzle.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku_poc/core/sudoku/grid.dart';

class GameProvider extends ChangeNotifier {
  SudokuGrid _grid = SudokuGrid.empty();
  bool _isLoading = false;
  bool _isWon = false;
  Puzzle? _currentPuzzle;

  // Timer
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // Hint
  Timer? _hintCooldownTimer;
  int _hintCooldownSeconds = 0;

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
  Puzzle? get currentPuzzle => _currentPuzzle;

  bool get isHintActive => _hintCooldownSeconds > 0;
  int get hintCooldown => _hintCooldownSeconds;

  GameProvider() {
    // No auto-start
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    super.dispose();
  }

  void startPuzzle(Puzzle puzzle) {
    _currentPuzzle = puzzle;
    _restartGameInternal(puzzle);
  }

  void restartGame() {
    if (_currentPuzzle != null) {
      _restartGameInternal(_currentPuzzle!);
    }
  }

  void _restartGameInternal(Puzzle puzzle) {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _hintCooldownSeconds = 0;

    _isLoading = true;
    _isWon = false;
    _history.clear();
    _elapsedTime = Duration.zero;
    notifyListeners();

    // Initialize Grid from Puzzle Data (sync for now, but keeping structure valid)
    _grid = SudokuGrid.fromIntList(puzzle.initialGrid);

    _isLoading = false;
    _startTimer();
    notifyListeners();
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
    _grid = _grid.updateCell(_selectedRow!, _selectedCol!, null);
    notifyListeners();
  }

  void _handleWin() async {
    _isWon = true;
    _timer?.cancel();
    _hintCooldownTimer?.cancel();

    if (_currentPuzzle != null) {
      final repo = await PuzzleRepository.create();
      await repo.completeLevel(_currentPuzzle!.id, _elapsedTime);
    }
    notifyListeners();
  }

  void useHint() {
    if (isHintActive || _isWon || _currentPuzzle == null) return;

    // Find a random empty spot
    final pos = _grid.getRandomEmptyPosition();
    if (pos == null) return; // Full board

    final (r, c) = pos;

    // Get correct value from solution grid
    final solutionGrid = _currentPuzzle!.solutionGrid;
    final correctVal = solutionGrid[r][c];

    // Check if it's valid in current state definition (it should be if user hasn't messed up)
    // If user has put wrong numbers elsewhere, this might "break" the puzzle rules visually,
    // but we trust the authoritative solution.

    _grid = _grid.updateCell(r, c, correctVal);

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
