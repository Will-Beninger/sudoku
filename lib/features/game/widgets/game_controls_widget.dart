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
        // Header: Timer (Centered)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Consumer<GameProvider>(builder: (_, game, __) {
            final t = game.elapsedTime;
            return Text(
              '${t.inMinutes}:${(t.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            );
          }),
        ),

        // Feedback Message (Reserved Space to prevent jump)
        SizedBox(
          height: 24,
          child: Consumer<GameProvider>(
            builder: (_, game, __) {
              if (game.feedbackMessage == null) return const SizedBox.shrink();
              return Center(
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
        ),
        const SizedBox(height: 8),

        // Main Controls Layout: Left Col | NumberPad | Right Col
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 0.0), // Reduced padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LEFT CONTROLS
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSideButton(
                    context,
                    icon: Icons.undo,
                    label: 'Undo',
                    onPressed: context.select((GameProvider g) => g.canUndo)
                        ? () => context.read<GameProvider>().undo()
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSideButton(
                    context,
                    icon: Icons.delete_outline,
                    label: 'Clear',
                    onPressed: () => context.read<GameProvider>().clearCell(),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // CENTER NUMBER PAD
              Expanded(
                child: NumberPadWidget(
                  onNumberSelected: (number) {
                    context.read<GameProvider>().inputNumber(number);
                  },
                ),
              ),

              const SizedBox(width: 16),

              // RIGHT CONTROLS
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hint is complex, needs own widget wrapper usually, but let's try to fit it
                  // For now, simpler to keep using HintButtonWidget but maybe wrap it?
                  // Actually HintButtonWidget returns an IconButton/ElevatedButton.
                  // Let's create a wrapper or just put it here.
                  const HintButtonWidget(),
                  const SizedBox(height: 16),
                  Consumer<GameProvider>(
                    builder: (_, game, __) => _buildSideButton(
                      context,
                      icon: game.isNoteMode ? Icons.edit : Icons.edit_off,
                      label: 'Note',
                      isActive: game.isNoteMode,
                      onPressed: () => game.toggleNoteMode(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<GameProvider>(
                    builder: (_, game, __) => Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildSideButton(
                          context,
                          icon: Icons.spellcheck,
                          label: 'Check',
                          onPressed: game.isConflictCheckActive
                              ? null
                              : () => game.checkConflicts(),
                        ),
                        if (game.isConflictCheckActive)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(BuildContext context,
      {required IconData icon,
      required String label,
      VoidCallback? onPressed,
      bool isActive = false}) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.iconTheme.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, color: onPressed == null ? null : color),
          iconSize: 32, // Larger icons
          style: isActive
              ? IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14, // Larger text
            color: onPressed == null ? theme.disabledColor : color,
          ),
        ),
      ],
    );
  }
}
