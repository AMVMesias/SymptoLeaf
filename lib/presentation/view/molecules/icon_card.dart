import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/app_icon.dart';

/// Molecule: Tarjeta de icono con título y subtítulo
class IconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double iconSize;
  final double iconContainerSize;
  final bool isCircleIcon;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;

  const IconCard({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize = 28,
    this.iconContainerSize = 50,
    this.isCircleIcon = false,
    this.padding,
    this.borderRadius = 16,
    this.elevation = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              AppIcon(
                icon: icon,
                size: iconSize,
                color: iconColor ?? EsquemaColor.primaryGreen,
                backgroundColor: iconBackgroundColor ??
                    EsquemaColor.primaryGreen.withOpacity(0.1),
                containerSize: iconContainerSize,
                isCircle: isCircleIcon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Tipografia.titulo3.copyWith(
                        color: EsquemaColor.darkGreen,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Tipografia.cuerpo.copyWith(
                          color: EsquemaColor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: EsquemaColor.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
