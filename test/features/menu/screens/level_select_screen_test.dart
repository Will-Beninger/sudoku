import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/core/sudoku/grid.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/menu/screens/level_select_screen.dart';
import 'package:sudoku/features/settings/settings_provider.dart';

// Mock Repo
class MockPuzzleRepository extends PuzzleRepository {
  bool hasSavedGameValue = false;

  @override
  Future<List<PuzzlePack>> loadPacks() async {
    return [
      PuzzlePack(
        id: 'pack_1',
        name: 'Demo Pack',
        puzzles: [
          Puzzle(
              id: 'p1',
              difficulty: Difficulty.easy,
              initialBoard: '0' * 81,
              solutionBoard: '1' * 81),
          Puzzle(
              id: 'p2',
              difficulty: Difficulty.easy,
              initialBoard: '0' * 81,
              solutionBoard: '1' * 81),
        ],
      )
    ];
  }

  @override
  bool isLevelCompleted(String id) => false;

  @override
  Duration? getBestTime(String id) => null;

  @override
  bool hasSavedGame() => hasSavedGameValue;

  @override
  Future<String?> getSavedPuzzleId() async {
    return hasSavedGameValue ? 'p1' : null;
  }
}

// Mock GameProvider since we only need to verify it exists/methods called
class MockGameProvider extends ChangeNotifier implements GameProvider {
  bool startPuzzleCalled = false;

  @override
  bool isLoading = false;
  @override
  bool isWon = false;
  @override
  Duration elapsedTime = Duration.zero;
  @override
  SudokuGrid grid = SudokuGrid.empty();
  @override
  Puzzle? currentPuzzle;
  @override
  String? feedbackMessage;
  @override
  bool isNoteMode = false;
  @override
  int? selectedRow;
  @override
  int? selectedCol;

  @override
  void startPuzzle(dynamic puzzle) {
    startPuzzleCalled = true;
  }

  // Stubs for other getters used by consumers
  @override
  int hintsUsed = 0;
  @override
  int mistakes = 0;
  @override
  int hintCooldownSeconds = 0;
  @override
  int conflictCooldownSeconds = 0;
  @override
  List<SudokuGrid> history = [];

  @override
  Future<void> loadSavedGame() async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(
      PuzzleRepository repo, GameProvider gameProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        home: LevelSelectScreen(repository: repo),
      ),
    );
  }

  group('LevelSelectScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      final repo = MockPuzzleRepository();
      final game = MockGameProvider();
      await tester.pumpWidget(createWidgetUnderTest(repo, game));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders level list after loading', (tester) async {
      final repo = MockPuzzleRepository();
      final game = MockGameProvider();
      await tester.pumpWidget(createWidgetUnderTest(repo, game));
      await tester.pumpAndSettle();

      expect(find.text('Select Level'), findsOneWidget);
      expect(find.text('Demo Pack'), findsOneWidget);
    });

    testWidgets('shows warning dialog when saved game exists', (tester) async {
      final repo = MockPuzzleRepository();
      repo.hasSavedGameValue = true;
      final game = MockGameProvider();

      await tester.pumpWidget(createWidgetUnderTest(repo, game));
      await tester.pumpAndSettle();

      // Expand Pack
      await tester.tap(find.text('Demo Pack'));
      await tester.pumpAndSettle();

      // Expand Difficulty (EASY)
      await tester.tap(find.text('EASY'));
      await tester.pumpAndSettle();

      // Tap Puzzle
      await tester.tap(find.text('Puzzle p2'));
      await tester.pumpAndSettle();

      // Verify Dialog
      expect(find.text('Start New Game?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Start New Game?'), findsNothing);
      expect(game.startPuzzleCalled, false);

      // Verify Start New Game button exists but don't tap it to avoid triggering
      // complex GameScreen navigation which requires extensive mocking.
      // The presence of the dialog and the Cancel working proves the logic.
      await tester.tap(find.text('Puzzle p2'));
      await tester.pumpAndSettle();
      expect(find.text('Start New Game'), findsOneWidget);
    });

    testWidgets('shows resume dialog when saved puzzle selected',
        (tester) async {
      final repo = MockPuzzleRepository();
      repo.hasSavedGameValue = true;
      final game = MockGameProvider();

      await tester.pumpWidget(createWidgetUnderTest(repo, game));
      await tester.pumpAndSettle();

      // Open pack and difficulty
      await tester.tap(find.text('Demo Pack'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EASY'));
      await tester.pumpAndSettle();

      // Verify "In Progress" indicator
      expect(find.text('In Progress'), findsOneWidget);

      // Tap saved puzzle
      await tester.tap(find.text('Puzzle p1'));
      await tester.pumpAndSettle();

      // Verify Resume Dialog
      expect(find.text('Resume Game?'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Restart Level'), findsOneWidget);

      // Tap Cancel to close dialog cleanly
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
