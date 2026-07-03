import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/gradient_container.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            final user = authViewModel.user;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: EsquemaColor.primaryGreen.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: EsquemaColor.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nombre de usuario
                  Text(
                    user?.name ?? 'Usuario SymptoLeaf',
                    style: Tipografia.titulo2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: EsquemaColor.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'usuario@symptoleaf.com',
                    style: Tipografia.cuerpo.copyWith(
                      color: EsquemaColor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Opciones del perfil
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Configuración',
                    subtitle: 'Ajustes de la aplicación',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configuración próximamente disponible'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Historial',
                    subtitle: 'Ver análisis anteriores',
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.history);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Ayuda',
                    subtitle: 'Centro de ayuda y soporte',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ayuda próximamente disponible'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    subtitle: 'Versión 1.0.0',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'SymptoLeaf',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 SymptoLeaf\nDetección de enfermedades en plantas',
                        applicationIcon: const Icon(
                          Icons.eco,
                          size: 50,
                          color: EsquemaColor.primaryGreen,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón de cerrar sesión
                  if (authViewModel.isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await authViewModel.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: EsquemaColor.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: EsquemaColor.primaryGreen,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Tipografia.titulo3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Tipografia.caption.copyWith(
            color: EsquemaColor.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: EsquemaColor.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
