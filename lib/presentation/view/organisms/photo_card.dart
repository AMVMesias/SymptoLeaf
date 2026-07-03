import 'dart:io';
import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../../models/foto.dart';
import '../atoms/app_button.dart';

/// Organism: Tarjeta de foto con acciones (reemplazo de FotoItem)
class PhotoCard extends StatelessWidget {
  final Foto foto;
  final VoidCallback? onAnalizar;
  final VoidCallback? onEliminar;
  final double imageHeight;
  final double borderRadius;

  const PhotoCard({
    Key? key,
    required this.foto,
    this.onAnalizar,
    this.onEliminar,
    this.imageHeight = 250,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            child: Image.file(
              File(foto.path),
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: imageHeight,
                color: EsquemaColor.background,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: EsquemaColor.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          
          // Información y acciones
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foto.nombre,
                  style: Tipografia.titulo3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  foto.description,
                  style: Tipografia.caption.copyWith(
                    color: EsquemaColor.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEliminar != null)
                      AppButton(
                        text: 'Eliminar',
                        icon: Icons.delete,
                        type: AppButtonType.danger,
                        onPressed: onEliminar,
                      ),
                    const SizedBox(width: 8),
                    if (onAnalizar != null)
                      AppButton(
                        text: 'Analizar',
                        icon: Icons.search,
                        type: AppButtonType.primary,
                        onPressed: onAnalizar,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
