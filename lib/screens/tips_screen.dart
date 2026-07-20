import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/models/financial_tip.dart';

/// Pantalla de "Consejos Financieros": muestra un solo consejo, el
/// que corresponde al día de hoy (ver `tipDelDia` en
/// financial_tip.dart), en una tarjeta grande y llamativa. Al día
/// siguiente, sin que el usuario haga nada, el consejo cambia solo.
///
/// El contenido es curado (no depende de los pagos del usuario), así
/// que esta pantalla no necesita escuchar a PaymentsController.
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tip = tipDelDia();
    final numero = numeroDeTipDelDia();

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
              const SizedBox(height: 28),
              _TipOfTheDayCard(tip: tip),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Consejo $numero de ${financialTips.length} · vuelve mañana '
                      'por el siguiente',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted.withOpacity(0.7),
                  ),
                ),
              ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tip.color.withOpacity(0.28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tip.color.withOpacity(0.10),
            Colors.white.withOpacity(0.03),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tip.color.withOpacity(0.18),
                ),
                child: Icon(tip.icono, color: tip.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CONSEJO DE HOY',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: tip.color,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            tip.titulo,
            style: GoogleFonts.montserrat(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tip.descripcion,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: tip.color.withOpacity(0.12),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: tip.color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.highlight,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: tip.color,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}