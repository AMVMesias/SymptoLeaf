// Servicio de validación de plantas - Agregado: 15 Enero 2026
// Usa Google ML Kit Image Labeling para detectar si una imagen contiene una planta
// Funciona 100% OFFLINE - no requiere internet

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Servicio para validar si una imagen contiene una planta/hoja
/// Usa ML Kit Image Labeling que funciona offline
class PlantValidatorService {
  // Singleton pattern
  static final PlantValidatorService _instance = PlantValidatorService._internal();
  factory PlantValidatorService() => _instance;
  PlantValidatorService._internal();

  ImageLabeler? _imageLabeler;
  bool _isInitialized = false;

  /// Etiquetas que indican que la imagen contiene una planta
  /// ML Kit puede detectar estas categorías
  static const List<String> plantLabels = [
    'plant',
    'leaf',
    'flower',
    'tree',
    'grass',
    'vegetation',
    'houseplant',
    'herb',
    'shrub',
    'fern',
    'moss',
    'algae',
    'flora',
    'foliage',
    'greenery',
    'garden',
    'botanical',
    'crop',
    'seedling',
    'sprout',
    'branch',
    'stem',
    'petal',
    'blossom',
    'bud',
    'fruit',
    'vegetable',
    'tomato',
    'potato',
    'corn',
    'grape',
    'apple',
    'strawberry',
    'pepper',
    'orange',
    'cherry',
    'peach',
    'squash',
    'raspberry',
    'blueberry',
    // Broad biological categories often returned for sick/close-up leaves
    'organism',
    'biology',
    'living thing',
    'terrestrial plant',
    'aquatic plant',
    'vascular plant',
    // Disease/Pest related terms
    'fungus',
    'fungi',
    'mold',
    'mildew',
    'rot',
    'rust',
    'spot',
    'blight',
    'patology',
    'pathology',
    'parasite',
    'pest',
    'insect',
    'arthropod',
    'invertebrate',
    'food', // Sometime sick fruits are just labeled as food
    'produce',
    'ingredient',
  ];

  /// Inicializa el servicio de ML Kit
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = ImageLabelerOptions(confidenceThreshold: 0.4);
      _imageLabeler = ImageLabeler(options: options);
      _isInitialized = true;
      print('✅ ML Kit Image Labeler inicializado');
    } catch (e) {
      print('❌ Error inicializando ML Kit: $e');
      rethrow;
    }
  }

  /// Valida si la imagen contiene una planta
  /// Retorna true si detecta una planta, false si no
  Future<bool> isPlantImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('🔍 Analizando imagen con ML Kit...');
      
      // Crear InputImage desde el path
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Procesar imagen
      final labels = await _imageLabeler!.processImage(inputImage);
      
      // Buscar etiquetas relacionadas con plantas
      for (final label in labels) {
        final labelText = label.label.toLowerCase();
        print('   📌 Etiqueta: ${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)');
        
        // Verificar si alguna etiqueta coincide con plantas
        for (final plantLabel in plantLabels) {
          if (labelText.contains(plantLabel)) {
            print('✅ Detectado como planta: ${label.label}');
            return true;
          }
        }
      }
      
      // No se encontraron etiquetas de plantas
      print('❌ No se detectó ninguna planta en la imagen');
      return false;
    } catch (e) {
      print('⚠️ Error en ML Kit: $e');
      // En caso de error, permitir clasificación para no bloquear
      return true;
    }
  }

  /// Obtiene todas las etiquetas detectadas en la imagen
  Future<List<String>> getImageLabels(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await _imageLabeler!.processImage(inputImage);
      
      return labels.map((l) => '${l.label} (${(l.confidence * 100).toStringAsFixed(0)}%)').toList();
    } catch (e) {
      print('Error obteniendo etiquetas: $e');
      return [];
    }
  }

  /// Libera recursos
  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
    _isInitialized = false;
  }
}
