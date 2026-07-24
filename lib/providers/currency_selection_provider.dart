import 'package:flutter/material.dart';
import '../repositories/currency_preferences_repository.dart';

/// Maneja qué monedas eligió mostrar el usuario y cuál es la principal.
/// Independiente de ExchangeProvider (ese maneja las tasas en sí).
class CurrencySelectionProvider extends ChangeNotifier {
  final CurrencyPreferencesRepository _repository =
      CurrencyPreferencesRepository();

  List<String> _selectedCurrencies =
      CurrencyPreferencesRepository.defaultSelected;
  String _mainCurrency = CurrencyPreferencesRepository.defaultMain;
  bool _loaded = false;

  List<String> get selectedCurrencies => _selectedCurrencies;
  String get mainCurrency => _mainCurrency;
  bool get isLoaded => _loaded;

  // Cargar preferencias guardadas — llamar una vez al iniciar la app
  Future<void> load() async {
    _selectedCurrencies = await _repository.getSelectedCurrencies();
    _mainCurrency = await _repository.getMainCurrency();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addCurrency(String code) async {
    if (_selectedCurrencies.contains(code)) return;
    _selectedCurrencies = [..._selectedCurrencies, code];
    await _repository.saveSelectedCurrencies(_selectedCurrencies);
    notifyListeners();
  }

  Future<void> removeCurrency(String code) async {
    if (code == _mainCurrency) return; // no se puede quitar la principal
    if (_selectedCurrencies.length <= 1) return; // siempre queda al menos 1
    _selectedCurrencies =
        _selectedCurrencies.where((c) => c != code).toList();
    await _repository.saveSelectedCurrencies(_selectedCurrencies);
    notifyListeners();
  }

  Future<void> setMainCurrency(String code) async {
    if (!_selectedCurrencies.contains(code)) return; // debe estar seleccionada
    _mainCurrency = code;
    await _repository.saveMainCurrency(code);
    notifyListeners();
  }
}
