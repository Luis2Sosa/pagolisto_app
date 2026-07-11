import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/widgets/glass_card.dart';

/// Pantalla "Sobre Pago Listo": misión, cómo funciona la app e
/// información general, presentadas como tarjetas flotantes de vidrio
/// esmerilado sobre el mismo fondo degradado de la app.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _AboutAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MissionCard(),
                      const SizedBox(height: 20),
                      const _HowItWorksCard(),
                      const SizedBox(height: 20),
                      const _AppInfoCard(),
                      const SizedBox(height: 32),
                      const _Footer(),
                    ],
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

class _AboutAppBar extends StatelessWidget {
  const _AboutAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          Text(
            'Acerca de',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: 17,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              const _CardEyebrow(text: 'Nuestra misión'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Simplificar el seguimiento financiero y la gestión de '
                'cuentas para un futuro mejor.',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Explica el flujo de uso de la app en 3 pasos, distinto del listado
/// de funciones que ya se ve en la pantalla de Inicio.
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  static const List<_StepItem> _steps = [
    _StepItem(
      number: '1',
      title: 'Registra tus pagos',
      description:
      'Añade cada cuenta con su monto y elige si es quincenal o mensual.',
    ),
    _StepItem(
      number: '2',
      title: 'Deja que Pago Listo te avise',
      description:
      'Recibe recordatorios antes de cada fecha límite, sin sorpresas.',
    ),
    _StepItem(
      number: '3',
      title: 'Revisa tu remanente y ahorra',
      description:
      'Consulta cuánto te falta por pagar y aplica los consejos financieros.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  size: 17,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              const _CardEyebrow(text: '¿Cómo funciona?'),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _steps.length; i++) ...[
            _StepRow(item: _steps[i]),
            if (i != _steps.length - 1) const _FeatureDivider(),
          ],
        ],
      ),
    );
  }
}

class _StepItem {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });
}

class _StepRow extends StatelessWidget {
  final _StepItem item;

  const _StepRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGreen.withOpacity(0.45),
                width: 1.2,
              ),
            ),
            child: Text(
              item.number,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.accentGreen,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    height: 1.4,
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

/// Información general de la app: para quién está hecha y versión.
class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              const _CardEyebrow(text: 'Información'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Pago Listo está pensado para quienes manejan su dinero por '
                'quincena o por mes, y quieren evitar sorpresas de último '
                'momento con sus cuentas fijas.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const _FeatureDivider(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Versión',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '1.0.0',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardEyebrow extends StatelessWidget {
  final String text;

  const _CardEyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.accentGreen,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withOpacity(0.06),
      height: 1,
      thickness: 1,
    );
  }
}

/// Firma de autoría al pie de la pantalla.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 1,
            color: Colors.white.withOpacity(0.10),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Text(
            'SOSA TECH LAB',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 Todos los derechos reservados',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}