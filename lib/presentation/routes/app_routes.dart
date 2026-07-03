import 'package:flutter/material.dart';
import '../view/pages/pages.dart';

/// App routes - Complete with all screens
/// Updated: February 10, 2026 - Cleaned obsolete routes
class AppRoutes {
  static const String main = '/';
  static const String camera = '/camera';
  static const String result = '/result';
  static const String chat = '/chat';
  static const String login = '/login';
  static const String register = '/register';
  static const String history = '/history';

  static Map<String, WidgetBuilder> get routes => {
    main: (context) => const MainScreen(),
    camera: (context) => const CameraScreen(),
    result: (context) => const ResultScreen(),
    chat: (context) => const ChatScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    history: (context) => const HistoryScreen(),
  };
}
