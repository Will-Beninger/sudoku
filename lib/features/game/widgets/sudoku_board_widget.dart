import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/features/game/widgets/sudoku_cell_widget.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/settings/settings_provider.dart';

class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, game, settings, child) {
        if (game.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        // High contrast border for outer edge
        final outerBorderColor = isDark ? Colors.white70 : Colors.black;
        // Slightly less contrast for inner 3x3
        final heavyBorderColor = isDark ? Colors.white54 : Colors.black87;
        // Subtle for cells
        final lightBorderColor = isDark ? Colors.white24 : Colors.black12;

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: outerBorderColor, width: 2),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final cell = game.grid.rows[row][col];

                final isSelected =
                    game.selectedRow == row && game.selectedCol == col;

                // Highlighting Logic
                bool isHighlighted = false;
                bool isSameNumber = false;
                bool isConflicting = false;

                if (settings.highlightRowCol) {
                  if (game.selectedRow == row || game.selectedCol == col) {
                    isHighlighted = true;
                  }
                }

                if (settings.highlightSameNumber &&
                    cell.value != null && // Must have a value to match
                    game.selectedRow != null &&
                    game.selectedCol != null) {
                  // Get selected value
                  final selectedValue = game
                      .grid.rows[game.selectedRow!][game.selectedCol!].value;
                  if (selectedValue != null && cell.value == selectedValue) {
                    isSameNumber = true;
                  }
                }

                // Conflict Logic
                if (game.conflictingCells.contains((r: row, c: col))) {
                  isConflicting = true;
                }

                // Border logic for 3x3 grids using thick borders
                final rightBorderWidth =
                    (col + 1) % 3 == 0 && col != 8 ? 2.0 : 0.5;
                final bottomBorderWidth =
                    (row + 1) % 3 == 0 && row != 8 ? 2.0 : 0.5;

                final rightColor = rightBorderWidth > 1.0
                    ? heavyBorderColor
                    : lightBorderColor;
                final bottomColor = bottomBorderWidth > 1.0
                    ? heavyBorderColor
                    : lightBorderColor;

                return SudokuCellWidget(
                  cell: cell,
                  isSelected: isSelected,
                  isHighlighted: isHighlighted,
                  isSameNumber: isSameNumber,
                  isConflicting: isConflicting,
                  onTap: () => game.selectCell(row, col),
                  border: Border(
                    right:
                        BorderSide(width: rightBorderWidth, color: rightColor),
                    bottom: BorderSide(
                        width: bottomBorderWidth, color: bottomColor),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
