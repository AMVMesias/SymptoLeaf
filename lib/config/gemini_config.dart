import 'package:flutter/services.dart';

/// Configuración para la API de Gemini
/// 
/// La API Key se carga desde el archivo oculto .keyapigemeni
/// para evitar subirla accidentalmente al repositorio
class GeminiConfig {
  static String? _apiKey;
  
  static const String model = 'gemini-2.5-flash';

  /// Carga la API Key desde el archivo oculto
  static Future<String> loadApiKey() async {
    if (_apiKey != null) return _apiKey!;
    
    try {
      _apiKey = await rootBundle.loadString('lib/.keyapigemeni');
      _apiKey = _apiKey!.trim();
      return _apiKey!;
    } catch (e) {
      throw Exception('No se pudo cargar la API Key. Asegúrate de crear el archivo lib/.keyapigemeni');
    }
  }
  
  /// Obtiene la API Key (debe llamarse loadApiKey primero)
  static String get apiKey => _apiKey ?? 'NO_KEY_LOADED';
}
