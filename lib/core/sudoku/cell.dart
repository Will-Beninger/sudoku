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

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'isFixed': isFixed,
      'isValid': isValid,
      'notes': notes.toList(),
    };
  }

  factory SudokuCell.fromJson(Map<String, dynamic> json) {
    return SudokuCell(
      value: json['value'] as int?,
      isFixed: json['isFixed'] as bool,
      isValid: json['isValid'] as bool? ?? true,
      notes:
          (json['notes'] as List<dynamic>?)?.map((e) => e as int).toSet() ?? {},
    );
  }
}
