class ExchangeRate {
  // Atributos
  final String baseCurrency;
  final Map<String, double> rates; // todas las tasas devueltas por la API
  final DateTime fetchedAt;

  // Constructor
  const ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.fetchedAt,
  });

  // Getters calculados — se mantienen para no romper RateCard,
  // ConverterWidget e HistoryScreen mientras se migran (Parte 2)
  double get copRate => rateFor('COP');
  double get eurRate => rateFor('EUR');
  double get usdRate => rateFor('USD');

  // Tasa de cualquier moneda soportada — 0 si no está en el mapa
  double rateFor(String code) => rates[code] ?? 0;

  // Convierte un monto de una moneda a otra usando el mapa completo
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    final fromRate = from == baseCurrency ? 1.0 : rateFor(from);
    final toRate = to == baseCurrency ? 1.0 : rateFor(to);

    if (fromRate == 0 || toRate == 0) return 0;

    final inBase = amount / fromRate;
    return inBase * toRate;
  }

  // Crea un ExchangeRate desde la respuesta JSON de la API
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rawRates = json['conversion_rates'] as Map<String, dynamic>;
    final rates = rawRates.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExchangeRate(
      baseCurrency: json['base_code'] as String,
      rates: rates,
      fetchedAt: DateTime.now(),
    );
  }

  // Convierte el modelo a Map para guardarlo en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  // Crea un ExchangeRate desde lo guardado en SharedPreferences
  factory ExchangeRate.fromCache(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;
    final rates = rawRates.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExchangeRate(
      baseCurrency: json['baseCurrency'] as String,
      rates: rates,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}
