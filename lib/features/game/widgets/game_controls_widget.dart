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
                const SizedBox(width: 16),
                const HintButtonWidget(),
                const SizedBox(width: 16),
                // Note Toggle
                IconButton(
                  onPressed: () => game.toggleNoteMode(),
                  icon: Icon(game.isNoteMode ? Icons.edit : Icons.edit_off),
                  color: game.isNoteMode
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  tooltip: 'Toggle Note Mode',
                ),
              ],
            );
          }),
        ),

        const SizedBox(height: 16),

        // Number Pad
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NumberPadWidget(
            onNumberSelected: (number) {
              context.read<GameProvider>().inputNumber(number);
            },
          ),
        ),
      ],
    );
  }
}
