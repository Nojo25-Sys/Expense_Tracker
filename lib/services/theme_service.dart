import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeService {
  static const String _themeKey = 'isDarkMode';
  static final Box _settingsBox = Hive.box('settings');

  static final ValueNotifier<bool> _darkModeNotifier = ValueNotifier<bool>(
    _settingsBox.get(_themeKey, defaultValue: false),
  );

  static ValueNotifier<bool> get darkModeNotifier => _darkModeNotifier;

  static bool get isDarkMode => _darkModeNotifier.value;

  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put(_themeKey, value);
    _darkModeNotifier.value = value;
  }

  static ThemeData getTheme(BuildContext context) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
    );
  }
}

class BudgetService {
  static const String _budgetKey = 'monthlyBudget';
  static final Box _settingsBox = Hive.box('settings');

  static double get monthlyBudget {
    return _settingsBox.get(_budgetKey, defaultValue: 100000.0);
  }

  static Future<void> setMonthlyBudget(double value) async {
    await _settingsBox.put(_budgetKey, value);
  }
}
