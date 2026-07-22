import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/models/financial_tip.dart';

/// Pantalla de "Consejos Financieros": muestra un solo consejo, el
/// que corresponde al día de hoy (ver `tipDelDia` en
/// financial_tip.dart), en una tarjeta con el mismo estilo visual
/// que el resto de la app (mismo tipo de borde y fondo que las
/// tarjetas de "Próximos Pagos" e "Historial"). Al día siguiente,
/// sin que el usuario haga nada, el consejo cambia solo.
///
/// El contenido es curado (no depende de los pagos del usuario), así
/// que esta pantalla no necesita escuchar a PaymentsController.
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tip = tipDelDia();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consejos Financieros',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Un consejo nuevo cada día para cuidar tus gastos.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              _TipOfTheDayCard(tip: tip),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipOfTheDayCard extends StatelessWidget {
  final FinancialTip tip;

  const _TipOfTheDayCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tip.color.withOpacity(0.14),
                ),
                child: Icon(tip.icono, color: tip.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip.titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip.descripcion,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tip.highlight,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: tip.color,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}