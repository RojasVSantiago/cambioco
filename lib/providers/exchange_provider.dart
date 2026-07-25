import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../repositories/exchange_repository.dart';

enum ExchangeStatus { initial, loading, success, error }

class ExchangeProvider extends ChangeNotifier {
  final ExchangeRepository _repository = ExchangeRepository();

  ExchangeStatus _status = ExchangeStatus.initial;
  ExchangeRate? _currentRate;
  ExchangeRate? _previousRate;
  String _errorMessage = '';

  ExchangeStatus get status => _status;
  ExchangeRate? get currentRate => _currentRate;
  ExchangeRate? get previousRate => _previousRate;
  String get errorMessage => _errorMessage;
  List<ExchangeRate> _history = [];
  List<ExchangeRate> get history => _history;

  bool? get copTrend => trendFor('COP');

  bool? trendFor(String code) {
    if (_currentRate == null || _previousRate == null) return null;
    return _currentRate!.rateFor(code) > _previousRate!.rateFor(code);
  }

  Future<void> loadRate({required String base}) async {
    final cached = await _repository.getCachedRate(base);
    if (cached != null) {
      _previousRate = _currentRate;
      _currentRate = cached;
      _status = ExchangeStatus.success;
      notifyListeners();
    } else {
      _status = ExchangeStatus.loading;
      notifyListeners();
    }

    try {
      final fresh = await _repository.fetchLatestRate(base);
      _previousRate = _currentRate;
      _currentRate = fresh;
      _status = ExchangeStatus.success;
      await _repository.saveToHistory(fresh);
      await loadHistory();
    } catch (e) {
      if (_currentRate == null) {
        _status = ExchangeStatus.error;
        _errorMessage =
            'Sin conexión y sin datos guardados.\nIntenta más tarde.';
      }
    }

    notifyListeners();
  }

  Future<void> refresh({required String base}) async {
    _status = ExchangeStatus.loading;
    notifyListeners();
    await loadRate(base: base);
  }

  Future<void> loadHistory() async {
    _history = await _repository.loadHistory();
    notifyListeners();
  }
}
