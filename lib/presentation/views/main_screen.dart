import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temas/esquema_color.dart';
import '../temas/tipografia.dart';
import '../viewmodels/settings_viewmodel.dart';
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
          // Chip indicador de modo (clicable)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showModeDialog(context, settingsViewModel);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: settingsViewModel.mode == PredictionMode.local
                        ? EsquemaColor.healthyGreen.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: settingsViewModel.mode == PredictionMode.local
                          ? EsquemaColor.healthyGreen
                          : Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settingsViewModel.mode == PredictionMode.local
                            ? Icons.phone_android
                            : Icons.cloud,
                        size: 16,
                        color: settingsViewModel.mode == PredictionMode.local
                            ? EsquemaColor.healthyGreen
                            : Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        settingsViewModel.mode == PredictionMode.local
                            ? 'Local'
                            : 'Servidor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: settingsViewModel.mode == PredictionMode.local
                              ? EsquemaColor.healthyGreen
                              : Colors.blue,
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

  void _showModeDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    print('🔧 DEBUG: _showModeDialog called'); // Debug
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo de Detección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.phone_android,
                color: settingsViewModel.mode == PredictionMode.local
                    ? EsquemaColor.healthyGreen
                    : Colors.grey,
              ),
              title: const Text('Modelo Local'),
              subtitle: const Text('Funciona sin internet'),
              trailing: settingsViewModel.mode == PredictionMode.local
                  ? const Icon(Icons.check_circle, color: EsquemaColor.healthyGreen)
                  : null,
              onTap: () {
                settingsViewModel.setMode(PredictionMode.local);
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.cloud,
                color: settingsViewModel.mode == PredictionMode.server
                    ? Colors.blue
                    : Colors.grey,
              ),
              title: const Text('Servidor Local'),
              subtitle: const Text('Requiere conexión'),
              trailing: settingsViewModel.mode == PredictionMode.server
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : null,
              onTap: () {
                settingsViewModel.setMode(PredictionMode.server);
                Navigator.of(context).pop();
              },
            ),
          ],
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
}
