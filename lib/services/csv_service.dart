import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class CsvService {
  static Future<void> exportToCsv(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return;
    }

    final rows = [
      ['Date', 'Titre', 'Montant', 'Catégorie'],
      ...expenses.map((expense) => [
        DateFormat('dd/MM/yyyy').format(expense.date),
        expense.title,
        expense.amount.toString(),
        expense.category,
      ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);

    await Share.share(
      csvData,
      subject: 'Export des dépenses',
    );
  }
}
