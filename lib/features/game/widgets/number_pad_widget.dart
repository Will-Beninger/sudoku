import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/settings/settings_provider.dart';

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

              return Material(
                color: isCompleted
                    ? Colors.black12
                    : Theme.of(context).colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: isCompleted ? null : () => onNumberSelected(number),
                  borderRadius: BorderRadius.circular(8),
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    heightFactor: 0.9,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 96,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          color: isCompleted
                              ? Theme.of(context).disabledColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
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
