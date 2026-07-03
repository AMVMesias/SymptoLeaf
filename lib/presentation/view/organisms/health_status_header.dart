import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Organism: Header con estado de salud para resultados
class HealthStatusHeader extends StatelessWidget {
  final bool isHealthy;
  final String plantName;
  final String? diseaseName;
  final double confidence;

  const HealthStatusHeader({
    Key? key,
    required this.isHealthy,
    required this.plantName,
    this.diseaseName,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = isHealthy ? EsquemaColor.healthyGreen : EsquemaColor.diseaseRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? '¡Planta Saludable!' : 'Enfermedad Detectada',
                  style: Tipografia.titulo3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHealthy ? plantName : (diseaseName ?? 'Desconocida'),
                  style: Tipografia.cuerpo.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // Barra de confianza
                _buildConfidenceBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confianza: ${(confidence * 100).toStringAsFixed(1)}%',
          style: Tipografia.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
