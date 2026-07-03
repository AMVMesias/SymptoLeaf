import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/foto_viewmodel.dart';
import '../atoms/gradient_container.dart';
import '../organisms/empty_state_view.dart';
import '../organisms/photo_card.dart';
import '../../viewmodels/prediction_viewmodel.dart';
import '../../temas/esquema_color.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fotoViewModel = Provider.of<FotoViewModel>(context);

    return Scaffold(
      body: fotoViewModel.fotos.isEmpty
          ? const GradientContainer(
              child: EmptyStateView(
                icon: Icons.add_a_photo,
                title: 'No hay fotos capturadas',
                subtitle: 'Presiona el botón de cámara para capturar',
              ),
            )
          : ListView.builder(
              itemCount: fotoViewModel.fotos.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final foto = fotoViewModel.fotos[index];
                return PhotoCard(
                  foto: foto,
                  onAnalizar: () {
                    final predictionViewModel = Provider.of<PredictionViewModel>(context, listen: false);
                    predictionViewModel.predictDisease(foto.path);
                    Navigator.of(context).pushNamed('/result');
                  },
                  onEliminar: () => fotoViewModel.eliminarFoto(index),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => fotoViewModel.seleccionarGaleria(context),
            backgroundColor: EsquemaColor.lightGreen,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => fotoViewModel.tomarFoto(context),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
