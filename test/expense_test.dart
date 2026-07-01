import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense creation with valid data', () {
      final expense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      expect(expense.id, 'test-id');
      expect(expense.title, 'Test Expense');
      expect(expense.amount, 100.0);
      expect(expense.category, 'Nourriture');
      expect(expense.date, DateTime(2024, 1, 1));
    });

    test('Expense toMap conversion', () {
      final expense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      final map = expense.toMap();

      expect(map['id'], 'test-id');
      expect(map['title'], 'Test Expense');
      expect(map['amount'], 100.0);
      expect(map['category'], 'Nourriture');
      expect(map['date'], '2024-01-01T00:00:00.000');
    });

    test('Expense fromMap conversion with double amount', () {
      final map = {
        'id': 'test-id',
        'title': 'Test Expense',
        'amount': 100.0,
        'category': 'Nourriture',
        'date': '2024-01-01T00:00:00.000',
      };

      final expense = Expense.fromMap(map);

      expect(expense.id, 'test-id');
      expect(expense.title, 'Test Expense');
      expect(expense.amount, 100.0);
      expect(expense.category, 'Nourriture');
      expect(expense.date, DateTime(2024, 1, 1));
    });

    test('Expense fromMap conversion with int amount', () {
      final map = {
        'id': 'test-id',
        'title': 'Test Expense',
        'amount': 100, // int instead of double
        'category': 'Nourriture',
        'date': '2024-01-01T00:00:00.000',
      };

      final expense = Expense.fromMap(map);

      expect(expense.amount, 100.0); // Should be converted to double
    });

    test('Expense round-trip conversion', () {
      final originalExpense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Nourriture',
        date: DateTime(2024, 1, 1),
      );

      final map = originalExpense.toMap();
      final restoredExpense = Expense.fromMap(map);

      expect(restoredExpense.id, originalExpense.id);
      expect(restoredExpense.title, originalExpense.title);
      expect(restoredExpense.amount, originalExpense.amount);
      expect(restoredExpense.category, originalExpense.category);
      expect(restoredExpense.date, originalExpense.date);
    });
  });
}
