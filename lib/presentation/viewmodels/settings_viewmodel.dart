import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';

enum PredictionMode { server, local }

class SettingsViewModel extends ChangeNotifier {
  PredictionMode _mode = PredictionMode.local;
  String _serverUrl = AppConfig.defaultServerUrl;

  PredictionMode get mode => _mode;
  String get serverUrl => _serverUrl;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('prediction_mode') ?? 'local';
    _mode = modeStr == 'server' ? PredictionMode.server : PredictionMode.local;
    _serverUrl = prefs.getString('server_url') ?? AppConfig.defaultServerUrl;
    notifyListeners();
  }

  Future<void> setMode(PredictionMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prediction_mode', mode == PredictionMode.server ? 'server' : 'local');
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    notifyListeners();
  }
}
