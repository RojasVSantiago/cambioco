import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/exchange_rate.dart';
import '../models/currency_info.dart';

class ExchangeRepository {
  static const String _cacheKeyPrefix = 'cached_exchange_rate_';
  static const Duration _cacheValidity = Duration(hours: 1);

  Future<ExchangeRate> fetchLatestRate(String base) async {
    try {
      final rate = await _fetchFromApi(base);
      await _saveToCache(rate);
      return rate;
    } catch (e) {
      final cached = await _loadFromCache(base);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<ExchangeRate?> getCachedRate(String base) async {
    return _loadFromCache(base);
  }

  Future<ExchangeRate> _fetchFromApi(String base) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/${ApiConfig.exchangeRateApiKey}/latest/$base',
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['result'] != 'success') {
        throw Exception('Error de API: ${json['error-type']}');
      }

      return ExchangeRate.fromJson(json);
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  Future<List<CurrencyInfo>> fetchSupportedCurrencies() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/${ApiConfig.exchangeRateApiKey}/codes',
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['result'] != 'success') {
        throw Exception('Error de API: ${json['error-type']}');
      }

      final codes = json['supported_codes'] as List<dynamic>;
      return codes
          .map((pair) => CurrencyInfo.fromJson(pair as List<dynamic>))
          .toList();
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  String _cacheKeyFor(String base) => '$_cacheKeyPrefix$base';

  // El caché se guarda por base — consultar con base USD y con base CAD
  // no deben pisarse entre sí.
  Future<void> _saveToCache(ExchangeRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(rate.toJson());
    await prefs.setString(_cacheKeyFor(rate.baseCurrency), jsonString);
  }

  Future<ExchangeRate?> _loadFromCache(String base) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKeyFor(base));

    if (jsonString == null) return null;

    try {
      final rate = ExchangeRate.fromCache(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      final age = DateTime.now().difference(rate.fetchedAt);
      if (age > _cacheValidity) return null;

      return rate;
    } catch (e) {
      // Caché en formato antiguo (esquema previo a rates como mapa) —
      // se ignora y se pide dato fresco a la API.
      return null;
    }
  }

  // Guarda una tasa en el historial (máximo 10 entradas por base)
  Future<void> saveToHistory(ExchangeRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    // Evitar duplicados del mismo día Y de la misma base — cambiar de
    // base no debe bloquear guardar una entrada nueva ese mismo día.
    final alreadySaved = history.any(
      (r) =>
          r.fetchedAt.day == rate.fetchedAt.day &&
          r.fetchedAt.month == rate.fetchedAt.month &&
          r.fetchedAt.year == rate.fetchedAt.year &&
          r.baseCurrency == rate.baseCurrency,
    );

    if (alreadySaved) return;

    history.insert(0, rate);

    final trimmed = history.take(10).toList();

    final jsonList = trimmed.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('exchange_history', jsonList);
  }

  Future<List<ExchangeRate>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('exchange_history') ?? [];

    final result = <ExchangeRate>[];
    for (final jsonString in jsonList) {
      try {
        result.add(ExchangeRate.fromCache(
          jsonDecode(jsonString) as Map<String, dynamic>,
        ));
      } catch (e) {
        continue;
      }
    }
    return result;
  }
}
