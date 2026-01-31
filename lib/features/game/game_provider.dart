import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/core/sudoku/grid.dart';

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

  // Conflict Check
  Timer? _conflictCooldownTimer;
  int _conflictCooldownSeconds = 0;
  final Set<({int r, int c})> _conflictingCells = {};

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

  bool get isConflictCheckActive => _conflictCooldownSeconds > 0;
  int get conflictCooldown => _conflictCooldownSeconds;
  Set<({int r, int c})> get conflictingCells => _conflictingCells;

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  final PuzzleRepository? _repository;

  GameProvider({PuzzleRepository? repository}) : _repository = repository;

  @override
  void dispose() {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _conflictCooldownTimer?.cancel();
    super.dispose();
  }

  void startPuzzle(Puzzle puzzle) {
    _currentPuzzle = puzzle;
    _restartGameInternal(puzzle);
    _saveGame();
  }

  void restartGame() {
    if (_currentPuzzle != null) {
      _deleteSavedGame();
      _restartGameInternal(_currentPuzzle!);
      _saveGame();
      resumeTimer(); // Explicitly restart timer for in-game restart
    }
  }

  Future<void> loadSavedGame() async {
    if (_repository == null) return;

    _isLoading = true;
    notifyListeners();

    final state = await _repository!.loadGame();
    if (state != null) {
      // Safety check: If the loaded game is already complete, strictly delete it and don't load.
      if (state.grid.isComplete) {
        await _deleteSavedGame();
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPuzzle = state.puzzle;
      _grid = state.grid;
      _elapsedTime = state.elapsedTime;
      // If saving won state, we need to handle it. For now assuming in-progress.
      _isWon = false;

      // Timer will be started by View
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveGame() async {
    // Prevent saving if won OR if grid is complete (race condition safety)
    if (_repository == null ||
        _currentPuzzle == null ||
        _isWon ||
        _grid.isComplete) {
      return;
    }

    final state = GameState(
      puzzle: _currentPuzzle!,
      grid: _grid,
      elapsedTime: _elapsedTime,
      lastPlayed: DateTime.now(),
    );
    await _repository.saveGame(state);
  }

  Future<void> _deleteSavedGame() async {
    await _repository?.deleteSavedGame();
  }

  void _restartGameInternal(Puzzle puzzle) {
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _conflictCooldownTimer?.cancel();
    _hintCooldownSeconds = 0;
    _conflictCooldownSeconds = 0;
    _conflictingCells.clear();

    _isLoading = true;
    _isWon = false;
    _history.clear();
    _elapsedTime = Duration.zero;
    notifyListeners();

    // Initialize Grid from Puzzle Data
    _grid = SudokuGrid.fromIntList(puzzle.initialGrid);

    _isLoading = false;
    // NOTE: We do NOT start timer here automatically anymore.
    // The View is responsible for calling resumeTimer() when ready.
    notifyListeners();
  }

  void resumeTimer() {
    if (_isWon) return;
    _timer?.cancel(); // Ensure no duplicate timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);

      if (_elapsedTime.inSeconds % 10 == 0) {
        _saveGame();
      }
      notifyListeners();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _saveGame(); // Save progress when pausing
  }

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    _feedbackMessage = null;
    notifyListeners();
  }

  void toggleNoteMode() {
    _isNoteMode = !_isNoteMode;
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty || _isWon) return;
    _grid = _history.removeLast();
    _saveGame();
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
      _conflictingCells.clear();
      _feedbackMessage = null;
      _grid = _grid.updateCell(_selectedRow!, _selectedCol!, number);

      if (_grid.isComplete) {
        _handleWin();
        notifyListeners(); // Notify UI of win
        return; // EXIT: Do not save game if won
      }
    }
    _saveGame();
    notifyListeners();
  }

  void clearCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isWon) return;
    if (_grid.rows[_selectedRow!][_selectedCol!].isFixed) return;

    _recordHistory();
    _conflictingCells.clear();
    _feedbackMessage = null;
    _grid = _grid.updateCell(_selectedRow!, _selectedCol!, null);
    _grid = _grid.updateCellNotes(_selectedRow!, _selectedCol!, {});
    _saveGame();
    notifyListeners();
  }

  void _handleWin() async {
    _isWon = true;
    // Ensure timer is stopped immediately
    _timer?.cancel();
    _hintCooldownTimer?.cancel();
    _conflictCooldownTimer?.cancel(); // Also cancel conflict timer

    // Fire-and-forget delete, but we rely on _isWon/isComplete guard in _saveGame to prevent race re-save.
    // We should await this if possible to ensure consistency before notifying listeners?
    // Since this method is async void, we can await inside.
    await _deleteSavedGame();

    if (_currentPuzzle != null) {
      // Use injected repo if available, else create (fallback)
      final repo = _repository ?? await PuzzleRepository.create();
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

  // --- Conflict Checker ---

  void checkConflicts() {
    if (isConflictCheckActive || _isWon) return;

    _conflictingCells.clear();
    final rows = _grid.rows;

    // Check every cell against every other cell in its row, col, and box
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = rows[r][c];
        if (cell.value == null) continue;

        // Skip default/fixed cells? Rule says: "only place the red X on user entries"
        // But we need to check IF a user entry conflicts with anything.
        // So we iterate user entries, and check if they have conflicts.

        // Actually, we should check ALL cells to find conflicts, but only ADD to set if !isFixed.

        bool hasConflict = false;

        // Check Row
        for (int k = 0; k < 9; k++) {
          if (k == c) continue;
          if (rows[r][k].value == cell.value) {
            hasConflict = true;
            break;
          }
        }

        // Check Col
        if (!hasConflict) {
          for (int k = 0; k < 9; k++) {
            if (k == r) continue;
            if (rows[k][c].value == cell.value) {
              hasConflict = true;
              break;
            }
          }
        }

        // Check Box
        if (!hasConflict) {
          final boxRow = (r ~/ 3) * 3;
          final boxCol = (c ~/ 3) * 3;
          for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
              final br = boxRow + i;
              final bc = boxCol + j;
              if (br == r && bc == c) continue;
              if (rows[br][bc].value == cell.value) {
                hasConflict = true;
                break;
              }
            }
            if (hasConflict) break;
          }
        }

        if (hasConflict && !cell.isFixed) {
          _conflictingCells.add((r: r, c: c));
        }
      }
    }

    if (_conflictingCells.isEmpty) {
      _feedbackMessage = "No Logic Errors Detected!";
    } else {
      _feedbackMessage = null;
    }

    _startConflictCooldown();
    notifyListeners();
  }

  void _startConflictCooldown() {
    _conflictCooldownSeconds = 10;
    _conflictCooldownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      _conflictCooldownSeconds--;
      if (_conflictCooldownSeconds <= 0) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Set<int> getCompletedNumbers() {
    final counts = <int, int>{};
    for (var row in _grid.rows) {
      for (var cell in row) {
        if (cell.value != null) {
          counts[cell.value!] = (counts[cell.value!] ?? 0) + 1;
        }
      }
    }
    return counts.entries.where((e) => e.value >= 9).map((e) => e.key).toSet();
  }
}
