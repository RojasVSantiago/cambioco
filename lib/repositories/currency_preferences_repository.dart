import 'package:shared_preferences/shared_preferences.dart';

/// Persiste las monedas que el usuario eligió mostrar y cuál es la principal.
/// Separado de ExchangeRepository porque maneja preferencias del usuario,
/// no datos de la API.
class CurrencyPreferencesRepository {
  static const String _selectedKey = 'selected_currencies';
  static const String _mainKey = 'main_currency';

  // Valores por defecto — coinciden con el comportamiento actual de la app
  static const List<String> defaultSelected = ['COP', 'USD', 'EUR'];
  static const String defaultMain = 'COP';

  Future<List<String>> getSelectedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_selectedKey) ?? defaultSelected;
  }

  Future<void> saveSelectedCurrencies(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedKey, codes);
  }

  Future<String> getMainCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mainKey) ?? defaultMain;
  }

  Future<void> saveMainCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mainKey, code);
  }
}
