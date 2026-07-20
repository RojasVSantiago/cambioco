/// Representa una moneda soportada por ExchangeRate-API,
/// tal como viene del endpoint `codes`.
class CurrencyInfo {
  final String code; // ej. "COP"
  final String name; // ej. "Colombian Peso"

  const CurrencyInfo({
    required this.code,
    required this.name,
  });

  factory CurrencyInfo.fromJson(List<dynamic> pair) {
    // La API devuelve cada moneda como ["COP", "Colombian Peso"]
    return CurrencyInfo(
      code: pair[0] as String,
      name: pair[1] as String,
    );
  }

  @override
  String toString() => '$code — $name';
}
