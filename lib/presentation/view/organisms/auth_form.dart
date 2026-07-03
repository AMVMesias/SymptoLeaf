import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/app_text_field.dart';
import '../atoms/app_button.dart';

/// Organism: Formulario de autenticación reutilizable
class AuthForm extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final TextEditingController? nameController;
  final bool isLogin;
  final bool isLoading;
  final VoidCallback? onSubmit;
  final VoidCallback? onSecondaryAction;
  final String submitText;
  final String? secondaryActionText;
  final bool obscurePassword;
  final VoidCallback? onTogglePassword;

  const AuthForm({
    Key? key,
    this.formKey,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    this.nameController,
    this.isLogin = true,
    this.isLoading = false,
    this.onSubmit,
    this.onSecondaryAction,
    this.submitText = 'Iniciar Sesión',
    this.secondaryActionText,
    this.obscurePassword = true,
    this.onTogglePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
              style: Tipografia.titulo2.copyWith(
                color: EsquemaColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Campo de nombre (solo registro)
            if (!isLogin && nameController != null) ...[
              AppTextField(
                controller: nameController,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Campo de email
            AppTextField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu email';
                }
                if (!value.contains('@')) {
                  return 'Por favor ingresa un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo de contraseña
            AppTextField(
              controller: passwordController,
              labelText: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: EsquemaColor.textSecondary,
                ),
                onPressed: onTogglePassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),

            // Confirmar contraseña (solo registro)
            if (!isLogin && confirmPasswordController != null) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: confirmPasswordController,
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            // Botón de envío
            AppButton(
              text: submitText,
              onPressed: onSubmit,
              isLoading: isLoading,
              isExpanded: true,
              height: 50,
            ),

            // Acción secundaria
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(
                  secondaryActionText!,
                  style: Tipografia.cuerpo.copyWith(
                    color: EsquemaColor.primaryGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
