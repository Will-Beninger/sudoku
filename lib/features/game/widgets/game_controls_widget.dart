import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';
import 'package:sudoku_poc/features/game/widgets/hint_button_widget.dart';
import 'package:sudoku_poc/features/game/widgets/number_pad_widget.dart';

class GameControlsWidget extends StatelessWidget {
  const GameControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: Timer and New Game
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<GameProvider>(builder: (_, game, __) {
                final t = game.elapsedTime;
                return Text(
                  'Time: ${t.inMinutes}:${(t.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                );
              }),
              ElevatedButton(
                onPressed: () => context.read<GameProvider>().restartGame(),
                child: const Text('New Game'),
              ),
            ],
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Consumer<GameProvider>(builder: (_, game, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Undo
                IconButton(
                  onPressed: game.canUndo ? () => game.undo() : null,
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                ),
                const SizedBox(width: 8),
                // Clear Cell
                IconButton(
                  onPressed: () => game.clearCell(),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear Cell',
                ),
                const SizedBox(width: 8),
                // Hint
                const HintButtonWidget(),
                const SizedBox(width: 8),
                // Note Toggle
                IconButton(
                  onPressed: () => game.toggleNoteMode(),
                  icon: Icon(game.isNoteMode ? Icons.edit : Icons.edit_off),
                  color: game.isNoteMode
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  tooltip: 'Toggle Note Mode',
                ),
                const SizedBox(width: 8),
                // Conflict Check
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                        onPressed: game.isConflictCheckActive
                            ? null
                            : () => game.checkConflicts(),
                        icon: const Icon(Icons.spellcheck),
                        tooltip: 'Check Logic'),
                    if (game.isConflictCheckActive)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${game.conflictCooldown}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
              ],
            );
          }),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NumberPadWidget(
            onNumberSelected: (number) {
              context.read<GameProvider>().inputNumber(number);
            },
          ),
        ),

        // Feedback Message
        Consumer<GameProvider>(
          builder: (_, game, __) {
            if (game.feedbackMessage == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                game.feedbackMessage!,
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            );
          },
        ),
      ],
    );
  }
}
