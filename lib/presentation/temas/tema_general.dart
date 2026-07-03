// Sistema de temas personalizado - Agregado: 10 Enero 2026
// Define el esquema de colores y estilos de la aplicación

import 'package:flutter/material.dart';
import 'esquema_color.dart';

class TemaGeneral {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: EsquemaColor.primaryGreen,
      scaffoldBackgroundColor: EsquemaColor.background,
      colorScheme: const ColorScheme.light(
        primary: EsquemaColor.primaryGreen,
        secondary: EsquemaColor.lightGreen,
        surface: EsquemaColor.surface,
        error: EsquemaColor.diseaseRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EsquemaColor.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EsquemaColor.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: EsquemaColor.primaryGreen,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: EsquemaColor.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EsquemaColor.lightGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EsquemaColor.lightGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EsquemaColor.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
