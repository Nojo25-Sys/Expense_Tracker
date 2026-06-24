import 'package:flutter/material.dart';

import '../services/hive_service.dart';
import 'add.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> expenses = [];

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
      (sum, item) => sum + (item["amount"] as double),
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

  Future<void> deleteExpense(int id) async {
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
    final filteredExpenses =
        selectedFilter == "Toutes"
            ? expenses
            : expenses.where((expense) {
                return expense["category"] == selectedFilter;
              }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Dépenses"),
        centerTitle: true,
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
                          expense["id"].toString(),
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
                            expense["id"],
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
                                  expense["category"],
                                ),
                                color: Colors.indigo,
                              ),
                            ),

                            title: Text(
                              expense["title"],
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
                                  expense["category"],
                                ),
                                Text(
                                  expense["date"],
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
      "${expense["amount"]} FCFA",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    IconButton(
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
      onPressed: () {
        deleteExpense(expense["id"]);
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