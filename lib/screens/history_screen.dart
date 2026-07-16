import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/core/formatters.dart';
import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/models/payment_history_entry.dart';

import '../services/lib/services/payments_controller.dart';

const List<String> _mesesEs = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String _mesAnio(DateTime fecha) => '${_mesesEs[fecha.month - 1]} ${fecha.year}';

/// Agrupa el historial por "Mes Año" y lo ordena: los meses más
/// recientes primero, y dentro de cada mes, los pagos más recientes
/// primero.
List<_HistoryGroup> _agruparPorMes(List<PaymentHistoryEntry> history) {
  final Map<String, List<PaymentHistoryEntry>> mapa = {};

  for (final entry in history) {
    final clave = _mesAnio(entry.fechaPago);
    mapa.putIfAbsent(clave, () => []).add(entry);
  }

  final grupos = mapa.entries.map((e) {
    final entradasOrdenadas = List<PaymentHistoryEntry>.from(e.value)
      ..sort((a, b) => b.fechaPago.compareTo(a.fechaPago));
    return _HistoryGroup(
      label: e.key,
      // Usamos el primer pago del grupo (ya ordenado desc) como
      // referencia para ordenar los grupos entre sí.
      fechaReferencia: entradasOrdenadas.first.fechaPago,
      entradas: entradasOrdenadas,
    );
  }).toList()
    ..sort((a, b) => b.fechaReferencia.compareTo(a.fechaReferencia));

  return grupos;
}

class _HistoryGroup {
  final String label;
  final DateTime fechaReferencia;
  final List<PaymentHistoryEntry> entradas;

  _HistoryGroup({
    required this.label,
    required this.fechaReferencia,
    required this.entradas,
  });

  double get total => entradas.fold(0.0, (sum, e) => sum + e.monto);
}

/// Pantalla de Historial: muestra todos los pagos que ya fueron
/// confirmados como realizados (ver
/// PaymentsController.registrarPagoYAvanzar), agrupados por mes, con
/// el total pagado en cada mes.
///
/// Escucha a PaymentsController igual que el resto de la app, así
/// que en cuanto se confirma un pago nuevo desde HomeScreen, esta
/// pantalla se actualiza sola sin recargar nada a mano.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    PaymentsController.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    PaymentsController.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final history = PaymentsController.instance.history;
    final grupos = _agruparPorMes(history);

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
                'Historial',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pagos que ya confirmaste',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: grupos.isEmpty
                    ? const _EmptyHistoryState()
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: grupos.length,
                  itemBuilder: (context, index) {
                    final grupo = grupos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _MonthGroup(group: grupo),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthGroup extends StatelessWidget {
  final _HistoryGroup group;

  const _MonthGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              group.label,
              style: GoogleFonts.montserrat(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              formatCurrency(group.total),
              style: GoogleFonts.montserrat(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...group.entradas.map(
              (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryTile(entry: entry),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PaymentHistoryEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: entry.categoria.color.withOpacity(0.14),
            ),
            child: Icon(
              entry.categoria.icon,
              color: entry.categoria.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nombre,
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
                  'Pagado el ${formatFechaCorta(entry.fechaPago)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                formatCurrency(entry.monto),
                style: GoogleFonts.montserrat(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentGreen,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
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
                Icons.history_rounded,
                color: AppColors.accentGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aún no tienes pagos en tu historial',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cuando confirmes un pago desde Inicio, aparecerá aquí.',
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
      ),
    );
  }
}