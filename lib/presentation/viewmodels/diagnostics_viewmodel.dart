import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../data/datasource/diagnostics_datasource.dart';

enum DiagnosticsState { idle, loading, success, error }

/// ViewModel para manejar el historial de diagnósticos
class DiagnosticsViewModel extends ChangeNotifier {
  final DiagnosticsDatasource _datasource = DiagnosticsDatasource();

  DiagnosticsState _state = DiagnosticsState.idle;
  List<DiagnosticModel> _diagnostics = [];
  String _errorMessage = '';
  String? _lastSavedId; // ID del último diagnóstico guardado
  String? _lastSavedKey;
  bool _isLoading = false;

  DiagnosticsState get state => _state;
  List<DiagnosticModel> get diagnostics => List.unmodifiable(_diagnostics);
  String get errorMessage => _errorMessage;
  bool get hasDiagnostics => _diagnostics.isNotEmpty;
  String? get lastSavedId => _lastSavedId;
  String? get lastSavedKey => _lastSavedKey;
  bool get isLoading => _isLoading;

  /// Cargar historial de diagnósticos
  Future<void> loadDiagnostics() async {
    _state = DiagnosticsState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _diagnostics = await _datasource.getDiagnostics();
      _state = DiagnosticsState.success;
    } catch (e) {
      _errorMessage = 'Error al cargar historial: $e';
      _state = DiagnosticsState.error;
    }
    notifyListeners();
  }

  /// Guardar un nuevo diagnóstico con imagen
  Future<DiagnosticModel?> saveDiagnostic({
    required String userId,
    required String plantName,
    required String diseaseName,
    double? confidence,
    String? treatment,
    Uint8List? imageBytes,
    String? savedKey,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageBase64;

      // Para evitar que la app se trabe o se cierre (ANR / OOM) al procesar fotos
      // de alta resolución (4K/8K) con el paquete 'image' en Dart pura, vamos a
      // intentar hacer un procesado ultraligero solo si la foto no es excesivamente pesada,
      // o directamente omitir la imagen si es problemática.
      if (imageBytes != null && imageBytes.lengthInBytes < 3000000) {
        // Si es menor a 3MB
        try {
          final compressedBytes = await compute(_compressImage, imageBytes);
          if (compressedBytes.isNotEmpty) {
            imageBase64 = base64Encode(compressedBytes);
          }
        } catch (e) {
          print('No se pudo comprimir la imagen: $e');
        }
      } else if (imageBytes != null) {
        print(
          'Imagen demasiado grande para el procesador local, omitiendo miniatura para evitar cierre de la app (peso: ${imageBytes.lengthInBytes} bytes).',
        );
      }

      final diagnostic = DiagnosticModel(
        userId: userId,
        plantName: plantName,
        diseaseName: diseaseName,
        confidence: confidence,
        treatment: treatment,
        imageBase64: imageBase64,
      );

      final saved = await _datasource.saveDiagnostic(diagnostic);

      if (saved != null) {
        _lastSavedId = saved.id;
        _lastSavedKey = savedKey;
        // Recargar la lista
        await loadDiagnostics();
      }

      _isLoading = false;
      notifyListeners();
      return saved;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error saving diagnostic: $e');
      rethrow;
    }
  }

  /// Eliminar un diagnóstico
  Future<bool> deleteDiagnostic(String id) async {
    try {
      final deleted = await _datasource.deleteDiagnostic(id);
      if (deleted) {
        _diagnostics.removeWhere((d) => d.id == id);
        notifyListeners();
      }
      return deleted;
    } catch (e) {
      print('Error deleting diagnostic: $e');
      return false;
    }
  }

  /// Guardar historial de chat
  Future<bool> saveChatHistory({
    required String userId,
    String? diagnosticId,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final chatMessages = messages
          .map(
            (m) => ChatMessageModel(
              content: m['content'] ?? '',
              isUser: m['isUser'] ?? false,
              timestamp: m['timestamp'],
            ),
          )
          .toList();

      return await _datasource.saveChatHistory(
        userId: userId,
        diagnosticId: diagnosticId,
        messages: chatMessages,
      );
    } catch (e) {
      print('Error saving chat history: $e');
      return false;
    }
  }

  /// Obtener historial de chat de un diagnóstico
  Future<List<ChatMessageModel>> getChatHistory(String diagnosticId) async {
    try {
      return await _datasource.getChatHistory(diagnosticId);
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }

  /// Limpiar datos
  void clear() {
    _diagnostics = [];
    _state = DiagnosticsState.idle;
    _errorMessage = '';
    _lastSavedId = null;
    _lastSavedKey = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// Función de nivel superior para ejecutarse en isolate (compute)
Uint8List _compressImage(Uint8List imageBytes) {
  try {
    // Convertir bytes a imagen
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Redimensionar para reducir drásticamente el tamaño final (thumbnail pequeño)
    final resized = img.copyResize(image, width: 250);

    // Comprimir a JPEG con baja calidad para garantizar el guardado en Firebase (máx 1MB)
    final compressed = img.encodeJpg(resized, quality: 40);
    return Uint8List.fromList(compressed);
  } catch (e) {
    print('Error crítico durante compresión en hilo secundario: $e');
    return Uint8List(0); // Devolver nada para evitar crashear la base de datos
  }
}
