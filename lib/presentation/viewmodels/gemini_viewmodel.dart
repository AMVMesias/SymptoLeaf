import 'package:flutter/foundation.dart';
import '../../data/datasource/gemini_service.dart';
import '../../data/models/treatment_model.dart';
import '../../data/models/chat_message_model.dart';

enum GeminiState { idle, loading, success, error }

/// ViewModel para manejar las funcionalidades de Gemini
class GeminiViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  bool _isInitialized = false;
  bool _initializationFailed = false;
  String _initError = '';
  
  // Estado del tratamiento
  GeminiState _treatmentState = GeminiState.idle;
  TreatmentModel? _treatment;
  String _treatmentError = '';
  String _rawTreatmentResponse = '';
  
  // Estado del chat
  GeminiState _chatState = GeminiState.idle;
  final List<ChatMessage> _messages = [];
  String _chatError = '';
  String? _currentDiagnosisContext;
  bool _chatStarted = false;

  // Getters para tratamiento
  GeminiState get treatmentState => _treatmentState;
  TreatmentModel? get treatment => _treatment;
  String get treatmentError => _treatmentError;
  String get rawTreatmentResponse => _rawTreatmentResponse;
  bool get hasTreatment => _treatment != null;

  // Getters para chat
  GeminiState get chatState => _chatState;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String get chatError => _chatError;
  bool get isConfigured => _isInitialized && _geminiService.isConfigured;
  bool get initializationFailed => _initializationFailed;
  String get initError => _initError;

  /// Inicializa el servicio de Gemini
  Future<void> initialize() async {
    if (_isInitialized || _initializationFailed) return;
    
    try {
      await _geminiService.initialize();
      _isInitialized = true;
      _initializationFailed = false;
    } catch (e) {
      _initializationFailed = true;
      _initError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  /// Obtiene recomendaciones de tratamiento
  Future<void> getTreatment({
    required String plant,
    required String disease,
  }) async {
    // Inicializar si es necesario
    if (!_isInitialized && !_initializationFailed) {
      await initialize();
    }
    
    if (!isConfigured) {
      _treatmentError = _initError.isNotEmpty ? _initError : 'Servicio no configurado';
      _treatmentState = GeminiState.error;
      notifyListeners();
      return;
    }
    
    _treatmentState = GeminiState.loading;
    _treatmentError = '';
    notifyListeners();

    try {
      _treatment = await _geminiService.getTreatmentRecommendation(
        plant: plant,
        disease: disease,
      );
      _rawTreatmentResponse = _treatment!.additionalInfo;
      _treatmentState = GeminiState.success;
    } catch (e) {
      _treatmentError = e.toString().replaceAll('Exception: ', '');
      _treatmentState = GeminiState.error;
    }
    notifyListeners();
  }

  /// Inicia el chat con contexto del diagnóstico
  Future<void> startChat({String? plant, String? disease}) async {
    // Evitar iniciar el chat múltiples veces
    if (_chatStarted && _geminiService.isChatActive) {
      return;
    }
    
    _messages.clear();
    _chatError = '';
    _chatStarted = false;
    
    // Inicializar si es necesario
    if (!_isInitialized && !_initializationFailed) {
      await initialize();
    }
    
    if (plant != null && disease != null) {
      _currentDiagnosisContext = 'El usuario tiene una planta de $plant con $disease detectada.';
      _geminiService.startNewChat(initialContext: _currentDiagnosisContext);
      
      // Mensaje de bienvenida
      _messages.add(ChatMessage.assistant(
        '¡Hola! 👋 Soy tu Asistente Agrícola.\n\n'
        'Veo que tu **$plant** tiene **$disease**. '
        '¿En qué puedo ayudarte? Puedes preguntarme sobre:\n\n'
        '• 💊 Tratamientos y remedios\n'
        '• 🛡️ Prevención\n'
        '• 🌱 Cuidados generales\n'
        '• 📅 Calendario de aplicación'
      ));
    } else {
      _geminiService.startNewChat();
      _messages.add(ChatMessage.assistant(
        '¡Hola! 👋 Soy tu Asistente Agrícola.\n\n'
        '¿En qué puedo ayudarte hoy? Puedo resolver dudas sobre:\n\n'
        '• 🌿 Enfermedades de plantas\n'
        '• 💊 Tratamientos\n'
        '• 🌱 Consejos de cultivo'
      ));
    }
    
    _chatStarted = true;
    notifyListeners();
  }

  /// Envía un mensaje al chatbot
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Agregar mensaje del usuario
    _messages.add(ChatMessage.user(message));
    
    // Agregar placeholder de "escribiendo..."
    _messages.add(ChatMessage.loading());
    _chatState = GeminiState.loading;
    notifyListeners();

    try {
      final response = await _geminiService.sendChatMessage(message);
      
      // Remover placeholder y agregar respuesta real
      _messages.removeLast();
      _messages.add(ChatMessage.assistant(response));
      _chatState = GeminiState.success;
    } catch (e) {
      _messages.removeLast();
      _chatError = e.toString().replaceAll('Exception: ', '');
      _messages.add(ChatMessage.assistant(
        '❌ Lo siento, hubo un error al procesar tu mensaje. '
        'Por favor verifica tu conexión a internet e intenta de nuevo.'
      ));
      _chatState = GeminiState.error;
    }
    notifyListeners();
  }

  /// Limpia el chat
  void clearChat() {
    _messages.clear();
    _chatState = GeminiState.idle;
    _chatError = '';
    _chatStarted = false;
    _geminiService.endChat();
    notifyListeners();
  }

  /// Limpia el tratamiento
  void clearTreatment() {
    _treatment = null;
    _rawTreatmentResponse = '';
    _treatmentState = GeminiState.idle;
    _treatmentError = '';
    notifyListeners();
  }

  /// Reinicia todo
  void reset() {
    clearChat();
    clearTreatment();
  }
}
