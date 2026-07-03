import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../temas/esquema_color.dart';
import '../atoms/gradient_container.dart';
import '../organisms/auth_form.dart';

/// Login Screen - Usa Atomic Design (AuthForm + GradientContainer)
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (mounted && authViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.error!),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  /// Manejar login con Google
  Future<void> _handleGoogleLogin() async {
    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.loginWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (mounted && authViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.error!),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: GradientContainer(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EsquemaColor.darkGreen,
              EsquemaColor.primaryGreen,
              EsquemaColor.lightGreen,
            ],
          ),
          useSafeArea: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'SymptoLeaf',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diagnóstico de enfermedades en plantas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Formulario de login (Atomic Design: AuthForm organism)
                  Consumer<AuthViewModel>(
                    builder: (context, auth, child) {
                      return AuthForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        isLogin: true,
                        isLoading: auth.isLoading,
                        onSubmit: _handleLogin,
                        submitText: 'Ingresar',
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      );
                    },
                   ),
                   const SizedBox(height: 24),

                   // Divisor
                   Row(
                     children: [
                       Expanded(
                         child: Container(
                           height: 1,
                           color: Colors.white.withOpacity(0.3),
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 12),
                         child: Text(
                           'O continúa con',
                           style: TextStyle(
                             color: Colors.white.withOpacity(0.7),
                             fontSize: 12,
                           ),
                         ),
                       ),
                       Expanded(
                         child: Container(
                           height: 1,
                           color: Colors.white.withOpacity(0.3),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 20),

                   // Botón Google Sign-In
                   Consumer<AuthViewModel>(
                     builder: (context, auth, child) {
                       return SizedBox(
                         width: double.infinity,
                         height: 56,
                         child: ElevatedButton.icon(
                           onPressed: auth.isLoading ? null : _handleGoogleLogin,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.white,
                             foregroundColor: EsquemaColor.darkGreen,
                             disabledBackgroundColor: Colors.white.withOpacity(0.5),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12),
                             ),
                           ),
                           icon: auth.isLoading
                               ? SizedBox(
                                   width: 24,
                                   height: 24,
                                   child: CircularProgressIndicator(
                                     valueColor: AlwaysStoppedAnimation<Color>(
                                       EsquemaColor.primaryGreen,
                                     ),
                                     strokeWidth: 2,
                                   ),
                                 )
                              : Image.asset(
                                  'assets/icon/google.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (_, __, ___) => const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                           label: Text(
                             auth.isLoading ? 'Cargando...' : 'Google Sign-In',
                             style: const TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                       );
                     },
                   ),
                   const SizedBox(height: 24),

                   // Enlace a registro
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         '¿No tienes cuenta? ',
                         style: TextStyle(
                           color: Colors.white.withOpacity(0.9),
                         ),
                       ),
                       TextButton(
                         onPressed: () {
                           Navigator.pushNamed(context, AppRoutes.register);
                         },
                         child: const Text(
                           'Regístrate',
                           style: TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.bold,
                             decoration: TextDecoration.underline,
                           ),
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
