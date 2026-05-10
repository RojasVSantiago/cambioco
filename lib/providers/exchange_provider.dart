import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../repositories/exchange_repository.dart';

// Estados posibles de la consulta
enum ExchangeStatus { initial, loading, success, error }

class ExchangeProvider extends ChangeNotifier {
  final ExchangeRepository _repository = ExchangeRepository();

  ExchangeStatus _status = ExchangeStatus.initial;
  ExchangeRate? _currentRate;
  ExchangeRate? _previousRate;
  String _errorMessage = '';

  // Getters — la UI solo puede leer, no modificar directamente
  ExchangeStatus get status => _status;
  ExchangeRate? get currentRate => _currentRate;
  ExchangeRate? get previousRate => _previousRate;
  String get errorMessage => _errorMessage;

  // ¿El dólar subió respecto a la consulta anterior?
  bool? get copTrend {
    if (_currentRate == null || _previousRate == null) return null;
    return _currentRate!.copRate > _previousRate!.copRate;
  }

  // Carga la tasa al iniciar — primero muestra caché, luego actualiza
  Future<void> loadRate() async {
    // Si hay caché, mostrarlo inmediatamente mientras carga
    final cached = await _repository.getCachedRate();
    if (cached != null) {
      _previousRate = _currentRate;
      _currentRate = cached;
      _status = ExchangeStatus.success;
      notifyListeners();
    } else {
      _status = ExchangeStatus.loading;
      notifyListeners();
    }

    // Luego busca datos frescos de la API
    try {
      final fresh = await _repository.fetchLatestRate();
      _previousRate = _currentRate;
      _currentRate = fresh;
      _status = ExchangeStatus.success;
    } catch (e) {
      // Si ya había caché, no sobreescribimos con error
      if (_currentRate == null) {
        _status = ExchangeStatus.error;
        _errorMessage = 'Sin conexión y sin datos guardados.\nIntenta más tarde.';
      }
    }

    notifyListeners();
  }

  // Permite refrescar manualmente con pull-to-refresh
  Future<void> refresh() async {
    _status = ExchangeStatus.loading;
    notifyListeners();
    await loadRate();
  }
}