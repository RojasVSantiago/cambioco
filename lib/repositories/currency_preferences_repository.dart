import 'package:shared_preferences/shared_preferences.dart';

/// Persiste las monedas que el usuario eligió mostrar, cuál es la
/// principal y cuál es la base de conversión.
class CurrencyPreferencesRepository {
  static const String _selectedKey = 'selected_currencies';
  static const String _mainKey = 'main_currency';
  static const String _baseKey = 'base_currency';

  static const List<String> defaultSelected = ['COP', 'USD', 'EUR'];
  static const String defaultMain = 'COP';
  static const String defaultBase = 'USD';

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

  Future<String> getBaseCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseKey) ?? defaultBase;
  }

  Future<void> saveBaseCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseKey, code);
  }
}
