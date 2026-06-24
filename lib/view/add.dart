import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String selectedCategory = "Nourriture";

  final List<String> categories = [
    "Nourriture",
    "Transport",
    "Santé",
    "Éducation",
    "Loisirs",
    "Autres",
  ];

  void saveExpense() {
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs",
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        "id": DateTime.now().millisecondsSinceEpoch,
        "title": titleController.text,
        "amount":
            double.tryParse(amountController.text) ?? 0,
        "category": selectedCategory,
        "date": DateTime.now()
            .toIso8601String()
            .substring(0, 10),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une dépense"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Montant",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Catégorie",
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveExpense,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}