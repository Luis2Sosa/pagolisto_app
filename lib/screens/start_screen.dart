import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/screens/about_screen.dart';
import 'package:pagolisto/screens/welcome_name_screen.dart';
import 'package:pagolisto/services/local_storage_service.dart';

/// Pantalla de bienvenida general de "Pago Listo".
///
/// Es la primera vista que ve cualquier usuario, antes de registrarse
/// o iniciar sesión.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<void> _onEnter(BuildContext context) async {
    final hasName = await LocalStorageService.hasUserName();

    if (!context.mounted) return;

    if (!hasName) {
      // Primera vez: pide el nombre antes de ir a Inicio.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const WelcomeNameScreen(),
        ),
      );
    } else {
      // Ya tiene nombre guardado: va directo a Inicio.
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 1),

                const _Logo(),

                const Spacer(flex: 1),

                const _NoveltiesCard(),

                const Spacer(flex: 2),

                _PrimaryButton(
                  label: 'ENTRAR',
                  onTap: () => _onEnter(context),
                ),

                const SizedBox(height: 14),

                _SecondaryButton(
                  label: 'ACERCA DE PAGO LISTO',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/listo.png',
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    );
  }
}


/// Tarjeta con encabezado, novedades y badge de confianza.
class _NoveltiesCard extends StatelessWidget {
  const _NoveltiesCard();

  static const List<_NoveltyItem> _items = [
    _NoveltyItem(
      icon: Icons.calendar_month_rounded,
      text: 'Organiza tus gastos quincenales y mensuales',
    ),
    _NoveltyItem(
      icon: Icons.notifications_active_rounded,
      text: 'Recordatorios antes de cada fecha de pago',
    ),
    _NoveltyItem(
      icon: Icons.lightbulb_rounded,
      text: 'Consejos financieros para ahorrar más cada mes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOVEDADES',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentGreen,
                  letterSpacing: 1.2,
                ),
              ),
              const _FreeBadge(),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Controla tus pagos quincenales y mensuales, sin complicaciones.',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 22),

          for (int i = 0; i < _items.length; i++) ...[
            _NoveltyRow(item: _items[i]),
            if (i != _items.length - 1) const SizedBox(height: 16),
          ],

          const SizedBox(height: 22),
          Divider(color: Colors.white.withOpacity(0.10), height: 1),
          const SizedBox(height: 16),

          const _TrustRow(),
        ],
      ),
    );
  }
}

class _NoveltyItem {
  final IconData icon;
  final String text;

  const _NoveltyItem({required this.icon, required this.text});
}

class _NoveltyRow extends StatelessWidget {
  final _NoveltyItem item;

  const _NoveltyRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentGreen.withOpacity(0.15),
          ),
          child: Icon(
            item.icon,
            size: 19,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            item.text,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}


/// Badge pequeño de "100% gratis" — a la gente le gusta verlo de entrada.
class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.accentGreen.withOpacity(0.15),
      ),
      child: Text(
        '100% GRATIS',
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.accentGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


/// Fila de confianza: seguridad de datos.
class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.lock_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          'Tus datos, siempre protegidos',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


/// Botón principal.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Botón secundario.
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
              color: Colors.white.withOpacity(0.03),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}