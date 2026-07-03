import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/app_button.dart';

/// Organism: Vista de estado de error con acción de reintentar
class ErrorStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData icon;
  final Color? iconColor;

  const ErrorStateView({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon = Icons.error_outline,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? EsquemaColor.diseaseRed,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Tipografia.titulo2.copyWith(
                color: iconColor ?? EsquemaColor.diseaseRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Tipografia.cuerpo.copyWith(
                color: EsquemaColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              AppButton(
                text: retryText ?? 'Volver',
                icon: Icons.arrow_back,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Organism: Vista de estado de carga
class LoadingStateView extends StatelessWidget {
  final String? message;
  final String? submessage;

  const LoadingStateView({
    Key? key,
    this.message,
    this.submessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingIndicator(
        message: message,
        submessage: submessage,
      ),
    );
  }
}
