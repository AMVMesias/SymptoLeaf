import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../atoms/app_text_field.dart';

/// Molecule: Campo de entrada con botón de acción
class InputWithButton extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData buttonIcon;
  final VoidCallback? onButtonPressed;
  final void Function(String)? onSubmitted;
  final bool isLoading;
  final FocusNode? focusNode;
  final Color? buttonColor;

  const InputWithButton({
    Key? key,
    required this.controller,
    this.hintText,
    this.buttonIcon = Icons.send,
    this.onButtonPressed,
    this.onSubmitted,
    this.isLoading = false,
    this.focusNode,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hintText: hintText ?? 'Escribe un mensaje...',
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (onSubmitted != null && value.trim().isNotEmpty) {
                  onSubmitted!(value);
                } else if (onButtonPressed != null && value.trim().isNotEmpty) {
                  onButtonPressed!();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: buttonColor ?? EsquemaColor.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isLoading ? null : onButtonPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(buttonIcon, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
