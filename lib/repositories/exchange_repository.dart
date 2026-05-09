import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/exchange_rate.dart';

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

  // Guarda la tasa en SharedPreferences
  Future<void> _saveToCache(ExchangeRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(rate.toJson());
    await prefs.setString(_cacheKey, jsonString);
  }

  // Lee la tasa guardada — retorna null si no hay o si expiró
  Future<ExchangeRate?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString == null) return null;

    final rate = ExchangeRate.fromCache(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );

    // Si el caché tiene más de 1 hora, lo ignoramos
    final age = DateTime.now().difference(rate.fetchedAt);
    if (age > _cacheValidity) return null;

    return rate;
  }
}