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
