import 'package:flutter/material.dart';

class AppConstants {
  static const String expensesBox = 'expenses';
  static const String settingsBox = 'settings';
  static const String themeKey = 'isDarkMode';
  static const String budgetKey = 'monthlyBudget';
  
  static const List<String> categories = [
    'Nourriture',
    'Transport',
    'Santé',
    'Éducation',
    'Loisirs',
    'Autres',
  ];
  
  static const Map<String, IconData> categoryIcons = {
    'Nourriture': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Santé': Icons.local_hospital,
    'Éducation': Icons.school,
    'Loisirs': Icons.movie,
    'Autres': Icons.category,
  };
}
