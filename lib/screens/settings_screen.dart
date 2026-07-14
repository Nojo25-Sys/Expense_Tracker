import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../models/currency.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetController = TextEditingController(text: ref.watch(budgetProvider).toStringAsFixed(0));
    final selectedCurrency = ref.watch(currencyProvider);

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
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
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
                    "Devise",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Currency>(
                    initialValue: selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: "Devise",
                      border: OutlineInputBorder(),
                    ),
                    items: Currency.allCurrencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text("${currency.symbol} - ${currency.name}"),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await ref.read(currencyProvider.notifier).setCurrency(value);
                      }
                    },
                  ),
                ],
              ),
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
                    decoration: InputDecoration(
                      labelText: "Budget (${selectedCurrency.symbol})",
                      border: const OutlineInputBorder(),
                      suffixText: selectedCurrency.symbol,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final value = double.tryParse(budgetController.text);
                        if (value != null && value > 0) {
                          // Convertir en FCFA avant de sauvegarder
                          final budgetInFCFA = selectedCurrency.convertToFCFA(value);
                          await ref.read(budgetProvider.notifier).setBudget(budgetInFCFA);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Budget mis à jour"),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
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
              title: const Text("Outils utilisés"),
              subtitle: const Text("Flutter, Riverpod, Hive, fl_chart, csv, share_plus"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Expense Tracker",
                  applicationVersion: "3.0.0",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
