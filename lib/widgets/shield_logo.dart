import 'package:flutter/material.dart';

import 'package:pagolisto/core/app_colors.dart';

/// Dibuja el logo de "Pago Listo": un escudo minimalista de líneas, con
/// un check (✓) y un signo de dólar ($) integrados, en verde eléctrico.
///
/// Se dibuja con CustomPainter en lugar de un asset de imagen para que
/// se vea nítido en cualquier densidad de pantalla y para poder animar
/// o recolorear el ícono fácilmente en el futuro si hace falta.
class ShieldLogo extends StatelessWidget {
  final double size;

  const ShieldLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldLogoPainter(),
      ),
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Contorno del escudo: silueta clásica de "shield" simplificada,
    // trazada como línea (no relleno) para mantener el look minimalista.
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.88, h * 0.20)
      ..lineTo(w * 0.88, h * 0.52)
      ..cubicTo(
        w * 0.88, h * 0.76,
        w * 0.70, h * 0.90,
        w * 0.5, h * 0.97,
      )
      ..cubicTo(
        w * 0.30, h * 0.90,
        w * 0.12, h * 0.76,
        w * 0.12, h * 0.52,
      )
      ..lineTo(w * 0.12, h * 0.20)
      ..close();

    canvas.drawPath(shieldPath, strokePaint);

    // Signo de dólar, sutil, detrás del check, como marca de agua del
    // propósito financiero de la app.
    final dollarPaint = Paint()
      ..color = AppColors.accentGreen.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round;

    final dollarPath = Path()
      ..moveTo(w * 0.5, h * 0.28)
      ..lineTo(w * 0.5, h * 0.50);
    canvas.drawPath(dollarPath, dollarPaint);

    final sPath = Path()
      ..moveTo(w * 0.42, h * 0.32)
      ..quadraticBezierTo(w * 0.34, h * 0.32, w * 0.34, h * 0.38)
      ..quadraticBezierTo(w * 0.34, h * 0.44, w * 0.46, h * 0.44)
      ..quadraticBezierTo(w * 0.58, h * 0.44, w * 0.58, h * 0.50)
      ..quadraticBezierTo(w * 0.58, h * 0.56, w * 0.46, h * 0.56);
    canvas.drawPath(sPath, dollarPaint);

    // Check (✓) prominente al frente, trazo grueso, es el elemento
    // dominante del ícono.
    final checkPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(w * 0.30, h * 0.58)
      ..lineTo(w * 0.45, h * 0.72)
      ..lineTo(w * 0.72, h * 0.42);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}