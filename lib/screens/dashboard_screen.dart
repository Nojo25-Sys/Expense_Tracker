import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/constants.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final budget = ref.watch(budgetProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    double totalExpenses() {
      return expenses.fold(0.0, (sum, item) => sum + item.amount);
    }

    int totalTransactions() {
      return expenses.length;
    }

    double averageExpense() {
      if (expenses.isEmpty) return 0.0;
      return totalExpenses() / expenses.length;
    }

    String topCategory() {
      if (expenses.isEmpty) return "Aucune";
      
      final categoryMap = <String, double>{};
      for (var expense in expenses) {
        categoryMap[expense.category] = 
            (categoryMap[expense.category] ?? 0) + expense.amount;
      }
      
      if (categoryMap.isEmpty) return "Aucune";
      
      return categoryMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    List<PieChartSectionData> pieChartData() {
      final categoryMap = <String, double>{};
      for (var expense in expenses) {
        categoryMap[expense.category] = 
            (categoryMap[expense.category] ?? 0) + expense.amount;
      }
      
      return categoryMap.entries.map((entry) {
        final index = AppConstants.categories.indexOf(entry.key);
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.grey,
        ];
        
        return PieChartSectionData(
          value: entry.value,
          title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
          color: colors[index % colors.length],
          radius: 100,
        );
      }).toList();
    }

    double currentMonthExpenses() {
      final now = DateTime.now();
      return expenses
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .fold(0.0, (sum, e) => sum + e.amount);
    }

    double budgetProgress() {
      if (budget == 0) return 0.0;
      return (currentMonthExpenses() / budget).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Stats Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  "Total",
                  selectedCurrency.formatAmount(totalExpenses()),
                  Icons.account_balance_wallet,
                  Colors.indigo,
                ),
                _buildStatCard(
                  context,
                  "Transactions",
                  totalTransactions().toString(),
                  Icons.receipt_long,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  "Moyenne",
                  selectedCurrency.formatAmount(averageExpense()),
                  Icons.calculate,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  "Top Catégorie",
                  topCategory(),
                  Icons.category,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Budget Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Budget Mensuel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedCurrency.formatAmount(budget),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: budgetProgress(),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budgetProgress() > 1.0 ? Colors.red : Colors.green,
                      ),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dépensé: ${selectedCurrency.formatAmount(currentMonthExpenses())}"),
                        Text("Restant: ${selectedCurrency.formatAmount(budget - currentMonthExpenses())}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pie Chart
            if (expenses.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Répartition par catégorie",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartData(),
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
