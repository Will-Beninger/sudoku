import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

class HintButtonWidget extends StatelessWidget {
  const HintButtonWidget({super.key});

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
          iconSize: 32,
        ),
        const SizedBox(height: 4),
        Text(
          isCooldown ? '${game.hintCooldown}s' : 'Hint',
          style: TextStyle(
            fontSize: 14,
            color: isCooldown ? theme.disabledColor : theme.iconTheme.color,
          ),
        ),
      ],
    );
  }
}
