import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/i_puzzle_repository.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/game/screens/game_screen.dart';
import 'package:sudoku/features/game/widgets/sudoku_board_widget.dart';
import 'package:sudoku/features/game/widgets/game_controls_widget.dart';
import 'package:sudoku/features/settings/settings_provider.dart';
import 'package:sudoku/core/sudoku/grid.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/device_simulators.dart';

class MockPuzzleRepository extends Mock implements IPuzzleRepository {}

class MockGameProvider extends Mock implements GameProvider {}

void main() {
  late MockPuzzleRepository mockRepo;
  late MockGameProvider mockGameProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockPuzzleRepository();
    mockGameProvider = MockGameProvider();

    // Default stubs
    when(() => mockGameProvider.grid).thenReturn(SudokuGrid.empty());
    when(() => mockGameProvider.isLoading).thenReturn(false);
    when(() => mockGameProvider.isWon).thenReturn(false);
    when(() => mockGameProvider.elapsedTime).thenReturn(Duration.zero);
    when(() => mockGameProvider.isNoteMode).thenReturn(false);
    when(() => mockGameProvider.canUndo).thenReturn(false);
    when(() => mockGameProvider.isHintActive).thenReturn(false);
    when(() => mockGameProvider.hintCooldown).thenReturn(0);
    when(() => mockGameProvider.isConflictCheckActive).thenReturn(false);
    when(() => mockGameProvider.conflictCooldown).thenReturn(0);
    when(() => mockGameProvider.conflictingCells).thenReturn({});
    when(() => mockGameProvider.currentPuzzle).thenReturn(null);
    when(() => mockGameProvider.getCompletedNumbers()).thenReturn({});
  });

  Widget createSubject() {
    return MultiProvider(
      providers: [
        Provider<IPuzzleRepository>.value(value: mockRepo),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<GameProvider>.value(value: mockGameProvider),
      ],
      child: const MaterialApp(
        home: GameScreen(),
      ),
    );
  }

  group('GameScreen UI Tests', () {
    testUI('Renders Board and Controls', callback: (tester, deviceSize) async {
      await tester.pumpWidget(createSubject());
      // GameScreen has post frame callback for timer, pump to setting it
      await tester.pump();

      expect(find.byType(SudokuBoardWidget), findsOneWidget);
      expect(find.byType(GameControlsWidget), findsOneWidget);
    });

    testUI('Layout adapts to orientation/size',
        callback: (tester, deviceSize) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final boardFinder = find.byType(SudokuBoardWidget);
      final controlsFinder = find.byType(GameControlsWidget);

      final boardCenter = tester.getCenter(boardFinder);
      final controlsCenter = tester.getCenter(controlsFinder);

      if (deviceSize.width > deviceSize.height && deviceSize.width > 900) {
        // Landscape / Wide (Laptop)
        // Board should be to the left of Controls (or at least roughly horizontal relationship)
        // Our layout logic: Row(children: [Expanded(Board), Expanded(Controls)])
        expect(boardCenter.dx, lessThan(controlsCenter.dx),
            reason: "On wide screens, board should be left of controls");
      } else {
        // Portrait (Pixel, iPhone)
        // Board should be above Controls
        // Column(children: [Expanded(Board), Expanded(Controls)])
        expect(boardCenter.dy, lessThan(controlsCenter.dy),
            reason: "On portrait screens, board should be above controls");
      }
    });
  });
}
