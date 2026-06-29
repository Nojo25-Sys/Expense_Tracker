import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    budgetController.text = BudgetService.monthlyBudget.toStringAsFixed(0);
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Mode sombre"),
              subtitle: const Text("Activer le thème sombre"),
              value: ThemeService.isDarkMode,
              onChanged: (value) async {
                await ThemeService.setDarkMode(value);
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Budget mensuel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Budget (FCFA)",
                      border: OutlineInputBorder(),
                      suffixText: "FCFA",
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final value = double.tryParse(budgetController.text);
                        if (value != null && value > 0) {
                          await BudgetService.setMonthlyBudget(value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Budget mis à jour"),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Veuillez entrer un montant valide"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("À propos"),
              subtitle: const Text("Expense Tracker V2.1"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Expense Tracker",
                  applicationVersion: "2.1.0",
                  applicationLegalese: "© 2026 Personal Finance Dashboard",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
