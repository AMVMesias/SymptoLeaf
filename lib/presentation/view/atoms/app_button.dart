import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Tipos de botón disponibles
enum AppButtonType { primary, secondary, text, danger }

/// Atom: Botón reutilizable con múltiples variantes
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final double height;
  final double borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();
    
    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }
    
    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildButton() {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton();
      case AppButtonType.secondary:
        return _buildSecondaryButton();
      case AppButtonType.text:
        return _buildTextButton();
      case AppButtonType.danger:
        return _buildDangerButton();
    }
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: EsquemaColor.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: EsquemaColor.primaryGreen,
        side: const BorderSide(color: EsquemaColor.primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(EsquemaColor.primaryGreen),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: EsquemaColor.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(EsquemaColor.primaryGreen),
    );
  }

  Widget _buildDangerButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: EsquemaColor.diseaseRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(EsquemaColor.diseaseRed),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: Tipografia.subtitulo),
        ],
      );
    }

    return Text(text, style: Tipografia.subtitulo);
  }
}
