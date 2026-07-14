import 'package:flutter/foundation.dart';

import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/services/local_storage_service.dart';

/// Calcula la próxima fecha de cobro de un pago recurrente a partir
/// de su fecha actual y su frecuencia.
///
/// - Quincenal: suma 15 días.
/// - Mensual: mismo día, un mes después (si el mes siguiente tiene
///   menos días que ese número de día, usa el último día de ese mes;
///   ej. 31 de enero -> 28/29 de febrero).
DateTime proximaFechaParaFrecuencia(
    DateTime fechaActual,
    PaymentPeriod frecuencia,
    ) {
  if (frecuencia == PaymentPeriod.quincenal) {
    return fechaActual.add(const Duration(days: 15));
  }

  final anioBase = fechaActual.year;
  final mesBase = fechaActual.month;
  final anio = mesBase == 12 ? anioBase + 1 : anioBase;
  final mes = mesBase == 12 ? 1 : mesBase + 1;

  // Día 0 del mes siguiente al que buscamos = último día del mes
  // que buscamos.
  final ultimoDiaDelMesSiguiente = DateTime(anio, mes + 1, 0).day;
  final dia = fechaActual.day > ultimoDiaDelMesSiguiente
      ? ultimoDiaDelMesSiguiente
      : fechaActual.day;

  return DateTime(anio, mes, dia);
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

  /// Marca/desmarca un pago como pagado SIN mover su fecha. Se deja
  /// disponible como respaldo (por ejemplo, para des-marcar un pago
  /// que haya quedado en estado "pagado" sin haber avanzado de
  /// fecha), pero el flujo normal de "ya pagué esto" debe usar
  /// [registrarPagoYAvanzar].
  Future<void> togglePaid(String id) async {
    await LocalStorageService.togglePaymentPaid(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  /// Flujo principal para confirmar que un pago recurrente ya se
  /// realizó: en vez de dejarlo marcado como "pagado" para siempre,
  /// calcula la próxima fecha de cobro (según la frecuencia) y
  /// actualiza el registro para ese nuevo ciclo, quedando como
  /// pendiente otra vez. Así el pago "avanza" solo al próximo mes o
  /// quincena en vez de quedarse atorado en la fecha vieja.
  Future<Payment> registrarPagoYAvanzar(Payment payment) async {
    final nuevaFecha =
    proximaFechaParaFrecuencia(payment.fecha, payment.frecuencia);

    final actualizado = Payment(
      id: payment.id,
      nombre: payment.nombre,
      monto: payment.monto,
      frecuencia: payment.frecuencia,
      fecha: nuevaFecha,
      notas: payment.notas,
      categoria: payment.categoria,
      pagado: false,
    );

    await LocalStorageService.deletePayment(payment.id);
    await LocalStorageService.addPayment(actualizado);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
    return actualizado;
  }

  List<Payment> byPeriod(PaymentPeriod period) =>
      _payments.where((p) => p.frecuencia == period).toList();

  double totalByPeriod(PaymentPeriod period) =>
      byPeriod(period).fold(0.0, (sum, p) => sum + p.monto);
}