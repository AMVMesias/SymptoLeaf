import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';

/// Atom: Icono con contenedor decorativo
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double containerSize;
  final double borderRadius;
  final bool isCircle;
  final BoxShadow? shadow;

  const AppIcon({
    Key? key,
    required this.icon,
    this.size = 28,
    this.color,
    this.backgroundColor,
    this.containerSize = 50,
    this.borderRadius = 12,
    this.isCircle = false,
    this.shadow,
  }) : super(key: key);

  /// Constructor para icono simple sin contenedor
  const AppIcon.simple({
    Key? key,
    required this.icon,
    this.size = 24,
    this.color,
  })  : backgroundColor = null,
        containerSize = 24,
        borderRadius = 0,
        isCircle = false,
        shadow = null,
        super(key: key);

  /// Constructor para icono circular con fondo
  const AppIcon.circular({
    Key? key,
    required this.icon,
    this.size = 28,
    this.color,
    this.backgroundColor,
    this.containerSize = 50,
    this.shadow,
  })  : borderRadius = 0,
        isCircle = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: size,
      color: color ?? EsquemaColor.primaryGreen,
    );

    if (backgroundColor == null && !isCircle) {
      return iconWidget;
    }

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? EsquemaColor.primaryGreen.withOpacity(0.1),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      child: Center(child: iconWidget),
    );
  }
}
