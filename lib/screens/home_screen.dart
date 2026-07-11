import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/core/formatters.dart';
import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/services/local_storage_service.dart';

import '../services/lib/services/payments_controller.dart';

/// Pantalla principal: saluda al usuario por su nombre, permite
/// alternar entre vista quincenal/mensual y muestra los próximos
/// pagos registrados.
///
/// Escucha a PaymentsController, así que en cuanto se guarda un
/// pago nuevo desde AddPaymentScreen (sea por Navigator.push o
/// desde otra pestaña de un IndexedStack), esta pantalla se
/// actualiza sola, sin recargar nada a mano.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  bool _isLoading = true;
  PaymentPeriod _selectedPeriod = PaymentPeriod.quincenal;

  @override
  void initState() {
    super.initState();
    PaymentsController.instance.addListener(_onPaymentsChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    PaymentsController.instance.removeListener(_onPaymentsChanged);
    super.dispose();
  }

  void _onPaymentsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    final name = await LocalStorageService.getUserName();
    if (!PaymentsController.instance.isLoaded) {
      await PaymentsController.instance.load();
    }
    if (!mounted) return;
    setState(() {
      _userName = name;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = PaymentsController.instance;
    final payments = List<Payment>.from(controller.byPeriod(_selectedPeriod))
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final total = controller.totalByPeriod(_selectedPeriod);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.accentGreen,
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(name: _userName),
                const SizedBox(height: 20),
                _PeriodToggle(
                  selected: _selectedPeriod,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),
                const SizedBox(height: 20),
                _TotalCard(period: _selectedPeriod, total: total),
                const SizedBox(height: 28),
                Text(
                  'Próximos Pagos',
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                if (payments.isEmpty)
                  const _EmptyPaymentsState()
                else
                  ...payments.map(
                        (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PaymentTile(payment: payment),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;

  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAGO LISTO',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.accentGreen,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name.isEmpty ? '¡Hola!' : '¡Hola, $name!',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        _SettingsButton(
          onTap: () {
            // TODO: navegar a la pantalla de Configuración cuando
            // esté lista (borrar cuenta, notificaciones, etc.).
          },
        ),
      ],
    );
  }
}

/// Botón circular de acceso a Configuración (borrar cuenta,
/// notificaciones, etc.).
class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final PaymentPeriod selected;
  final ValueChanged<PaymentPeriod> onChanged;

  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: PaymentPeriod.values.map((period) {
          final isSelected = period == selected;
          return Expanded(
            child: _ToggleOption(
              label: period.label,
              isSelected: isSelected,
              onTap: () => onChanged(period),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? AppColors.accentGreen.withOpacity(0.18)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.accentGreen : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final PaymentPeriod period;
  final double total;

  const _TotalCard({required this.period, required this.total});

  @override
  Widget build(BuildContext context) {
    final label = period == PaymentPeriod.quincenal
        ? 'Total quincenal'
        : 'Total mensual';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(total),
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un pago dentro de "Próximos Pagos". Tocarla marca o
/// desmarca el pago como pagado.
class _PaymentTile extends StatelessWidget {
  final Payment payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PaymentsController.instance.togglePaid(payment.id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: payment.categoria.color.withOpacity(0.14),
              ),
              child: Icon(
                payment.categoria.icon,
                color: payment.categoria.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatFechaCorta(payment.fecha),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(payment.monto),
                  style: GoogleFonts.montserrat(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  payment.pagado
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: payment.pagado
                      ? AppColors.accentGreen
                      : AppColors.textMuted.withOpacity(0.5),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPaymentsState extends StatelessWidget {
  const _EmptyPaymentsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          style: BorderStyle.solid,
        ),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGreen.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.accentGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aún no tienes pagos registrados',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca "Añadir" para registrar tu primer pago.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}