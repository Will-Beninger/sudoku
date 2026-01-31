import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/sudoku/cell.dart';

void main() {
  group('SudokuCell', () {
    test('supports value equality', () {
      expect(
        const SudokuCell(value: 1),
        const SudokuCell(value: 1),
      );
    });

    test('copyWith updates properties', () {
      const cell = SudokuCell(value: 1, isFixed: true);
      final updated = cell.copyWith(value: 2);

      expect(updated.value, 2);
      expect(updated.isFixed, true); // Should remain same
    });
  });
}
