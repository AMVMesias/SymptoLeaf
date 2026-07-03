import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Tipos de estado
enum StatusType { healthy, diseased, warning, neutral }

/// Molecule: Badge de estado con icono y texto
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final IconData? icon;
  final bool showIcon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    Key? key,
    required this.text,
    this.type = StatusType.neutral,
    this.icon,
    this.showIcon = true,
    this.borderRadius = 12,
    this.padding,
  }) : super(key: key);

  /// Constructor para estado saludable
  const StatusBadge.healthy({
    Key? key,
    required this.text,
    this.icon = Icons.check_circle,
    this.showIcon = true,
    this.borderRadius = 12,
    this.padding,
  })  : type = StatusType.healthy,
        super(key: key);

  /// Constructor para estado de enfermedad
  const StatusBadge.diseased({
    Key? key,
    required this.text,
    this.icon = Icons.warning,
    this.showIcon = true,
    this.borderRadius = 12,
    this.padding,
  })  : type = StatusType.diseased,
        super(key: key);

  /// Constructor para advertencia
  const StatusBadge.warning({
    Key? key,
    required this.text,
    this.icon = Icons.info_outline,
    this.showIcon = true,
    this.borderRadius = 12,
    this.padding,
  })  : type = StatusType.warning,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && _icon != null) ...[
            Icon(_icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: Tipografia.subtitulo.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusType.healthy:
        return EsquemaColor.healthyGreen;
      case StatusType.diseased:
        return EsquemaColor.diseaseRed;
      case StatusType.warning:
        return EsquemaColor.warningOrange;
      case StatusType.neutral:
        return EsquemaColor.textSecondary;
    }
  }

  IconData? get _icon {
    if (icon != null) return icon;
    
    switch (type) {
      case StatusType.healthy:
        return Icons.check_circle;
      case StatusType.diseased:
        return Icons.warning;
      case StatusType.warning:
        return Icons.info_outline;
      case StatusType.neutral:
        return null;
    }
  }
}
