import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
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

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/expenses_export.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Export des dépenses',
      text: 'Voici l\'export de vos dépenses au format CSV.',
    );
  }
}
