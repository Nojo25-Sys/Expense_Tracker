import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/hive_service.dart';

void main() {
  group('HiveService Tests', () {
    setUpAll(() async {
      await Hive.initFlutter();
      await Hive.openBox('test_expenses');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    tearDown(() async {
      final box = Hive.box('test_expenses');
      await box.clear();
    });

    test('Add expense to Hive', () async {
      final expense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      await HiveService.addExpense(expense);

      final expenses = HiveService.getExpenses();
      expect(expenses.length, 1);
      expect(expenses.first.id, 'test-id');
    });

    test('Get all expenses from Hive', () async {
      final expense1 = Expense(
        id: 'test-id-1',
        title: 'Test Expense 1',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      final expense2 = Expense(
        id: 'test-id-2',
        title: 'Test Expense 2',
        amount: 200.0,
        category: 'Transport',
        date: DateTime(2024, 1, 2),
      );

      await HiveService.addExpense(expense1);
      await HiveService.addExpense(expense2);

      final expenses = HiveService.getExpenses();
      expect(expenses.length, 2);
    });

    test('Delete expense by ID', () async {
      final expense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      await HiveService.addExpense(expense);
      expect(HiveService.getExpenses().length, 1);

      await HiveService.deleteExpenseById('test-id');
      expect(HiveService.getExpenses().length, 0);
    });

    test('Update existing expense', () async {
      final expense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      await HiveService.addExpense(expense);

      final updatedExpense = Expense(
        id: 'test-id',
        title: 'Updated Expense',
        amount: 200.0,
        category: 'Transport',
        date: DateTime(2024, 1, 2),
      );

      await HiveService.updateExpense(updatedExpense);

      final expenses = HiveService.getExpenses();
      expect(expenses.length, 1);
      expect(expenses.first.title, 'Updated Expense');
      expect(expenses.first.amount, 200.0);
      expect(expenses.first.category, 'Transport');
    });

    test('Delete non-existent expense does not throw', () async {
      await HiveService.deleteExpenseById('non-existent-id');
      expect(HiveService.getExpenses().length, 0);
    });
  });
}
