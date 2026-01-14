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
