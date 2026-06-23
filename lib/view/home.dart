import 'package:flutter/material.dart';

import '../services/hive_service.dart';
import 'add.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List expenses = [];

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
      (sum, item) =>
          sum + (item["amount"] as double),
    );
  }

  Future<void> addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddExpenseScreen(),
      ),
    );

    if (result != null) {
      await HiveService.addExpense(result);

      setState(() {
        expenses =
            HiveService.getExpenses();
      });
    }
  }

  Future<void> deleteExpense(
      int index) async {
    await HiveService.deleteExpense(
      index,
    );

    setState(() {
      expenses = HiveService.getExpenses();
    });
  }

  IconData getCategoryIcon(
      String category) {
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
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Gestion des Dépenses"),
        centerTitle: true,
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: addExpense,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.all(16),
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Total des dépenses",
                  style: TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                    height: 10),
                Text(
                  "${total.toStringAsFixed(0)} FCFA",
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      "Aucune dépense enregistrée",
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        expenses.length,
                    itemBuilder:
                        (context,
                            index) {
                      final expense =
                          expenses[
                              index];

                      return Card(
                        elevation: 3,
                        margin:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              12,
                          vertical:
                              6,
                        ),
                        child:
                            ListTile(
                          leading:
                              CircleAvatar(
                            child: Icon(
                              getCategoryIcon(
                                expense[
                                    "category"],
                              ),
                            ),
                          ),
                          title: Text(
                            expense[
                                "title"],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          subtitle:
                              Text(
                            expense[
                                "category"],
                          ),
                          trailing:
                              Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                "${expense["amount"]} FCFA",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(
                                  Icons
                                      .delete,
                                  color: Colors
                                      .red,
                                ),
                                onPressed:
                                    () {
                                  deleteExpense(
                                      index);
                                },
                              ),
                            ],
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