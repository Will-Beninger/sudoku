import 'package:equatable/equatable.dart';

class SudokuCell extends Equatable {
  final int? value;
  final bool isFixed; // True if part of the initial puzzle
  final bool isValid; // True if the value doesn't conflict

  final Set<int> notes; // User notes/guesses for this cell

  const SudokuCell({
    this.value,
    this.isFixed = false,
    this.isValid = true,
    this.notes = const {},
  });

  SudokuCell copyWith({
    int? value,
    bool? isFixed,
    bool? isValid,
    Set<int>? notes,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isFixed: isFixed ?? this.isFixed,
      isValid: isValid ?? this.isValid,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [value, isFixed, isValid, notes];
}
