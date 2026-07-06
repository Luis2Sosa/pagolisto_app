import 'package:flutter/material.dart';

/// Paleta de colores central de "Pago Listo".
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Verde de acento (el mismo verde del escudo, botones y highlights).
  // ---------------------------------------------------------------------
  static const Color accentGreen = Color(0xFF34D399);

  // ---------------------------------------------------------------------
  // Texto
  // ---------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFFB8C4C0);
  static const Color textMuted = Color(0xFF8A9994);

  // ---------------------------------------------------------------------
  // Fondo: negro predominante, con solo un toque sutil de verde
  // asomando desde arriba y otro toque desde abajo (no un brillo
  // fuerte y centrado, sino algo casi imperceptible).
  // ---------------------------------------------------------------------
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0C231C), // toque verde muy tenue, arriba
      Color(0xFF060F0C),
      Color(0xFF000000), // negro puro, domina el centro
      Color(0xFF060F0C),
      Color(0xFF0C231C), // toque verde muy tenue, abajo
    ],
    stops: [0.0, 0.22, 0.5, 0.78, 1.0],
  );

  // ---------------------------------------------------------------------
  // Vidrio esmerilado (GlassCard): relleno translúcido y borde sutil
  // que dejan ver el fondo degradado desenfocado detrás de la tarjeta.
  // ---------------------------------------------------------------------
  static const Color glassFill = Color(0x0DFFFFFF); // blanco al 5%
  static const Color glassBorder = Color(0x1FFFFFFF); // blanco al 12%

  // ---------------------------------------------------------------------
  // Botón principal (relleno del botón "ENTRAR" / "GUARDAR").
  // ---------------------------------------------------------------------
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4ADE80),
      Color(0xFF16A34A),
    ],
  );
}