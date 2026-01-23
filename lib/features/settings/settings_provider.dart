import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _highlightRowCol = false;
  bool _highlightSameNumber = false;
  bool _greyOutCompletedNumbers = true;
  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get highlightRowCol => _highlightRowCol;
  bool get highlightSameNumber => _highlightSameNumber;
  bool get greyOutCompletedNumbers => _greyOutCompletedNumbers;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex =
        _prefs.getInt('theme_mode') ?? 0; // 0: system, 1: light, 2: dark
    if (themeIndex == 1) _themeMode = ThemeMode.light;
    if (themeIndex == 2) _themeMode = ThemeMode.dark;

    _highlightRowCol = _prefs.getBool('highlight_row_col') ?? false;
    _highlightSameNumber = _prefs.getBool('highlight_same_number') ?? false;
    _greyOutCompletedNumbers = _prefs.getBool('grey_out_completed') ?? true;

    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      _prefs.setInt('theme_mode', 1);
    } else {
      _themeMode = ThemeMode.dark;
      _prefs.setInt('theme_mode', 2);
    }
    notifyListeners();
  }

  void setHighlightRowCol(bool value) {
    _highlightRowCol = value;
    _prefs.setBool('highlight_row_col', value);
    notifyListeners();
  }

  void setHighlightSameNumber(bool value) {
    _highlightSameNumber = value;
    _prefs.setBool('highlight_same_number', value);
    notifyListeners();
  }

  void setGreyOutCompletedNumbers(bool value) {
    _greyOutCompletedNumbers = value;
    _prefs.setBool('grey_out_completed', value);
    notifyListeners();
  }
}
