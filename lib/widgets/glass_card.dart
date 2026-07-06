import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:pagolisto/core/app_colors.dart';

/// Contenedor con efecto de vidrio esmerilado: fondo translúcido +
/// desenfoque de lo que hay detrás + borde sutil brillante.
///
/// Usar BackdropFilter dentro de un ClipRRect es lo que produce el
/// desenfoque real del contenido de atrás (no solo una superposición
/// semitransparente), y el ClipRRect evita que el blur se "escape"
/// fuera de las esquinas redondeadas.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final Color borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurSigma = 16,
    this.borderColor = AppColors.glassBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}