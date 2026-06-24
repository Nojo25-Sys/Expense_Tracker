import 'package:hive/hive.dart';
import '../models/expense.dart';

class HiveService {
  static final Box box = Hive.box('expenses');

  static Future<void> addExpense(Expense expense) async {
    await box.add(expense.toMap());
  }

  static List<Expense> getExpenses() {
    return box.values
        .map((e) => Expense.fromMap(e))
        .toList();
  }

  static Future<void> deleteExpenseById(String id) async {
    final keys = box.keys.toList();

    for (var key in keys) {
      final item = Map<String, dynamic>.from(box.get(key));

      if (item["id"] == id) {
        await box.delete(key);
        break;
      }
    }
  }
}