import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/app_icon.dart';

/// Organism: Vista de estado vacío reutilizable
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double iconSize;
  final Color? iconColor;
  final bool showIconContainer;

  const EmptyStateView({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize = 60,
    this.iconColor,
    this.showIconContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIconContainer)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: EsquemaColor.primaryGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? EsquemaColor.primaryGreen,
                ),
              )
            else
              AppIcon(
                icon: icon,
                size: iconSize,
                color: iconColor ?? EsquemaColor.primaryGreen,
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Tipografia.titulo3.copyWith(
                color: EsquemaColor.darkGreen,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Tipografia.cuerpo.copyWith(
                  color: EsquemaColor.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
