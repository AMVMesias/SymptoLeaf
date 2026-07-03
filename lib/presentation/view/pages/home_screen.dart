import 'package:flutter/material.dart';
import '../atoms/gradient_container.dart';
import '../atoms/app_text.dart';
import '../molecules/icon_card.dart';
import '../../temas/esquema_color.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;
  
  const HomeScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      useSafeArea: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Ícono principal
              Container(
                width: 120,
                height: 120,
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
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/img.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Título
              AppText.title2(
                'Bienvenido a SymptoLeaf',
                color: EsquemaColor.darkGreen,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtítulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppText.body(
                  'Detecta enfermedades en tus plantas de manera rápida y precisa',
                  color: EsquemaColor.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              
              // Tarjetas de acciones rápidas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    IconCard(
                      icon: Icons.camera_alt,
                      title: 'Analizar Planta',
                      subtitle: 'Toma una foto o selecciona de galería',
                      onTap: () {
                        if (onTabChange != null) {
                          onTabChange!(1);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    IconCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Asistente Virtual',
                      subtitle: 'Pregunta sobre cuidados y tratamientos',
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
