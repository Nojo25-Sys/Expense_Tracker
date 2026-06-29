import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/theme_service.dart';
import '../services/csv_service.dart';
import 'add.dart';
import 'dashboard.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  String searchQuery = "";
  DateTime? startDate;
  DateTime? endDate;

  String selectedFilter = "Toutes";

  final List<String> filters = [
    "Toutes",
    "Nourriture",
    "Transport",
    "Santé",
    "Éducation",
    "Loisirs",
    "Autres",
  ];

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

  double get total {
    return expenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  Future<void> addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );

    if (result != null) {
      await HiveService.addExpense(result);

      setState(() {
        expenses = HiveService.getExpenses();
      });
    }
  }

  Future<void> deleteExpense(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette dépense ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HiveService.deleteExpenseById(id);

      setState(() {
        expenses = HiveService.getExpenses();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dépense supprimée"),
          ),
        );
      }
    }
  }

  Future<void> editExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );

    if (result != null) {
      await HiveService.updateExpense(result);

      setState(() {
        expenses = HiveService.getExpenses();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dépense modifiée"),
          ),
        );
      }
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Nourriture":
        return Icons.restaurant;

      case "Transport":
        return Icons.directions_car;

      case "Santé":
        return Icons.local_hospital;

      case "Éducation":
        return Icons.school;

      case "Loisirs":
        return Icons.sports_esports;

      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = expenses.where((expense) {
      final matchesCategory = selectedFilter == "Toutes" || expense.category == selectedFilter;
      final matchesSearch = searchQuery.isEmpty || 
          expense.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesDate = (startDate == null || expense.date.isAfter(startDate!.subtract(const Duration(days: 1)))) &&
                          (endDate == null || expense.date.isBefore(endDate!.add(const Duration(days: 1))));
      return matchesCategory && matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Dépenses"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await CsvService.exportToCsv(expenses);
            },
          ),
          IconButton(
            icon: Icon(ThemeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              await ThemeService.setDarkMode(!ThemeService.isDarkMode);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addExpense,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Carte Total
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Total des dépenses",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${total.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher une dépense...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Filtre par date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      startDate == null ? "Date début" : DateFormat('dd/MM/yyyy').format(startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      endDate == null ? "Date fin" : DateFormat('dd/MM/yyyy').format(endDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Filtres
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(
                    child: Text(
                      "Aucune dépense enregistrée",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense =
                          filteredExpenses[index];

                      return Dismissible(
                        key: Key(
                          expense.id,
                        ),
                        direction:
                            DismissDirection.endToStart,
                        background: Container(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                          alignment:
                              Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(
                            right: 20,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          deleteExpense(
                            expense.id,
                          );
                        },
                        child: Card(
                          elevation: 3,
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.indigo.shade100,
                              child: Icon(
                                getCategoryIcon(
                                  expense.category,
                                ),
                                color: Colors.indigo,
                              ),
                            ),

                            title: Text(
                              expense.title,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  expense.category,
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy', 'fr').format(expense.date),
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      "${expense.amount} FCFA",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    IconButton(
      icon: const Icon(
        Icons.edit_outlined,
        color: Colors.blue,
      ),
      onPressed: () {
        editExpense(expense);
      },
    ),
    IconButton(
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
      onPressed: () {
        deleteExpense(expense.id);
      },
    ),
  ],
),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}