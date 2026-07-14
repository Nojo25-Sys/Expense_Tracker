class Currency {
  final String code;
  final String symbol;
  final String name;
  final double rateToFCFA; // Taux de conversion vers FCFA

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToFCFA,
  });

  static const List<Currency> allCurrencies = [
    Currency(
      code: 'XOF',
      symbol: 'FCFA',
      name: 'Franc CFA',
      rateToFCFA: 1.0,
    ),
    Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      rateToFCFA: 655.957,
    ),
    Currency(
      code: 'USD',
      symbol: '\$',
      name: 'Dollar US',
      rateToFCFA: 600.0,
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      name: 'Livre Sterling',
      rateToFCFA: 760.0,
    ),
  ];

  static Currency fromCode(String code) {
    return allCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => allCurrencies.first,
    );
  }

  double convertFromFCFA(double amountInFCFA) {
    return amountInFCFA / rateToFCFA;
  }

  double convertToFCFA(double amountInCurrency) {
    return amountInCurrency * rateToFCFA;
  }

  String formatAmount(double amountInFCFA) {
    final converted = convertFromFCFA(amountInFCFA);
    return '${converted.toStringAsFixed(2)} $symbol';
  }
}
