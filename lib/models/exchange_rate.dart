class ExchangeRate {
    // Atributos
  final String baseCurrency;
  final double copRate;
  final double eurRate;
  final double usdRate;
  final DateTime fetchedAt;

    // Constructor
  const ExchangeRate({
    required this.baseCurrency,
    required this.copRate,
    required this.eurRate,
    required this.usdRate,
    required this.fetchedAt,
  });

  // Convierte un monto de una moneda a otra
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    // Primero convertimos todo a USD como moneda base
    double inUSD;

    switch (from) {
      case 'COP':
        inUSD = amount / copRate;
      case 'EUR':
        inUSD = amount / eurRate;
      default: // USD
        inUSD = amount;
    }

    // Luego convertimos de USD a la moneda destino
    switch (to) {
      case 'COP':
        return inUSD * copRate;
      case 'EUR':
        return inUSD * eurRate;
      default: // USD
        return inUSD;
    }
  }

  // Crea un ExchangeRate desde la respuesta JSON de la API
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rates = json['conversion_rates'] as Map<String, dynamic>;

    return ExchangeRate(
      baseCurrency: json['base_code'] as String,
      copRate: (rates['COP'] as num).toDouble(),
      eurRate: (rates['EUR'] as num).toDouble(),
      usdRate: 1.0,
      fetchedAt: DateTime.now(),
    );
  }

  // Convierte el modelo a Map para guardarlo en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'copRate': copRate,
      'eurRate': eurRate,
      'usdRate': usdRate,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  // Crea un ExchangeRate desde lo guardado en SharedPreferences
  factory ExchangeRate.fromCache(Map<String, dynamic> json) {
    return ExchangeRate(
      baseCurrency: json['baseCurrency'] as String,
      copRate: (json['copRate'] as num).toDouble(),
      eurRate: (json['eurRate'] as num).toDouble(),
      usdRate: (json['usdRate'] as num).toDouble(),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}