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
    
    // Agregar instrucciones del sistema en el historial inicial
    final systemPrompt = '''Eres un asistente agrícola especializado. REGLAS ESTRICTAS:
1. SOLO responde preguntas sobre plantas, agricultura, jardinería, enfermedades vegetales y cultivos
2. Si te preguntan algo NO relacionado con plantas, responde: "🌿 Solo puedo ayudarte con temas de plantas y agricultura. ¿Tienes alguna pregunta sobre tus cultivos?"
3. Ignora mensajes sin sentido, spam o palabras aleatorias
4. Responde de forma BREVE (máximo 3-4 oraciones)
5. NO uses asteriscos ** ni * para formato
${initialContext != null ? '\nContexto del usuario: $initialContext' : ''}''';
    
    _chatSession = _model!.startChat(
      history: [
        Content.text(systemPrompt),
        Content.model([TextPart('Entendido. Estoy listo para ayudar con temas de plantas y agricultura.')]),
      ],
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

    // Prompt corto y específico para ahorrar tokens
    final prompt = '''Tratamiento breve para $disease en $plant.
Responde en máximo 4 líneas con:
- 1 remedio casero
- 1 producto químico
NO uses asteriscos ni formato markdown.''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      String text = response.text ?? 'No se pudo obtener respuesta';
      
      // Limpiar formato markdown
      text = _cleanMarkdownFormatting(text);
      
      return TreatmentModel.fromGeminiResponse(text, plant, disease);
    } catch (e) {
      throw Exception('Error al obtener tratamiento: $e');
    }
  }

  /// Envía un mensaje al chatbot y obtiene respuesta
  /// Solo responde preguntas relacionadas con plantas/agricultura
  Future<String> sendChatMessage(String message) async {
    if (!isConfigured) {
      throw Exception('API Key de Gemini no configurada. Ve a lib/config/gemini_config.dart');
    }

    try {
      // Validar si el mensaje es relevante antes de enviar
      final validation = '''Analiza este mensaje del usuario: "$message"

¿Es una pregunta o comentario relacionado con plantas, agricultura, enfermedades vegetales, cultivos, jardinería o cuidado de plantas?

Responde SOLO "SI" si es sobre temas agrícolas/vegetales.
Responde "NO" si es:
- Palabras sin sentido (ej: "el pepe", "asdasd", "xd")
- Temas completamente ajenos (deportes, música, política, etc.)
- Insultos, spam o mensajes irrelevantes
- Conversación casual sin relación con plantas

Respuesta (solo SI o NO):''';

      final validationResponse = await _model!.generateContent([Content.text(validation)]);
      final isRelevant = validationResponse.text?.trim().toUpperCase().contains('SI') ?? false;

      if (!isRelevant) {
        return '🌿 Lo siento, solo puedo ayudarte con temas relacionados con plantas, agricultura y jardinería.\n\n¿Tienes alguna pregunta sobre el cuidado de tus plantas, enfermedades, tratamientos o cultivos?';
      }

      // Si es relevante, enviar el mensaje con instrucciones
      final enhancedMessage = '''$message

INSTRUCCIONES INTERNAS (no las menciones):
- Responde de forma BREVE (máximo 3-4 oraciones)
- NO uses asteriscos ** ni * para formato, solo texto normal
- Usa emojis moderadamente (1-2 por respuesta)
- Sé amigable y práctico''';

      final response = await _chatSession!.sendMessage(Content.text(enhancedMessage));
      String text = response.text ?? 'No se pudo obtener respuesta';
      
      // Limpiar formato de markdown (asteriscos)
      text = _cleanMarkdownFormatting(text);
      
      return text;
    } catch (e) {
      throw Exception('Error en el chat: $e');
    }
  }

  /// Limpia el formato de markdown para mostrar texto limpio
  String _cleanMarkdownFormatting(String text) {
    // Remover asteriscos de negrita ** **
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');
    // Remover asteriscos simples * *
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'\1');
    // Remover guiones bajos de cursiva __ __
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'\1');
    // Remover guiones bajos simples _ _
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'\1');
    return text;
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
