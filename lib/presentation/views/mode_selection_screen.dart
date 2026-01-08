import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../temas/esquema_color.dart';
import '../temas/tipografia.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  final TextEditingController _serverController = TextEditingController();
  bool _showServerInput = false;

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    _serverController.text = settingsViewModel.serverUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo de Detección'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: EsquemaColor.backgroundGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Cómo deseas analizar las plantas?',
                  style: Tipografia.titulo2.copyWith(
                    color: EsquemaColor.darkGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Botón Servidor Local
                _buildModeCard(
                  icon: Icons.cloud,
                  title: 'Usar Servidor Local',
                  description: 'Requiere conexión al servidor',
                  color: EsquemaColor.primaryGreen,
                  onTap: () {
                    setState(() {
                      _showServerInput = true;
                    });
                    settingsViewModel.setMode(PredictionMode.server);
                  },
                  isSelected: settingsViewModel.mode == PredictionMode.server,
                ),
                
                const SizedBox(height: 24),
                
                // Botón Modelo Local
                _buildModeCard(
                  icon: Icons.phone_android,
                  title: 'Usar Modelo Local',
                  description: 'Funciona sin internet',
                  color: EsquemaColor.lightGreen,
                  onTap: () {
                    setState(() {
                      _showServerInput = false;
                    });
                    settingsViewModel.setMode(PredictionMode.local);
                  },
                  isSelected: settingsViewModel.mode == PredictionMode.local,
                ),
                
                const SizedBox(height: 32),
                
                // Input de servidor si está seleccionado
                if (_showServerInput && settingsViewModel.mode == PredictionMode.server) ...[
                  const SizedBox(height: 16),
                  Flexible(
                    child: TextField(
                      controller: _serverController,
                      decoration: const InputDecoration(
                        labelText: 'URL del Servidor',
                        hintText: 'http://192.168.1.100:5000',
                        prefixIcon: Icon(Icons.link),
                      ),
                      onChanged: (value) {
                        settingsViewModel.setServerUrl(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Botón continuar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/camera');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Continuar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.3) : Colors.black12,
              blurRadius: 10,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Tipografia.titulo3.copyWith(
                      color: EsquemaColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Tipografia.cuerpo.copyWith(
                      color: EsquemaColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: EsquemaColor.healthyGreen,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
