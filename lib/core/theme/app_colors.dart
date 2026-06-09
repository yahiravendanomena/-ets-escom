import 'package:flutter/material.dart';

/// Paleta de colores institucional ESCOM-IPN.
///
/// Centraliza todos los colores de la aplicación.
/// No se permite usar Color(0x...) directo en widgets,
/// siempre referenciar desde aquí.
class AppColors {
  AppColors._(); // Constructor privado: clase utility, no se instancia.

  // ============================================
  // Colores institucionales IPN
  // ============================================
  static const Color guindaIpn = Color(0xFF7B1538);
  static const Color guindaClaro = Color(0xFF9B2A4F);
  static const Color guindaOscuro = Color(0xFF5A0F2A);

  // ============================================
  // Colores ESCOM (acento)
  // ============================================
  static const Color azulEscom = Color(0xFF1E4D7B);

  // ============================================
  // Panel administrativo (diferenciador visual)
  // ============================================
  static const Color adminGreen = Color(0xFF0F6E56);

  // ============================================
  // Colores semánticos (feedback al usuario)
  // ============================================
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // ============================================
  // Neutros
  // ============================================
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color surface = Color(0xFFFEF7FF);
  static const Color background = Color(0xFFFFFBFE);
}