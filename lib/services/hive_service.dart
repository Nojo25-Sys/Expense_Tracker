import 'package:hive/hive.dart';

class HiveService {
  static final Box box = Hive.box('expenses');

  static Future<void> addExpense(
    Map<String, dynamic> expense,
  ) async {
    await box.add(expense);
  }

  static List<Map<String, dynamic>> getExpenses() {
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> deleteExpenseById(
      int id) async {
    final keys = box.keys.toList();

    for (var key in keys) {
      final item =
          Map<String, dynamic>.from(box.get(key));

      if (item["id"] == id) {
        await box.delete(key);
        break;
      }
    }
  }
}