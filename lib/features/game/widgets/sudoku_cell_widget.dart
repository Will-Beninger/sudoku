import 'package:flutter/material.dart';
import 'package:sudoku_poc/core/sudoku/cell.dart';

class SudokuCellWidget extends StatelessWidget {
  final SudokuCell cell;
  final bool isSelected;
  final bool isHighlighted; // Row/Col highlight
  final bool isSameNumber; // Same number highlight
  final bool isConflicting;
  final VoidCallback onTap;
  final Border border;

  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    this.isHighlighted = false,
    this.isSameNumber = false,
    this.isConflicting = false,
    required this.onTap,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background color
    Color? bgColor;
    if (isSelected) {
      bgColor = Colors.blue.withOpacity(0.5);
    } else if (isSameNumber) {
      bgColor = Colors.blue.withOpacity(0.3);
    } else if (isHighlighted) {
      bgColor = Colors.blue.withOpacity(0.1);
    } else if (cell.isFixed) {
      // Adaptive grey for light/dark mode
      bgColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: border,
            ),
            child: Center(
              child: _buildContent(context),
            ),
          ),
          if (isConflicting)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(Icons.close, color: Colors.red, size: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (cell.value != null) {
      return Text(
        cell.value!.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
          color: cell.isFixed
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final num = index + 1;
            if (cell.notes.contains(num)) {
              return Center(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      num.toString(),
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    )),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
