import 'package:flutter/material.dart';
import '../repositories/currency_preferences_repository.dart';

/// Maneja qué monedas eligió mostrar el usuario, cuál es la principal
/// y cuál es la base de conversión. Principal y base nunca pueden
/// coincidir — si lo hicieran, la card destacada de la principal
/// desaparecería (convertir una moneda contra sí misma no se muestra).
class CurrencySelectionProvider extends ChangeNotifier {
  final CurrencyPreferencesRepository _repository =
      CurrencyPreferencesRepository();

  List<String> _selectedCurrencies =
      CurrencyPreferencesRepository.defaultSelected;
  String _mainCurrency = CurrencyPreferencesRepository.defaultMain;
  String _baseCurrency = CurrencyPreferencesRepository.defaultBase;
  bool _loaded = false;

  List<String> get selectedCurrencies => _selectedCurrencies;
  String get mainCurrency => _mainCurrency;
  String get baseCurrency => _baseCurrency;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _selectedCurrencies = await _repository.getSelectedCurrencies();
    _mainCurrency = await _repository.getMainCurrency();
    _baseCurrency = await _repository.getBaseCurrency();
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
    if (code == _mainCurrency || code == _baseCurrency) return;
    if (_selectedCurrencies.length <= 2) return; // mínimo: principal + base
    _selectedCurrencies =
        _selectedCurrencies.where((c) => c != code).toList();
    await _repository.saveSelectedCurrencies(_selectedCurrencies);
    notifyListeners();
  }

  Future<void> setMainCurrency(String code) async {
    if (!_selectedCurrencies.contains(code)) return;
    if (code == _baseCurrency) return; // no puede coincidir con la base
    _mainCurrency = code;
    await _repository.saveMainCurrency(code);
    notifyListeners();
  }

  Future<void> setBaseCurrency(String code) async {
    if (!_selectedCurrencies.contains(code)) return;
    if (code == _mainCurrency) return; // no puede coincidir con la principal
    _baseCurrency = code;
    await _repository.saveBaseCurrency(code);
    notifyListeners();
  }

  /// Aplica varios cambios a la vez (usado por ManageCurrenciesScreen con
  /// flujo de confirmación) — evita notificaciones/escrituras intermedias.
  /// Lanza un AssertionError en debug si el estado resultante es inválido;
  /// la pantalla que llama a esto debe validar antes de invocarlo.
  Future<void> applyChanges({
    required List<String> selectedCurrencies,
    required String mainCurrency,
    required String baseCurrency,
  }) async {
    assert(selectedCurrencies.length >= 2);
    assert(selectedCurrencies.contains(mainCurrency));
    assert(selectedCurrencies.contains(baseCurrency));
    assert(mainCurrency != baseCurrency);

    _selectedCurrencies = selectedCurrencies;
    _mainCurrency = mainCurrency;
    _baseCurrency = baseCurrency;

    await _repository.saveSelectedCurrencies(_selectedCurrencies);
    await _repository.saveMainCurrency(_mainCurrency);
    await _repository.saveBaseCurrency(_baseCurrency);

    notifyListeners();
  }
}
