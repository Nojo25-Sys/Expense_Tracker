import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';
import '../models/currency.dart';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.settingsBox);
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return ThemeModeNotifier(box);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box _box;

  ThemeModeNotifier(this._box) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final isDarkMode = _box.get(AppConstants.themeKey, defaultValue: false);
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put(AppConstants.themeKey, mode == ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, double>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return BudgetNotifier(box);
});

class BudgetNotifier extends StateNotifier<double> {
  final Box _box;

  BudgetNotifier(this._box) : super(200000) {
    _loadBudget();
  }

  void _loadBudget() {
    state = _box.get(AppConstants.budgetKey, defaultValue: 200000.0);
  }

  Future<void> setBudget(double budget) async {
    state = budget;
    await _box.put(AppConstants.budgetKey, budget);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return CurrencyNotifier(box);
});

class CurrencyNotifier extends StateNotifier<Currency> {
  final Box _box;
  static const String _currencyKey = 'selectedCurrency';

  CurrencyNotifier(this._box) : super(Currency.allCurrencies.first) {
    _loadCurrency();
  }

  void _loadCurrency() {
    final currencyCode = _box.get(_currencyKey, defaultValue: 'XOF');
    state = Currency.fromCode(currencyCode);
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    await _box.put(_currencyKey, currency.code);
  }
}
