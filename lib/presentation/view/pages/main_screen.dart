import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'perfil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<String> _titles = const [
    'Inicio',
    'Mis Fotografías',
    'Perfil',
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: Tipografia.titulo2.copyWith(
            color: EsquemaColor.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Chip indicador de configuración (clicable)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showSettingsDialog(context, settingsViewModel);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: EsquemaColor.healthyGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: EsquemaColor.healthyGreen,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settingsViewModel.modelType == ModelType.yolo11
                            ? Icons.auto_awesome
                            : Icons.memory,
                        size: 16,
                        color: EsquemaColor.healthyGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        settingsViewModel.modelType == ModelType.yolo11
                            ? 'YOLO11'
                            : 'ResNet9',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: EsquemaColor.healthyGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onTabChange: _onTabChange),
          const CameraScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: EsquemaColor.primaryGreen,
          unselectedItemColor: EsquemaColor.textSecondary,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: _onTabChange,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: 'Fotos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: EsquemaColor.healthyGreen),
            const SizedBox(width: 8),
            const Text('Configuración de IA'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Modelo
              const Text(
                '🧠 Modelo de Clasificación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildModelOption(
                settingsViewModel,
                ModelType.standard,
                Icons.memory,
                'ResNet9',
                'Modelo original (38 enfermedades)',
              ),
              _buildModelOption(
                settingsViewModel,
                ModelType.yolo11,
                Icons.auto_awesome,
                'YOLO11 (Mejorado)',
                'Mayor precisión con imágenes variadas',
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Nota sobre preprocesamiento automático
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El análisis prueba automáticamente 3 métodos de preprocesamiento y selecciona el mejor resultado',
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModelOption(
    SettingsViewModel settings,
    ModelType type,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = settings.modelType == type;
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isSelected ? EsquemaColor.healthyGreen : Colors.grey,
        size: 22,
      ),
      title: Text(title, style: TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: EsquemaColor.healthyGreen, size: 20)
          : null,
      onTap: () {
        settings.setModelType(type);
        Navigator.of(context).pop();
        _showSettingsDialog(context, settings);
      },
    );
  }
}
