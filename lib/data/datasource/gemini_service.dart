// Servicio Gemini AI - Agregado: 13-14 Enero 2026
// Proporciona recomendaciones de tratamiento y chatbot agrícola
// Usa patrón Singleton para optimizar cuota de API gratuita

import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/gemini_config.dart';
import '../models/treatment_model.dart';

/// Servicio para comunicarse con la API de Gemini
/// 
/// Implementa el patrón Singleton para garantizar una única instancia
/// del modelo Gemini en toda la aplicación, evitando múltiples conexiones
/// que consumen la cuota de la API gratuita.
class GeminiService {
  // ===== PATRÓN SINGLETON =====
  static final GeminiService _instance = GeminiService._internal();
  
  /// Factory constructor que siempre retorna la misma instancia
  factory GeminiService() => _instance;
  
  /// Constructor privado interno
  GeminiService._internal();
  // ============================
  
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  bool _initializationAttempted = false;
  bool _isChatActive = false;

  /// Inicializa el modelo (debe llamarse antes de usar)
  /// SIN systemInstruction para ahorrar tokens en cada solicitud
  Future<void> initialize() async {
    if (_initializationAttempted) return;
    _initializationAttempted = true;
    
    try {
      final apiKey = await GeminiConfig.loadApiKey();
      
      // Sin systemInstruction = menos tokens por solicitud
      _model = GenerativeModel(
        model: GeminiConfig.model,
        apiKey: apiKey,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  bool get isConfigured => _isInitialized;

  /// Verifica si hay una sesión de chat activa
  bool get isChatActive => _isChatActive;

  /// Inicia una nueva sesión de chat
  void startNewChat({String? initialContext}) {
    if (!isConfigured) return;
    
    // Solo crear nueva sesión si no hay una activa
    if (_isChatActive) {
      return;
    }
    
    _chatSession = _model!.startChat(
      history: initialContext != null
          ? [Content.text('Contexto: $initialContext')]
          : [],
    );
    _isChatActive = true;
  }

  /// Finaliza la sesión de chat actual
  void endChat() {
    _chatSession = null;
    _isChatActive = false;
  }

  /// Obtiene recomendaciones de tratamiento para una enfermedad
  Future<TreatmentModel> getTreatmentRecommendation({
    required String plant,
    required String disease,
  }) async {
    if (!isConfigured) {
      throw Exception('API Key de Gemini no configurada. Ve a lib/config/gemini_config.dart');
    }

    // Prompt simplificado para consumir menos tokens de la cuota gratuita
    final prompt = 'Tratamiento breve para $disease en $plant. Incluye: 1 remedio casero y 1 químico.';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? 'No se pudo obtener respuesta';
      
      return TreatmentModel.fromGeminiResponse(text, plant, disease);
    } catch (e) {
      throw Exception('Error al obtener tratamiento: $e');
    }
  }

  /// Envía un mensaje al chatbot y obtiene respuesta
  Future<String> sendChatMessage(String message) async {
    if (!isConfigured) {
      throw Exception('API Key de Gemini no configurada. Ve a lib/config/gemini_config.dart');
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'No se pudo obtener respuesta';
    } catch (e) {
      throw Exception('Error en el chat: $e');
    }
  }

  /// Genera una respuesta única sin historial de chat
  Future<String> generateResponse(String prompt) async {
    if (!isConfigured) {
      throw Exception('API Key de Gemini no configurada');
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'No se pudo obtener respuesta';
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Valida si una imagen contiene una hoja de planta usando Gemini Vision
  /// Retorna true si es una planta, false si no lo es
  Future<bool> validatePlantImage(Uint8List imageBytes) async {
    if (!isConfigured) {
      // Si Gemini no está configurado, permitir clasificación (modo offline)
      return true;
    }

    try {
      final prompt = '''Analiza esta imagen y responde SOLO con "SI" o "NO":
¿Esta imagen muestra una hoja de planta o una planta que pueda tener una enfermedad vegetal?

Responde "SI" si ves:
- Una hoja de planta (de cualquier tipo)
- Una planta completa o parte de ella
- Vegetación que pueda ser analizada para enfermedades

Responde "NO" si ves:
- Personas, animales, objetos
- Paisajes sin plantas en primer plano
- Comida procesada, edificios, vehículos
- Cualquier cosa que NO sea una planta o hoja

Respuesta (solo SI o NO):''';

      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final text = response.text?.trim().toUpperCase() ?? '';
      
      // Verificar si la respuesta contiene "SI" o "SÍ"
      return text.contains('SI') || text.contains('SÍ') || text.startsWith('S');
    } catch (e) {
      print('⚠️ Error validando imagen con Gemini: $e');
      // En caso de error, permitir clasificación para no bloquear
      return true;
    }
  }
}
