import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';
import 'package:sudoku_poc/features/settings/settings_provider.dart';

class NumberPadWidget extends StatelessWidget {
  final ValueChanged<int> onNumberSelected;

  const NumberPadWidget({
    super.key,
    required this.onNumberSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, game, settings, child) {
        final completedNumbers = settings.greyOutCompletedNumbers
            ? game.getCompletedNumbers()
            : <int>{};

        return AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final number = index + 1;
              final isCompleted = completedNumbers.contains(number);

              return FilledButton.tonal(
                onPressed: isCompleted ? null : () => onNumberSelected(number),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  // Explicitly grey out background if completed
                  backgroundColor: isCompleted ? Colors.black12 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
