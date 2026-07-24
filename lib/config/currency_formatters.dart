/// Formatea un valor numérico según la convención de la moneda.
/// COP: sin decimales, punto como separador de miles.
/// USD/EUR: símbolo conocido + 2 decimales.
/// Otras: código ISO como prefijo + 2 decimales.
String formatCurrencyValue(double value, String code) {
  if (code == 'COP') {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\$ $formatted';
  }

  const symbols = {'USD': '\$', 'EUR': '€'};
  final symbol = symbols[code];

  if (symbol != null) {
    return '$symbol ${value.toStringAsFixed(2)}';
  }

  return '$code ${value.toStringAsFixed(2)}';
}
