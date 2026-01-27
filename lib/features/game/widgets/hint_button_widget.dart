import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

class HintButtonWidget extends StatelessWidget {
  final bool useLargeControls;

  const HintButtonWidget({super.key, this.useLargeControls = false});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isCooldown = game.isHintActive;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: isCooldown ? null : () => game.useHint(),
          icon: const Icon(Icons.lightbulb),
          iconSize: useLargeControls ? 56 : 32,
        ),
        const SizedBox(height: 4),
        Text(
          isCooldown ? '${game.hintCooldown}s' : 'Hint',
          style: TextStyle(
            fontSize: useLargeControls ? 16 : 14,
            color: isCooldown ? theme.disabledColor : theme.iconTheme.color,
          ),
        ),
      ],
    );
  }
}
