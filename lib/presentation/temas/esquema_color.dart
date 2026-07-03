import 'package:flutter/material.dart';

class EsquemaColor {
  // Colores principales - tonos verdes para plantas
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color darkGreen = Color(0xFF1B5E20);
  
  // Colores de estado
  static const Color healthyGreen = Color(0xFF4CAF50);
  static const Color diseaseRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  
  // Colores neutros
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Gradiente de fondo
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F5E9),
      Color(0xFFF1F8E9),
    ],
  );
}
