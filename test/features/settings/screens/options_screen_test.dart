import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/features/settings/settings_provider.dart';
import 'package:sudoku/features/settings/screens/options_screen.dart';

class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  bool isDarkMode = false;

  @override
  bool highlightRowCol = true;

  @override
  bool highlightSameNumber = true;

  @override
  bool greyOutCompletedNumbers = true;

  @override
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  @override
  void setHighlightRowCol(bool value) {
    highlightRowCol = value;
    notifyListeners();
  }

  @override
  void setHighlightSameNumber(bool value) {
    highlightSameNumber = value;
    notifyListeners();
  }

  @override
  void setGreyOutCompletedNumbers(bool value) {
    greyOutCompletedNumbers = value;
    notifyListeners();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createWidgetUnderTest(SettingsProvider settings) {
    return ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: const MaterialApp(
        home: OptionsScreen(),
      ),
    );
  }

  group('OptionsScreen', () {
    testWidgets('renders all settings options', (tester) async {
      final settings = MockSettingsProvider();
      await tester.pumpWidget(createWidgetUnderTest(settings));

      expect(find.text('Options'), findsOneWidget); // AppBar
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Gameplay Highlights'), findsOneWidget);
      expect(find.text('Highlight Row & Column'), findsOneWidget);
    });

    testWidgets('toggling dark mode updates value', (tester) async {
      final settings = MockSettingsProvider();
      await tester.pumpWidget(createWidgetUnderTest(settings));

      // Initial state
      expect(settings.isDarkMode, false);

      // Tap switch
      await tester.tap(find.widgetWithText(SwitchListTile, 'Dark Mode'));
      await tester.pump();

      expect(settings.isDarkMode, true);
    });
  });
}
