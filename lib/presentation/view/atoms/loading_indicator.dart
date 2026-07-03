import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Atom: Indicador de carga reutilizable
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final String? submessage;
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.submessage,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? EsquemaColor.primaryGreen,
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            style: Tipografia.titulo3,
            textAlign: TextAlign.center,
          ),
        ],
        if (submessage != null) ...[
          const SizedBox(height: 8),
          Text(
            submessage!,
            style: Tipografia.cuerpo.copyWith(
              color: EsquemaColor.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
