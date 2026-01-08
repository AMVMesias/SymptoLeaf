import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'base_datasource.dart';
import '../models/prediction_model.dart';

class ApiDataSource implements BaseDataSource {
  final String baseUrl;

  ApiDataSource(this.baseUrl);

  @override
  Future<PredictionModel> predictDisease(String imagePath) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      final request = http.MultipartRequest('POST', url);
      
      // Adjuntar imagen
      final file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Error al predecir: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      
      if (data['success'] != true) {
        throw Exception('Error en la predicción: ${data['error']}');
      }

      return PredictionModel.fromJson(data);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }
}
