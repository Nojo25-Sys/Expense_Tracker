import 'package:hive/hive.dart';

class HiveService {
  static final Box box =
      Hive.box('expenses');

  static Future<void> addExpense(
    Map<String, dynamic> expense,
  ) async {
    await box.add(expense);
  }

  static List getExpenses() {
    return box.values.toList();
  }

  static Future<void> deleteExpense(
      int index) async {
    await box.deleteAt(index);
  }
}