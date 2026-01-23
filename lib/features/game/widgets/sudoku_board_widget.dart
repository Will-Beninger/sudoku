import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_poc/features/game/widgets/sudoku_cell_widget.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
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

                // Border logic for 3x3 grids using thick borders

                // Border logic for 3x3 grids using thick borders
                final rightBorderWidth =
                    (col + 1) % 3 == 0 && col != 8 ? 2.0 : 0.5;
                final bottomBorderWidth =
                    (row + 1) % 3 == 0 && row != 8 ? 2.0 : 0.5;

                return SudokuCellWidget(
                  cell: cell,
                  isSelected: isSelected,
                  onTap: () => game.selectCell(row, col),
                  border: Border(
                    right: BorderSide(width: rightBorderWidth),
                    bottom: BorderSide(width: bottomBorderWidth),
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
