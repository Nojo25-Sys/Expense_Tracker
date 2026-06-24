import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() {
    setState(() {
      expenses = HiveService.getExpenses();
    });
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  int get totalTransactions {
    return expenses.length;
  }

  double get averageExpense {
    if (expenses.isEmpty) return 0.0;
    return totalExpenses / expenses.length;
  }

  String get topCategory {
    if (expenses.isEmpty) return "Aucune";
    
    final categoryMap = <String, double>{};
    for (var expense in expenses) {
      categoryMap[expense.category] = 
          (categoryMap[expense.category] ?? 0) + expense.amount;
    }
    
    if (categoryMap.isEmpty) return "Aucune";
    
    return categoryMap.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  List<PieChartSectionData> get pieChartData {
    if (expenses.isEmpty) return [];

    final categoryMap = <String, double>{};
    for (var expense in expenses) {
      categoryMap[expense.category] = 
          (categoryMap[expense.category] ?? 0) + expense.amount;
    }

    final total = categoryMap.values.fold(0.0, (sum, val) => sum + val);
    if (total == 0) return [];

    final colors = [
      Colors.indigo,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int colorIndex = 0;
    return categoryMap.entries.map((entry) {
      final value = entry.value;
      final percentage = (value / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (expenses.isNotEmpty)
              Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 20),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChart(
                      PieChartData(
                        sections: pieChartData,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
              ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                  _buildStatCard(
                    "Total Dépenses",
                    "${totalExpenses.toStringAsFixed(0)} FCFA",
                    Icons.account_balance_wallet,
                    Colors.indigo,
                  ),
                  _buildStatCard(
                    "Transactions",
                    totalTransactions.toString(),
                    Icons.receipt_long,
                    Colors.green,
                  ),
                  _buildStatCard(
                    "Catégorie dominante",
                    topCategory,
                    Icons.category,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    "Moyenne",
                    "${averageExpense.toStringAsFixed(0)} FCFA",
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
