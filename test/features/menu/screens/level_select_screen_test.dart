import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/menu/screens/level_select_screen.dart';

// Mock Repo
class MockPuzzleRepository extends PuzzleRepository {
  @override
  Future<List<PuzzlePack>> loadPacks() async {
    // Return dummy data
    return [PuzzlePack(id: 'pack_1', name: 'Demo Pack', puzzles: [])];
  }

  @override
  bool isLevelCompleted(String id) => false;

  @override
  Duration? getBestTime(String id) => null;
}

// Mock GameProvider since we only need to verify it exists/methods called
class MockGameProvider extends ChangeNotifier implements GameProvider {
  @override
  void startPuzzle(dynamic puzzle) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(PuzzleRepository repo) {
    return ChangeNotifierProvider<GameProvider>(
      create: (_) => MockGameProvider(),
      child: MaterialApp(
        home: LevelSelectScreen(repository: repo),
      ),
    );
  }

  group('LevelSelectScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      // To test loading state, we need a repo that delays?
      // Or just pump once. FutureBuilder usually starts waiting.
      final repo = MockPuzzleRepository();
      await tester.pumpWidget(createWidgetUnderTest(repo));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders level list after loading', (tester) async {
      final repo = MockPuzzleRepository();
      await tester.pumpWidget(createWidgetUnderTest(repo));
      await tester.pumpAndSettle(); // Wait for FutureBuilder

      // Verify AppBar
      expect(find.text('Select Level'), findsOneWidget);
      // Verify Pack
      expect(find.text('Demo Pack'), findsOneWidget);
    });
  });
}
