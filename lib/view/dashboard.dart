import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController budgetController = TextEditingController();
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

  double get currentMonthExpenses {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get budgetProgress {
    final budget = BudgetService.monthlyBudget;
    if (budget == 0) return 0.0;
    return currentMonthExpenses / budget;
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

  List<FlSpot> get monthlyChartData {
    final now = DateTime.now();
    final monthlyData = <int, double>{};

    for (var expense in expenses) {
      final monthKey = expense.date.year * 100 + expense.date.month;
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + expense.amount;
    }

    final spots = <FlSpot>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = date.year * 100 + date.month;
      final value = monthlyData[key] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              budgetController.text = BudgetService.monthlyBudget.toStringAsFixed(0);
              final result = await showDialog<double>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Modifier le budget mensuel"),
                  content: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Budget (FCFA)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        final value = double.tryParse(budgetController.text);
                        if (value != null && value > 0) {
                          Navigator.pop(context, value);
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ],
                ),
              );
              if (result != null) {
                await BudgetService.setMonthlyBudget(result);
                setState(() {});
              }
            },
          ),
        ],
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
            if (expenses.isNotEmpty)
              Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 20),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Évolution mensuelle",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: monthlyChartData,
                                  isCurved: true,
                                  color: Colors.indigo,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
              childAspectRatio: 1.2,
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
                  _buildStatCard(
                    "Budget du mois",
                    "${currentMonthExpenses.toStringAsFixed(0)} / ${BudgetService.monthlyBudget.toStringAsFixed(0)} FCFA",
                    Icons.account_balance,
                    budgetProgress > 1.0 ? Colors.red : Colors.teal,
                  ),
                  _buildStatCard(
                    "Progression",
                    "${(budgetProgress * 100).toStringAsFixed(0)}%",
                    Icons.pie_chart_outline,
                    budgetProgress > 0.8 ? Colors.orange : Colors.blue,
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
