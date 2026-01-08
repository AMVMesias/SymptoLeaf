class AppConfig {
  // URL del servidor por defecto
  // Cambia esta IP por la de tu computadora
  static const String defaultServerUrl = 'http://192.168.1.100:5000';
  
  // Configuraciones adicionales
  static const int connectionTimeout = 30; // segundos
  static const int maxImageSize = 1024; // píxeles
  static const int imageQuality = 85; // 0-100
}
