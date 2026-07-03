import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/prediction_viewmodel.dart';
import '../../viewmodels/gemini_viewmodel.dart';
import '../../viewmodels/diagnostics_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/gradient_container.dart';
import '../organisms/state_views.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Análisis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PredictionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == PredictionState.loading) {
            return _buildLoading();
          } else if (viewModel.state == PredictionState.error) {
            return _buildError(context, viewModel.errorMessage);
          } else if (viewModel.state == PredictionState.success &&
              viewModel.prediction != null) {
            return _buildSuccess(context, viewModel);
          } else {
            return _buildInitial(context);
          }
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const GradientContainer(
      child: LoadingStateView(
        message: 'Analizando imagen...',
        submessage: 'Esto puede tomar unos segundos',
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return GradientContainer(
      child: ErrorStateView(
        title: 'Error en el Análisis',
        message: error,
        onRetry: () => Navigator.of(context).pop(),
        retryText: 'Volver',
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, PredictionViewModel viewModel) {
    final prediction = viewModel.prediction!;

    // ⭐ CASO ESPECIAL: No es una planta
    if (prediction.className == 'no_plant_detected') {
      return _buildNotPlantDetected(context, viewModel);
    }

    final isHealthy = prediction.isHealthy;

    return Container(
      decoration: const BoxDecoration(
        gradient: EsquemaColor.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Estado de salud
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHealthy
                    ? EsquemaColor.healthyGreen
                    : EsquemaColor.diseaseRed,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isHealthy
                                ? EsquemaColor.healthyGreen
                                : EsquemaColor.diseaseRed)
                            .withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHealthy
                              ? 'Planta Saludable'
                              : 'Enfermedad Detectada',
                          style: Tipografia.titulo3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(prediction.confidence * 100).toStringAsFixed(1)}% de confianza',
                          style: Tipografia.subtitulo.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detalles de la predicción
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Detección',
                      style: Tipografia.titulo3.copyWith(
                        color: EsquemaColor.darkGreen,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow('Planta:', prediction.plant),
                    const SizedBox(height: 12),
                    _buildDetailRow('Condición:', prediction.disease),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Confianza:',
                      '${(prediction.confidence * 100).toStringAsFixed(2)}%',
                    ),
                    // Mostrar método ganador si está disponible
                    if (prediction.bestMethod != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        '🏆 Mejor método:',
                        prediction.bestMethod!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Top 3 predicciones
            if (prediction.top3.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Otras Posibilidades',
                        style: Tipografia.titulo3.copyWith(
                          color: EsquemaColor.darkGreen,
                        ),
                      ),
                      const Divider(height: 24),
                      ...prediction.top3.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: EsquemaColor.lightGreen,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.plant} - ${item.disease}',
                                      style: Tipografia.subtitulo,
                                    ),
                                    Text(
                                      '${(item.confidence * 100).toStringAsFixed(1)}%',
                                      style: Tipografia.caption.copyWith(
                                        color: EsquemaColor.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Sección de IA - Tratamiento y Chatbot
            _buildAISection(context, prediction.plant, prediction.disease),
            const SizedBox(height: 24),

            // Botón para guardar diagnóstico
            _buildSaveDiagnosticButton(context, viewModel, prediction),
            const SizedBox(height: 16),

            // Botón para otra foto - vuelve a la pantalla anterior
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  viewModel.reset();
                  Provider.of<GeminiViewModel>(context, listen: false).reset();
                  Provider.of<DiagnosticsViewModel>(
                    context,
                    listen: false,
                  ).clear();
                  Navigator.of(context).pop(); // Volver a main (tab fotos)
                },
                icon: const Icon(Icons.camera_alt),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Analizar Otra Planta',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Tipografia.subtitulo.copyWith(
              color: EsquemaColor.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Tipografia.subtitulo.copyWith(
              fontWeight: FontWeight.bold,
              color: EsquemaColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: EsquemaColor.backgroundGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 80,
              color: EsquemaColor.primaryGreen,
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay resultados disponibles',
              style: Tipografia.titulo3,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar cuando NO se detecta una planta en la imagen
  Widget _buildNotPlantDetected(
    BuildContext context,
    PredictionViewModel viewModel,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: EsquemaColor.backgroundGradient,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono grande
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.nature_outlined,
                  size: 80,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),

              // Título
              Text(
                'No es una planta',
                style: Tipografia.titulo2.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                'La imagen no parece contener una hoja o planta que pueda ser analizada para detectar enfermedades.',
                style: Tipografia.cuerpo.copyWith(
                  color: EsquemaColor.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Sugerencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EsquemaColor.lightGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: EsquemaColor.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Por favor, toma una foto de una hoja de planta con buena iluminación.',
                        style: Tipografia.caption.copyWith(
                          color: EsquemaColor.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botón para otra foto - vuelve a la pantalla anterior (Main con tab de fotos)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    viewModel.reset();
                    Navigator.of(context).pop(); // Volver a main (tab fotos)
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Tomar Otra Foto',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAISection(BuildContext context, String plant, String disease) {
    return Consumer<GeminiViewModel>(
      builder: (context, geminiViewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.smart_toy,
                      color: EsquemaColor.primaryGreen,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Asistente IA',
                      style: Tipografia.titulo3.copyWith(
                        color: EsquemaColor.darkGreen,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Mostrar tratamiento si está disponible
                if (geminiViewModel.treatmentState == GeminiState.success &&
                    geminiViewModel.rawTreatmentResponse.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: EsquemaColor.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_services,
                              color: EsquemaColor.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tratamiento Recomendado',
                              style: Tipografia.subtitulo.copyWith(
                                fontWeight: FontWeight.bold,
                                color: EsquemaColor.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          geminiViewModel.rawTreatmentResponse,
                          style: Tipografia.cuerpo.copyWith(
                            color: EsquemaColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón para obtener tratamiento
                if (geminiViewModel.treatmentState != GeminiState.success) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          geminiViewModel.treatmentState == GeminiState.loading
                          ? null
                          : () {
                              geminiViewModel.getTreatment(
                                plant: plant,
                                disease: disease,
                              );
                            },
                      icon:
                          geminiViewModel.treatmentState == GeminiState.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.medical_services),
                      label: Text(
                        geminiViewModel.treatmentState == GeminiState.loading
                            ? 'Obteniendo recomendaciones...'
                            : '💊 Obtener Tratamiento',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: EsquemaColor.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Error de tratamiento
                if (geminiViewModel.treatmentState == GeminiState.error) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EsquemaColor.diseaseRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: EsquemaColor.diseaseRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            geminiViewModel.treatmentError,
                            style: Tipografia.caption.copyWith(
                              color: EsquemaColor.diseaseRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Botón del chatbot
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chat,
                        arguments: {'plant': plant, 'disease': disease},
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('🤖 Consultar al Asistente'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: EsquemaColor.darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveDiagnosticButton(
    BuildContext context,
    PredictionViewModel predictionViewModel,
    dynamic prediction,
  ) {
    return Consumer<DiagnosticsViewModel>(
      builder: (context, diagnosticsVm, child) {
        final authViewModel = Provider.of<AuthViewModel>(
          context,
          listen: false,
        );
        final currentSaveKey = _buildSaveKey(predictionViewModel, prediction);

        // Si ya se guardó, mostrar indicador
        if (diagnosticsVm.lastSavedId != null &&
            diagnosticsVm.lastSavedKey == currentSaveKey) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EsquemaColor.healthyGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EsquemaColor.healthyGreen),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: EsquemaColor.healthyGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Diagnóstico guardado',
                  style: Tipografia.subtitulo.copyWith(
                    color: EsquemaColor.healthyGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: diagnosticsVm.isLoading
                ? null
                : () async {
                    final imagePath = predictionViewModel.currentImagePath;
                    if (imagePath == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se encontró la imagen'),
                          backgroundColor: EsquemaColor.diseaseRed,
                        ),
                      );
                      return;
                    }

                    final geminiVm = Provider.of<GeminiViewModel>(
                      context,
                      listen: false,
                    );
                    final treatment = geminiVm.rawTreatmentResponse.isNotEmpty
                        ? geminiVm.rawTreatmentResponse
                        : null;

                    // Leer los bytes de la imagen
                    try {
                      final imageFile = File(imagePath);
                      final imageBytes = await imageFile.readAsBytes();

                      await diagnosticsVm.saveDiagnostic(
                        userId: (authViewModel.user?.id ?? 0).toString(),
                        plantName: prediction.plant,
                        diseaseName: prediction.disease,
                        confidence: prediction.confidence,
                        treatment: treatment,
                        imageBytes: imageBytes,
                        savedKey: currentSaveKey,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Diagnóstico guardado exitosamente',
                            ),
                            backgroundColor: EsquemaColor.healthyGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar: $e'),
                            backgroundColor: EsquemaColor.diseaseRed,
                          ),
                        );
                      }
                    }
                  },
            icon: diagnosticsVm.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              diagnosticsVm.isLoading
                  ? 'Guardando...'
                  : '💾 Guardar Diagnóstico',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(
                color: EsquemaColor.primaryGreen,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildSaveKey(
    PredictionViewModel predictionViewModel,
    dynamic prediction,
  ) {
    return [
      predictionViewModel.currentImagePath ?? '',
      prediction.className,
      prediction.plant,
      prediction.disease,
      prediction.confidence.toStringAsFixed(6),
    ].join('|');
  }
}
