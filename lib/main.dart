import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'data/datasource/onnx_datasource.dart';
import 'data/repositories/prediction_repository_impl.dart';
import 'domain/use_case/predict_disease_usecase.dart';
import 'presentation/viewmodels/prediction_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'presentation/viewmodels/gemini_viewmodel.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/diagnostics_viewmodel.dart';
import 'presentation/viewmodels/foto_viewmodel.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/temas/tema_general.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModel - Debe inicializarse primero
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..init(),
        ),
        
        // Foto ViewModel para manejo de cámara y galería (MVVM)
        ChangeNotifierProvider(
          create: (_) => FotoViewModel(),
        ),
        
        // Settings ViewModel
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(),
        ),
        
        // Prediction ViewModel con dependencias (modelo configurable, preprocesamiento automático)
        ChangeNotifierProxyProvider<SettingsViewModel, PredictionViewModel>(
          create: (context) {
            final settings = Provider.of<SettingsViewModel>(context, listen: false);
            final dataSource = OnnxDataSource(
              modelFileName: settings.modelFileName,
            );
            final repository = PredictionRepositoryImpl(dataSource);
            final useCase = PredictDiseaseUseCase(repository);
            return PredictionViewModel(useCase);
          },
          update: (context, settings, previousViewModel) {
            // Recrear ViewModel cuando cambien las configuraciones
            final dataSource = OnnxDataSource(
              modelFileName: settings.modelFileName,
            );
            final repository = PredictionRepositoryImpl(dataSource);
            final useCase = PredictDiseaseUseCase(repository);
            return PredictionViewModel(useCase);
          },
        ),
        
        // Gemini ViewModel para tratamientos y chatbot
        ChangeNotifierProvider(
          create: (_) => GeminiViewModel(),
        ),
        
        // Diagnostics ViewModel para historial
        ChangeNotifierProvider(
          create: (_) => DiagnosticsViewModel(),
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SymptoLeaf',
            theme: TemaGeneral.lightTheme,
            // Ruta inicial basada en estado de autenticación
            initialRoute: authViewModel.isLoading 
                ? AppRoutes.login // Mostrar login mientras carga
                : (authViewModel.isLoggedIn ? AppRoutes.main : AppRoutes.login),
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
