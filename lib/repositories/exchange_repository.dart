import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/exchange_rate.dart';
import '../models/currency_info.dart';

class ExchangeRepository {
  static const String _cacheKey = 'cached_exchange_rate';
  static const Duration _cacheValidity = Duration(hours: 1);

  // Obtiene la tasa actual — primero intenta la API, si falla usa caché
  Future<ExchangeRate> fetchLatestRate() async {
    try {
      final rate = await _fetchFromApi();
      await _saveToCache(rate);
      return rate;
    } catch (e) {
      final cached = await _loadFromCache();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // Carga la tasa guardada localmente (puede ser null si nunca se ha consultado)
  Future<ExchangeRate?> getCachedRate() async {
    return _loadFromCache();
  }

  // Llama a la API de ExchangeRate-API
  Future<ExchangeRate> _fetchFromApi() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/${ApiConfig.exchangeRateApiKey}/latest/USD',
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

  // Trae la lista completa de monedas soportadas por la API
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

  // Guarda la tasa en SharedPreferences
  Future<void> _saveToCache(ExchangeRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(rate.toJson());
    await prefs.setString(_cacheKey, jsonString);
  }

  // Lee la tasa guardada — retorna null si no hay, si expiró,
  // o si quedó en el formato viejo (antes de rates como mapa)
  Future<ExchangeRate?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString == null) return null;

    try {
      final rate = ExchangeRate.fromCache(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      // Si el caché tiene más de 1 hora, lo ignoramos
      final age = DateTime.now().difference(rate.fetchedAt);
      if (age > _cacheValidity) return null;

      return rate;
    } catch (e) {
      // Caché en formato antiguo (esquema copRate/eurRate/usdRate) —
      // se ignora y se pide dato fresco a la API. Ver nota de migración
      // en README: limpiar manualmente en una ronda posterior.
      return null;
    }
  }

  // Guarda una tasa en el historial (máximo 10 entradas)
  Future<void> saveToHistory(ExchangeRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    // Evitar duplicados del mismo día
    final alreadySaved = history.any(
      (r) =>
          r.fetchedAt.day == rate.fetchedAt.day &&
          r.fetchedAt.month == rate.fetchedAt.month &&
          r.fetchedAt.year == rate.fetchedAt.year,
    );

    if (alreadySaved) return;

    history.insert(0, rate); // más reciente primero

    final trimmed = history.take(10).toList(); // máximo 10 entradas

    final jsonList = trimmed.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('exchange_history', jsonList);
  }

  // Carga el historial completo
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
        // Entrada de historial en formato antiguo — se omite
        continue;
      }
    }
    return result;
  }
}
