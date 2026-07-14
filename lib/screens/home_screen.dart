import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/core/formatters.dart';
import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/services/local_storage_service.dart';

import '../services/lib/services/payments_controller.dart';

// TODO: ajusta este import al path real de tu pantalla de
// agregar/editar pago si es distinto.
import 'add_payment_screen.dart';

/// Devuelve true si un pago está vencido: la fecha ya llegó (hoy o
/// antes) y todavía no se ha marcado como pagado.
///
/// TODO (futuro): antes de llegar a este punto, mandar una
/// notificación push X días antes de `payment.fecha` para avisar
/// que el pago se acerca.
bool _esPagoVencido(Payment payment) {
  if (payment.pagado) return false;
  final ahora = DateTime.now();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final fecha = DateTime(
    payment.fecha.year,
    payment.fecha.month,
    payment.fecha.day,
  );
  return !fecha.isAfter(hoy); // fecha <= hoy
}

/// Muestra un diálogo de confirmación al tocar un pago.
///
/// - Si el pago está pendiente: confirma que ya se pagó y, al
///   aceptar, llama a `registrarPagoYAvanzar`, que actualiza la
///   fecha al próximo ciclo (mes o quincena siguiente) y lo deja
///   pendiente para esa nueva fecha. Por eso un pago recién pagado
///   nunca se queda "marcado y oscuro": pasa a ser el próximo pago
///   pendiente, con su fecha ya actualizada.
/// - Si el pago quedó marcado como pagado sin avanzar de fecha
///   (caso raro/legado), permite desmarcarlo manualmente.
Future<void> _confirmarCambioEstado(
    BuildContext context,
    Payment payment,
    ) async {
  if (payment.pagado) {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Marcar como pendiente?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '"${payment.nombre}" volverá a aparecer como pendiente en '
              '"Próximos Pagos".',
          style: GoogleFonts.montserrat(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Sí, marcar pendiente',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800,
                color: Colors.orangeAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await PaymentsController.instance.togglePaid(payment.id);
    }
    return;
  }

  final proximaFecha =
  proximaFechaParaFrecuencia(payment.fecha, payment.frecuencia);

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF16221C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '¿Ya realizaste este pago?',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Se registrará "${payment.nombre}" (${formatCurrency(payment.monto)}) '
            'como pagado y la fecha se actualizará automáticamente a '
            '${formatFechaLarga(proximaFecha)}.',
        style: GoogleFonts.montserrat(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancelar',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'Confirmar',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              color: AppColors.accentGreen,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmado == true) {
    await PaymentsController.instance.registrarPagoYAvanzar(payment);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16221C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            '"${payment.nombre}" pagado. Próxima fecha: '
                '${formatFechaCorta(proximaFecha)}',
            style: GoogleFonts.montserrat(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}

/// Pantalla principal: saluda al usuario por su nombre, permite
/// alternar entre vista quincenal/mensual y muestra los próximos
/// pagos registrados.
///
/// Escucha a PaymentsController, así que en cuanto se guarda un
/// pago nuevo desde AddPaymentScreen (sea por Navigator.push o
/// desde otra pestaña de un IndexedStack), esta pantalla se
/// actualiza sola, sin recargar nada a mano.
///
/// El estado es público (`HomeScreenState`, no `_HomeScreenState`)
/// para que MainNavigationScreen pueda tomarlo con un GlobalKey y
/// llamar a `refreshSelectedPeriod()` cada vez que el usuario vuelve
/// a esta pestaña — necesario porque, al vivir dentro de un
/// IndexedStack, `initState()` solo corre una vez y no se repite
/// cada vez que se re-selecciona el tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
      _selectedPeriod = _periodWithMorePayments();
    });
  }

  /// Recalcula y aplica la pestaña (quincenal/mensual) con más
  /// pagos. Se llama cada vez que el usuario regresa a Inicio desde
  /// otra pestaña, para que siempre abra donde hay más pagos,
  /// aunque el usuario la haya cambiado manualmente la vez anterior.
  void refreshSelectedPeriod() {
    if (!mounted) return;
    setState(() {
      _selectedPeriod = _periodWithMorePayments();
    });
  }

  /// Devuelve la pestaña (quincenal/mensual) que tiene más pagos
  /// registrados. Si hay empate, se queda en quincenal por defecto.
  PaymentPeriod _periodWithMorePayments() {
    final controller = PaymentsController.instance;
    final quincenalCount = controller.byPeriod(PaymentPeriod.quincenal).length;
    final mensualCount = controller.byPeriod(PaymentPeriod.mensual).length;
    return mensualCount > quincenalCount
        ? PaymentPeriod.mensual
        : PaymentPeriod.quincenal;
  }

  void _openEditPayment(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPaymentScreen(paymentToEdit: payment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PaymentsController.instance;
    final payments = List<Payment>.from(controller.byPeriod(_selectedPeriod))
      ..sort((a, b) {
        // Los pagados (caso raro/legado) siempre van al final.
        if (a.pagado != b.pagado) {
          return a.pagado ? 1 : -1;
        }
        // Entre los pendientes, los más urgentes (fecha más cercana
        // o ya vencida) van primero (arriba).
        final byFecha = a.fecha.compareTo(b.fecha);
        if (byFecha != 0) return byFecha;
        // Desempate estable si dos pagos caen el mismo día.
        return a.nombre.compareTo(b.nombre);
      });
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
                      child: _PaymentTile(
                        payment: payment,
                        onEdit: () => _openEditPayment(payment),
                      ),
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

/// Tarjeta de un pago dentro de "Próximos Pagos".
///
/// - Tocar la tarjeta abre un diálogo de confirmación. Si se
///   confirma el pago, la fecha avanza sola al próximo ciclo (ver
///   `registrarPagoYAvanzar`), así que la tarjeta nunca se queda
///   marcada y oscura: vuelve a verse como un pago pendiente normal,
///   solo que con la fecha ya actualizada.
/// - Tocar el ícono de lápiz abre la pantalla de edición del pago.
/// - Si el pago está vencido (la fecha ya llegó) y no se ha
///   pagado, la tarjeta se pinta en rojo.
class _PaymentTile extends StatelessWidget {
  final Payment payment;
  final VoidCallback onEdit;

  const _PaymentTile({required this.payment, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isOverdue = _esPagoVencido(payment);

    final borderColor = isOverdue
        ? Colors.redAccent.withOpacity(0.45)
        : Colors.white.withOpacity(0.08);
    final backgroundColor = isOverdue
        ? Colors.redAccent.withOpacity(0.06)
        : Colors.white.withOpacity(0.03);
    final nameColor =
    isOverdue ? Colors.redAccent : AppColors.textPrimary;
    final dateColor =
    isOverdue ? Colors.redAccent.withOpacity(0.85) : AppColors.textMuted;

    return GestureDetector(
      onTap: () => _confirmarCambioEstado(context, payment),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOverdue
                    ? Colors.redAccent.withOpacity(0.14)
                    : payment.categoria.color.withOpacity(0.14),
              ),
              child: Icon(
                payment.categoria.icon,
                color: isOverdue ? Colors.redAccent : payment.categoria.color,
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
                      color: nameColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOverdue
                        ? '${formatFechaCorta(payment.fecha)} · Vencido'
                        : formatFechaCorta(payment.fecha),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dateColor,
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
                    color: isOverdue ? Colors.redAccent : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  payment.pagado
                      ? Icons.check_circle_rounded
                      : (isOverdue
                      ? Icons.error_rounded
                      : Icons.radio_button_unchecked_rounded),
                  color: payment.pagado
                      ? AppColors.accentGreen
                      : (isOverdue
                      ? Colors.redAccent
                      : AppColors.textMuted.withOpacity(0.5)),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
              ),
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