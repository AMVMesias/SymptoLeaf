import 'dart:io';
import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Molecule: Tarjeta de imagen con información
class ImageInfoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final double imageHeight;
  final double borderRadius;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ImageInfoCard({
    Key? key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.imageHeight = 200,
    this.borderRadius = 16,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
              child: _buildImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Tipografia.titulo3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: Tipografia.caption.copyWith(
                              color: EsquemaColor.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: EsquemaColor.background,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: EsquemaColor.textSecondary,
        ),
      ),
    );
  }
}
