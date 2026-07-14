import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../core/constants.dart';

final expenseBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.expensesBox);
});

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  final box = ref.watch(expenseBoxProvider);
  return ExpensesNotifier(box);
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final Box _box;

  ExpensesNotifier(this._box) : super([]) {
    _loadExpenses();
  }

  void _loadExpenses() {
    state = _box.values.map((map) => Expense.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _box.add(expense.toMap());
    _loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    final keys = _box.keys.toList();
    for (var key in keys) {
      final item = Map<String, dynamic>.from(_box.get(key));
      if (item["id"] == expense.id) {
        await _box.put(key, expense.toMap());
        break;
      }
    }
    _loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    final keys = _box.keys.toList();
    for (var key in keys) {
      final item = Map<String, dynamic>.from(_box.get(key));
      if (item["id"] == id) {
        await _box.delete(key);
        break;
      }
    }
    _loadExpenses();
  }
}

final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
});
