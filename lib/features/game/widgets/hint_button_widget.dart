import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

class HintButtonWidget extends StatelessWidget {
  const HintButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isCooldown = game.isHintActive;

    return ElevatedButton.icon(
      onPressed: isCooldown ? null : () => game.useHint(),
      icon: const Icon(Icons.lightbulb),
      label: Text(isCooldown ? 'Hint (${game.hintCooldown}s)' : 'Hint'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
