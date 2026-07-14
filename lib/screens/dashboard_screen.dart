import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/constants.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';

enum TimePeriod {
  today,
  week,
  month,
  year,
  all,
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  List<Expense> _filterExpensesByPeriod(List<Expense> expenses, TimePeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case TimePeriod.today:
        return expenses.where((e) {
          final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
          return expenseDate == today;
        }).toList();
      case TimePeriod.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return expenses.where((e) {
          final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
          return !expenseDate.isBefore(weekStart) && !expenseDate.isAfter(weekEnd);
        }).toList();
      case TimePeriod.month:
        return expenses.where((e) => 
          e.date.year == now.year && e.date.month == now.month
        ).toList();
      case TimePeriod.year:
        return expenses.where((e) => e.date.year == now.year).toList();
      case TimePeriod.all:
        return expenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expensesProvider);
    final budget = ref.watch(budgetProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final expenses = _filterExpensesByPeriod(allExpenses, _selectedPeriod);

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
      return allExpenses
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .fold(0.0, (sum, e) => sum + e.amount);
    }

    double budgetProgress() {
      if (budget == 0) return 0.0;
      return (currentMonthExpenses() / budget).clamp(0.0, 1.0);
    }

    IconData getPeriodIcon(TimePeriod period) {
      switch (period) {
        case TimePeriod.today:
          return Icons.today;
        case TimePeriod.week:
          return Icons.calendar_view_week;
        case TimePeriod.month:
          return Icons.calendar_month;
        case TimePeriod.year:
          return Icons.calendar_today;
        case TimePeriod.all:
          return Icons.all_inclusive;
      }
    }

    String getPeriodLabel(TimePeriod period) {
      switch (period) {
        case TimePeriod.today:
          return "Aujourd'hui";
        case TimePeriod.week:
          return "Cette semaine";
        case TimePeriod.month:
          return "Ce mois";
        case TimePeriod.year:
          return "Cette année";
        case TimePeriod.all:
          return "Tout";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        actions: [
          PopupMenuButton<TimePeriod>(
            icon: Icon(getPeriodIcon(_selectedPeriod)),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TimePeriod.today,
                child: Row(
                  children: [
                    Icon(Icons.today, size: 20),
                    SizedBox(width: 12),
                    Text("Aujourd'hui"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TimePeriod.week,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_week, size: 20),
                    SizedBox(width: 12),
                    Text("Cette semaine"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TimePeriod.month,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text("Ce mois"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TimePeriod.year,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 12),
                    Text("Cette année"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TimePeriod.all,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 12),
                    Text("Tout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Period Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(getPeriodIcon(_selectedPeriod), color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    getPeriodLabel(_selectedPeriod),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: budgetProgress() > 1.0 
                                ? Colors.red.withValues(alpha: 0.2)
                                : budgetProgress() > 0.8
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            budgetProgress() > 1.0 
                                ? "Dépassé"
                                : budgetProgress() > 0.8
                                    ? "Attention"
                                    : "Normal",
                            style: TextStyle(
                              color: budgetProgress() > 1.0 
                                  ? Colors.red
                                  : budgetProgress() > 0.8
                                      ? Colors.orange
                                      : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedCurrency.formatAmount(budget),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: budgetProgress().clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budgetProgress() > 1.0 
                            ? Colors.red 
                            : budgetProgress() > 0.8 
                                ? Colors.orange 
                                : Colors.green,
                      ),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dépensé: ${selectedCurrency.formatAmount(currentMonthExpenses())}"),
                        Text("Restant: ${selectedCurrency.formatAmount(budget - currentMonthExpenses())}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(budgetProgress() * 100).toStringAsFixed(0)}% du budget utilisé",
                      style: TextStyle(
                        fontSize: 12,
                        color: budgetProgress() > 1.0 
                            ? Colors.red 
                            : budgetProgress() > 0.8 
                                ? Colors.orange 
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Budget Alerts
            if (budgetProgress() > 1.0)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "⚠️ Budget dépassé",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Vous avez dépassé votre budget de ${selectedCurrency.formatAmount(currentMonthExpenses() - budget)}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (budgetProgress() > 0.8 && budgetProgress() <= 1.0)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "⚡ Budget presque atteint",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Il vous reste ${selectedCurrency.formatAmount(budget - currentMonthExpenses())} dans votre budget",
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
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
