import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/data/repositories/i_puzzle_repository.dart';
import 'package:sudoku/features/game/game_provider.dart';
import 'package:sudoku/features/menu/screens/main_menu_screen.dart';
import 'package:sudoku/features/settings/settings_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/device_simulators.dart';

class MockPuzzleRepository extends Mock implements IPuzzleRepository {}

class MockGameProvider extends Mock implements GameProvider {}

void main() {
  late MockPuzzleRepository mockRepo;
  late MockGameProvider mockGameProvider;

  setUp(() {
    mockRepo = MockPuzzleRepository();
    mockGameProvider = MockGameProvider();

    PackageInfo.setMockInitialValues(
      appName: 'Sudoku',
      packageName: 'com.example.sudoku',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    SharedPreferences.setMockInitialValues({});

    // Default stubs
    when(() => mockRepo.hasSavedGame()).thenReturn(false);
    when(() => mockGameProvider.isWon).thenReturn(false);
    when(() => mockGameProvider.isLoading).thenReturn(false);
  });

  Widget createSubject() {
    return MultiProvider(
      providers: [
        Provider<IPuzzleRepository>.value(value: mockRepo),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<GameProvider>.value(value: mockGameProvider),
      ],
      child: const MaterialApp(
        home: MainMenuScreen(),
      ),
    );
  }

  group('MainMenuScreen UI Tests', () {
    testUI('Renders critical elements', callback: (tester, deviceSize) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Sudoku: Always Free'), findsNWidgets(2));

      // Verify Play Game button
      expect(find.text('Play Game'), findsOneWidget);

      // Verify Statistics button
      expect(find.text('Statistics'), findsOneWidget);

      // Verify Options button
      expect(find.text('Options'), findsOneWidget);

      // Verify App Icon
      expect(find.byType(Image), findsOneWidget);
    });

    testUI('Does not overflow', callback: (tester, deviceSize) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Implicitly checks for overflow errors which would throw exceptions in test environment
      // We can also check that the bottom element is visible
      // For laptop, we might expect different layout, but components should be there.
    });
  });
}
