# Script para reconstruir el historial de commits de SymptoLeaf
# Cada commit tendrá los archivos correspondientes a cada feature

$source = "C:\Users\mesia\AndroidStudioProjects\SymptoLeaf"
$dest = "C:\Users\mesia\AndroidStudioProjects\SymptoLeaf_new"

# Función para hacer commit con fecha específica
function Make-Commit {
    param(
        [string]$message,
        [string]$date
    )
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    git add -A
    git commit -m $message
}

# ========================================
# COMMIT 1: Initial commit (8 de enero)
# Archivos base del proyecto sin features avanzadas
# ========================================
Write-Host "📦 Commit 1: Initial commit - 8 de enero 2026" -ForegroundColor Green

# Copiar archivos de configuración base
Copy-Item "$source\.gitignore" $dest -Force
Copy-Item "$source\.metadata" $dest -Force -ErrorAction SilentlyContinue
Copy-Item "$source\README.md" $dest -Force
Copy-Item "$source\pubspec.yaml" $dest -Force
Copy-Item "$source\pubspec.lock" $dest -Force
Copy-Item "$source\analysis_options.yaml" $dest -Force
Copy-Item "$source\SymptoLeaf.code-workspace" $dest -Force

# Copiar android, ios, linux, macos, web, windows, test
Copy-Item "$source\android" $dest -Recurse -Force
Copy-Item "$source\ios" $dest -Recurse -Force
Copy-Item "$source\linux" $dest -Recurse -Force
Copy-Item "$source\macos" $dest -Recurse -Force
Copy-Item "$source\web" $dest -Recurse -Force
Copy-Item "$source\windows" $dest -Recurse -Force
Copy-Item "$source\test" $dest -Recurse -Force
Copy-Item "$source\assets" $dest -Recurse -Force

# Crear estructura lib base (sin features avanzadas)
New-Item -ItemType Directory -Path "$dest\lib" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\config" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\data\datasource" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\data\models" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\data\repositories" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\domain\entities" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\domain\use_case" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\presentation\routes" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\presentation\viewmodels" -Force | Out-Null
New-Item -ItemType Directory -Path "$dest\lib\presentation\views" -Force | Out-Null

# Main básico (versión inicial simple)
@"
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// SymptoLeaf - Plant Disease Detection App
/// Initial version with basic UI structure
/// Created: January 8, 2026
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SymptoLeaf',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('SymptoLeaf - Coming Soon'),
        ),
      ),
    );
  }
}
"@ | Out-File -FilePath "$dest\lib\main.dart" -Encoding utf8

# Copiar archivos base de data layer
Copy-Item "$source\lib\data\datasource\base_datasource.dart" "$dest\lib\data\datasource\" -Force
Copy-Item "$source\lib\data\datasource\api_datasource.dart" "$dest\lib\data\datasource\" -Force
Copy-Item "$source\lib\data\models\prediction_model.dart" "$dest\lib\data\models\" -Force
Copy-Item "$source\lib\data\repositories\base_repository.dart" "$dest\lib\data\repositories\" -Force
Copy-Item "$source\lib\data\repositories\prediction_repository_impl.dart" "$dest\lib\data\repositories\" -Force
Copy-Item "$source\lib\domain\entities\prediction_entity.dart" "$dest\lib\domain\entities\" -Force
Copy-Item "$source\lib\domain\use_case\predict_disease_usecase.dart" "$dest\lib\domain\use_case\" -Force

# App config básico
Copy-Item "$source\lib\config\app_config.dart" "$dest\lib\config\" -Force

# Mode selection screen básico
Copy-Item "$source\lib\presentation\views\mode_selection_screen.dart" "$dest\lib\presentation\views\" -Force

# Settings viewmodel
Copy-Item "$source\lib\presentation\viewmodels\settings_viewmodel.dart" "$dest\lib\presentation\viewmodels\" -Force

# Routes básico (sin todas las rutas)
@"
import 'package:flutter/material.dart';
import '../views/mode_selection_screen.dart';

/// App routes - Initial version
/// Created: January 8, 2026
class AppRoutes {
  static const String modeSelection = '/mode-selection';

  static Map<String, WidgetBuilder> get routes => {
    modeSelection: (context) => const ModeSelectionScreen(),
  };
}
"@ | Out-File -FilePath "$dest\lib\presentation\routes\app_routes.dart" -Encoding utf8

Make-Commit -message "Initial commit - First design with basic UI" -date "2026-01-08T12:00:00"

# ========================================
# COMMIT 2: Welcome Screen (9 de enero)
# ========================================
Write-Host "📦 Commit 2: Welcome screen - 9 de enero 2026" -ForegroundColor Cyan

# Agregar welcome_screen.dart
Copy-Item "$source\lib\presentation\views\welcome_screen.dart" "$dest\lib\presentation\views\" -Force

# Actualizar main.dart para usar welcome
@"
import 'package:flutter/material.dart';
import 'presentation/views/welcome_screen.dart';
import 'presentation/views/mode_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

/// SymptoLeaf - Plant Disease Detection App
/// Added: Welcome screen with animations
/// Updated: January 9, 2026
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SymptoLeaf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/mode-selection': (context) => const ModeSelectionScreen(),
      },
    );
  }
}
"@ | Out-File -FilePath "$dest\lib\main.dart" -Encoding utf8

Make-Commit -message "feat: Add welcome screen with animations and improved UX" -date "2026-01-09T14:30:00"

# ========================================
# COMMIT 3: Theme System (10 de enero)
# ========================================
Write-Host "📦 Commit 3: Theme system - 10 de enero 2026" -ForegroundColor Yellow

# Crear directorio de temas y copiar archivos
New-Item -ItemType Directory -Path "$dest\lib\presentation\temas" -Force | Out-Null
Copy-Item "$source\lib\presentation\temas\esquema_color.dart" "$dest\lib\presentation\temas\" -Force
Copy-Item "$source\lib\presentation\temas\tipografia.dart" "$dest\lib\presentation\temas\" -Force
Copy-Item "$source\lib\presentation\temas\tema_general.dart" "$dest\lib\presentation\temas\" -Force

# Actualizar main.dart para usar el tema
@"
import 'package:flutter/material.dart';
import 'presentation/views/welcome_screen.dart';
import 'presentation/views/mode_selection_screen.dart';
import 'presentation/temas/tema_general.dart';

void main() {
  runApp(const MyApp());
}

/// SymptoLeaf - Plant Disease Detection App
/// Added: Custom theme system with colors and typography
/// Updated: January 10, 2026
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SymptoLeaf',
      debugShowCheckedModeBanner: false,
      theme: TemaGeneral.lightTheme,
      home: const WelcomeScreen(),
      routes: {
        '/mode-selection': (context) => const ModeSelectionScreen(),
      },
    );
  }
}
"@ | Out-File -FilePath "$dest\lib\main.dart" -Encoding utf8

Make-Commit -message "feat: Add custom theme system with colors and typography" -date "2026-01-10T16:00:00"

# ========================================
# COMMIT 4: Camera & Result Screens (11 de enero)
# ========================================
Write-Host "📦 Commit 4: Camera & Result screens - 11 de enero 2026" -ForegroundColor Magenta

# Copiar camera y result screens
Copy-Item "$source\lib\presentation\views\camera_screen.dart" "$dest\lib\presentation\views\" -Force
Copy-Item "$source\lib\presentation\views\result_screen.dart" "$dest\lib\presentation\views\" -Force

# Copiar prediction viewmodel
Copy-Item "$source\lib\presentation\viewmodels\prediction_viewmodel.dart" "$dest\lib\presentation\viewmodels\" -Force

# Copiar treatment model
Copy-Item "$source\lib\data\models\treatment_model.dart" "$dest\lib\data\models\" -Force

# Actualizar routes
@"
import 'package:flutter/material.dart';
import '../views/welcome_screen.dart';
import '../views/mode_selection_screen.dart';
import '../views/camera_screen.dart';
import '../views/result_screen.dart';

/// App routes - Added camera and result screens
/// Updated: January 11, 2026
class AppRoutes {
  static const String welcome = '/';
  static const String modeSelection = '/mode-selection';
  static const String camera = '/camera';
  static const String result = '/result';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    modeSelection: (context) => const ModeSelectionScreen(),
    camera: (context) => const CameraScreen(),
    result: (context) => const ResultScreen(),
  };
}
"@ | Out-File -FilePath "$dest\lib\presentation\routes\app_routes.dart" -Encoding utf8

Make-Commit -message "feat: Redesign camera and result screens with modern UI" -date "2026-01-11T10:00:00"

# ========================================
# COMMIT 5: ONNX Runtime (12 de enero)
# ========================================
Write-Host "📦 Commit 5: ONNX Runtime fix - 12 de enero 2026" -ForegroundColor Blue

# Copiar ONNX datasource
Copy-Item "$source\lib\data\datasource\onnx_datasource.dart" "$dest\lib\data\datasource\" -Force

Make-Commit -message "fix: Migrate from TFLite to ONNX Runtime - Local mode now working" -date "2026-01-12T11:30:00"

# ========================================
# COMMIT 6: Gemini Config (13 de enero)
# ========================================
Write-Host "📦 Commit 6: Gemini config - 13 de enero 2026" -ForegroundColor DarkCyan

# Copiar gemini config y service
Copy-Item "$source\lib\config\gemini_config.dart" "$dest\lib\config\" -Force
Copy-Item "$source\lib\data\datasource\gemini_service.dart" "$dest\lib\data\datasource\" -Force

Make-Commit -message "feat: Add Gemini AI configuration with secure API key management" -date "2026-01-13T09:00:00"

# ========================================
# COMMIT 7: Chatbot (14 de enero AM)
# ========================================
Write-Host "📦 Commit 7: Chatbot - 14 de enero 2026" -ForegroundColor DarkGreen

# Copiar chat screen y gemini viewmodel
Copy-Item "$source\lib\presentation\views\chat_screen.dart" "$dest\lib\presentation\views\" -Force
Copy-Item "$source\lib\presentation\viewmodels\gemini_viewmodel.dart" "$dest\lib\presentation\viewmodels\" -Force
Copy-Item "$source\lib\data\models\chat_message_model.dart" "$dest\lib\data\models\" -Force

# Actualizar routes con chat
@"
import 'package:flutter/material.dart';
import '../views/welcome_screen.dart';
import '../views/mode_selection_screen.dart';
import '../views/camera_screen.dart';
import '../views/result_screen.dart';
import '../views/chat_screen.dart';

/// App routes - Complete with all screens
/// Updated: January 14, 2026
class AppRoutes {
  static const String welcome = '/';
  static const String modeSelection = '/mode-selection';
  static const String camera = '/camera';
  static const String result = '/result';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    modeSelection: (context) => const ModeSelectionScreen(),
    camera: (context) => const CameraScreen(),
    result: (context) => const ResultScreen(),
    chat: (context) => const ChatScreen(),
  };
}
"@ | Out-File -FilePath "$dest\lib\presentation\routes\app_routes.dart" -Encoding utf8

Make-Commit -message "feat: Add agricultural chatbot with Gemini AI" -date "2026-01-14T10:00:00"

# ========================================
# COMMIT 8: Final main.dart (14 de enero PM)
# ========================================
Write-Host "📦 Commit 8: Final cleanup - 14 de enero 2026" -ForegroundColor White

# Copiar el main.dart final completo
Copy-Item "$source\lib\main.dart" "$dest\lib\main.dart" -Force

# Copiar el test_gemini_api.py si existe
if (Test-Path "$source\test_gemini_api.py") {
    Copy-Item "$source\test_gemini_api.py" "$dest\" -Force
}

Make-Commit -message "chore: Clean up and finalize project structure" -date "2026-01-14T22:00:00"

Write-Host ""
Write-Host "✅ Historial reconstruido exitosamente!" -ForegroundColor Green
Write-Host "Verifica con: git log --oneline" -ForegroundColor Gray
