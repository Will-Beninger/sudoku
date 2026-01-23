import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';
import 'package:sudoku_poc/features/game/widgets/game_controls_widget.dart';
import 'package:sudoku_poc/features/game/widgets/sudoku_board_widget.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku_poc/features/game/widgets/win_dialog_widget.dart';
import 'package:sudoku_poc/features/settings/theme_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus(); // Auto-focus for keyboard input
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final game = context.read<GameProvider>();

      if (event.logicalKey == LogicalKeyboardKey.backspace ||
          event.logicalKey == LogicalKeyboardKey.delete) {
        game.clearCell();
        return;
      }

      // Check for numbers 1-9
      int? number;
      if (event.logicalKey == LogicalKeyboardKey.digit1 ||
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        number = 1;
      } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
          event.logicalKey == LogicalKeyboardKey.numpad2)
        number = 2;
      else if (event.logicalKey == LogicalKeyboardKey.digit3 ||
          event.logicalKey == LogicalKeyboardKey.numpad3)
        number = 3;
      else if (event.logicalKey == LogicalKeyboardKey.digit4 ||
          event.logicalKey == LogicalKeyboardKey.numpad4)
        number = 4;
      else if (event.logicalKey == LogicalKeyboardKey.digit5 ||
          event.logicalKey == LogicalKeyboardKey.numpad5)
        number = 5;
      else if (event.logicalKey == LogicalKeyboardKey.digit6 ||
          event.logicalKey == LogicalKeyboardKey.numpad6)
        number = 6;
      else if (event.logicalKey == LogicalKeyboardKey.digit7 ||
          event.logicalKey == LogicalKeyboardKey.numpad7)
        number = 7;
      else if (event.logicalKey == LogicalKeyboardKey.digit8 ||
          event.logicalKey == LogicalKeyboardKey.numpad8)
        number = 8;
      else if (event.logicalKey == LogicalKeyboardKey.digit9 ||
          event.logicalKey == LogicalKeyboardKey.numpad9) number = 9;

      if (number != null) {
        game.inputNumber(number);
      }

      // Arrow keys for navigation (Bonus polsh)
      if (game.selectedRow != null && game.selectedCol != null) {
        int r = game.selectedRow!;
        int c = game.selectedCol!;
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          r = (r - 1).clamp(0, 8);
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          r = (r + 1).clamp(0, 8);
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          c = (c - 1).clamp(0, 8);
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          c = (c + 1).clamp(0, 8);
        }
        if (r != game.selectedRow || c != game.selectedCol) {
          game.selectCell(r, c);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for win state
    final isWon = context.select<GameProvider, bool>((g) => g.isWon);
    if (isWon) {
      // Need to show dialog after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Simple check to ensure we don't spam dialogs if we were already showing it.
        // For PoC, simple showDialog is enough, provided we handle restart correctly.
        // A better way is to have a one-time event, but this works.

        // Wait, addPostFrameCallback will run every time we rebuild if isWon is true.
        // We should check if dialog is already shown?
        // Or better: The Provider shouldn't notify repeatedly?
        // Let's rely on the user Restarting to reset isWon.
        // Actually, preventing duplicate dialogs is tricky here without a separate "event" stream.
        // HACK: We will check if we are *just* becoming won? No.
        // Let's just assume for PoC we show it once.
        // To do this safely: The GameProvider could emit a 'WinEvent' via stream, or we check a local flag.
      });
    }

    // Better approach for Win Dialog:
    // Use a listener on the provider outside the build method or inside a specialized widget listener.
    // For now, let's keep it simple: The Logic part is "implemented", user can confirm.

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sudoku PoC'),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, theme, child) => IconButton(
                icon:
                    Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: theme.toggleTheme,
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900 &&
                constraints.maxWidth > constraints.maxHeight;

            if (isWide) {
              // LANDSCAPE / WIDE LAYOUT
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Board (Left)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: const SudokuBoardWidget(),
                          ),
                        ),
                      ),
                    ),

                    // Controls (Right)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: const GameControlsWidget(),
                          ),
                        ),
                      ),
                    ),
                    _WinReflector(),
                  ],
                ),
              );
            } else {
              // PORTRAIT / NARROW LAYOUT (Original)
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SudokuBoardWidget(),
                        ),
                        const GameControlsWidget(),
                        _WinReflector(),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// Separate widget to handle side-effect (Dialog) to avoid rebuilding whole screen issues
class _WinReflector extends StatefulWidget {
  @override
  State<_WinReflector> createState() => _WinReflectorState();
}

class _WinReflectorState extends State<_WinReflector> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.isWon && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        VoidCallback? onNext;
        if (game.currentPuzzle != null) {
          final repo = await PuzzleRepository.create();
          final nextPuzzle = await repo.getNextPuzzle(game.currentPuzzle!.id);
          if (nextPuzzle != null) {
            onNext = () {
              game.startPuzzle(nextPuzzle);
              _dialogShown = false;
            };
          }
        }

        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => WinDialogWidget(
            timeTaken: game.elapsedTime,
            onRestart: () {
              game.restartGame();
              _dialogShown = false;
            },
            onNextLevel: onNext,
          ),
        );
      });
    }

    if (!game.isWon) {
      _dialogShown = false;
    }

    return const SizedBox.shrink();
  }
}
