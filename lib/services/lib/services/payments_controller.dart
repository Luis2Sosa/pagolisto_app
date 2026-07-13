import 'package:flutter/foundation.dart';

import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/services/local_storage_service.dart';

/// Calcula la fecha del siguiente ciclo de un pago recurrente, a
/// partir de su fecha actual y su frecuencia.
///
/// - Quincenal: suma 15 días.
/// - Mensual: suma un mes completo, ajustando meses más cortos
///   (ej. 31 de enero -> 28/29 de febrero).
DateTime siguienteFechaDePago(DateTime fecha, PaymentPeriod frecuencia) {
  if (frecuencia == PaymentPeriod.quincenal) {
    return fecha.add(const Duration(days: 15));
  }

  final nextMonth = fecha.month == 12 ? 1 : fecha.month + 1;
  final nextYear = fecha.month == 12 ? fecha.year + 1 : fecha.year;
  final ultimoDiaDelSiguienteMes = DateTime(nextYear, nextMonth + 1, 0).day;
  final dia = fecha.day <= ultimoDiaDelSiguienteMes
      ? fecha.day
      : ultimoDiaDelSiguienteMes;
  return DateTime(nextYear, nextMonth, dia);
}

/// Controlador central del estado de pagos.
///
/// HomeScreen, AddPaymentScreen (y cualquier otra pantalla) escuchan
/// esta misma instancia (patrón singleton). En cuanto se guarda,
/// edita o borra un pago desde cualquier lado, todos los que estén
/// escuchando se refrescan solos — no hace falta navegar de vuelta
/// ni recargar manualmente, así que funciona igual si usas
/// Navigator.push o una barra de navegación con IndexedStack.
class PaymentsController extends ChangeNotifier {
  PaymentsController._internal();
  static final PaymentsController instance = PaymentsController._internal();

  List<Payment> _payments = [];
  bool _isLoaded = false;

  List<Payment> get payments => List.unmodifiable(_payments);
  bool get isLoaded => _isLoaded;

  /// Carga los pagos guardados. Solo hace falta llamarlo una vez al
  /// inicio de la app (por ejemplo desde HomeScreen); las siguientes
  /// pantallas que lean `payments` ya encontrarán los datos listos.
  Future<void> load() async {
    _payments = await LocalStorageService.getPayments();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addPayment(Payment payment) async {
    await LocalStorageService.addPayment(payment);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  /// Actualiza un pago ya existente (mismo `id`) con los datos
  /// nuevos que vengan en [payment]. Se apoya en los métodos que ya
  /// existen en LocalStorageService: borra el registro viejo por id
  /// y guarda el nuevo en su lugar, para no depender de que
  /// LocalStorageService tenga un método de "update" propio.
  Future<void> updatePayment(Payment payment) async {
    await LocalStorageService.deletePayment(payment.id);
    await LocalStorageService.addPayment(payment);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  Future<void> deletePayment(String id) async {
    await LocalStorageService.deletePayment(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  /// Alterna el estado pagado/pendiente sin tocar la fecha. Se deja
  /// disponible por si otra pantalla (ej. Historial) lo necesita,
  /// pero la pantalla principal usa `confirmarPago` en su lugar.
  Future<void> togglePaid(String id) async {
    await LocalStorageService.togglePaymentPaid(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  /// Confirma que un pago recurrente ya se realizó: en vez de solo
  /// marcarlo como pagado y dejarlo ahí, avanza automáticamente su
  /// fecha al siguiente ciclo (quincena o mes) y lo deja como
  /// pendiente para esa nueva fecha. Así el pago "vencido" de julio
  /// se convierte, solo, en el pago de agosto — sin quedarse
  /// marcado ni oscurecido en la lista.
  Future<Payment> confirmarPago(Payment payment) async {
    final actualizado = Payment(
      id: payment.id,
      nombre: payment.nombre,
      monto: payment.monto,
      frecuencia: payment.frecuencia,
      fecha: siguienteFechaDePago(payment.fecha, payment.frecuencia),
      notas: payment.notas,
      categoria: payment.categoria,
      pagado: false,
    );
    await updatePayment(actualizado);
    return actualizado;
  }

  List<Payment> byPeriod(PaymentPeriod period) =>
      _payments.where((p) => p.frecuencia == period).toList();

  double totalByPeriod(PaymentPeriod period) =>
      byPeriod(period).fold(0.0, (sum, p) => sum + p.monto);
}