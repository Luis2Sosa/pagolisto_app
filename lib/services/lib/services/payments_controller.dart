import 'package:flutter/foundation.dart';

import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/models/payment_history_entry.dart';
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
/// HomeScreen, AddPaymentScreen, HistoryScreen (y cualquier otra
/// pantalla) escuchan esta misma instancia (patrón singleton). En
/// cuanto se guarda, edita, borra o confirma un pago desde cualquier
/// lado, todos los que estén escuchando se refrescan solos — no hace
/// falta navegar de vuelta ni recargar manualmente, así que funciona
/// igual si usas Navigator.push o una barra de navegación con
/// IndexedStack.
class PaymentsController extends ChangeNotifier {
  PaymentsController._internal();
  static final PaymentsController instance = PaymentsController._internal();

  List<Payment> _payments = [];
  List<PaymentHistoryEntry> _history = [];
  bool _isLoaded = false;

  List<Payment> get payments => List.unmodifiable(_payments);

  /// Historial completo de pagos ya confirmados, sin ordenar. Para
  /// mostrarlo en pantalla, ordénalo por `fechaPago` (ver
  /// HistoryScreen, que lo agrupa por mes y lo ordena descendente).
  List<PaymentHistoryEntry> get history => List.unmodifiable(_history);

  bool get isLoaded => _isLoaded;

  /// Carga los pagos y el historial guardados. Solo hace falta
  /// llamarlo una vez al inicio de la app (por ejemplo desde
  /// HomeScreen); las siguientes pantallas que lean `payments` o
  /// `history` ya encontrarán los datos listos.
  Future<void> load() async {
    _payments = await LocalStorageService.getPayments();
    _history = await LocalStorageService.getHistory();
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

  /// Marca/desmarca un pago como pagado SIN mover su fecha y SIN
  /// crear una entrada de historial. Se deja disponible como
  /// respaldo (por ejemplo, para des-marcar un pago que haya
  /// quedado en estado "pagado" sin haber avanzado de fecha), pero
  /// el flujo normal de "ya pagué esto" debe usar
  /// [registrarPagoYAvanzar], que sí alimenta el Historial.
  Future<void> togglePaid(String id) async {
    await LocalStorageService.togglePaymentPaid(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  /// Flujo principal para confirmar que un pago recurrente ya se
  /// realizó:
  /// 1. Guarda una entrada permanente en el Historial con los datos
  ///    de este pago (nombre, monto, fecha en que se pagó).
  /// 2. En vez de dejar el pago marcado como "pagado" para siempre,
  ///    calcula la próxima fecha de cobro (según la frecuencia) y
  ///    actualiza el registro para ese nuevo ciclo, quedando como
  ///    pendiente otra vez.
  ///
  /// Así el pago "avanza" solo al próximo mes o quincena en vez de
  /// quedarse atorado en la fecha vieja, y el historial conserva un
  /// registro fijo de que ese pago se hizo.
  Future<Payment> registrarPagoYAvanzar(Payment payment) async {
    final nuevaFecha =
    proximaFechaParaFrecuencia(payment.fecha, payment.frecuencia);

    final entradaHistorial = PaymentHistoryEntry(
      id: '${payment.id}_${DateTime.now().microsecondsSinceEpoch}',
      paymentId: payment.id,
      nombre: payment.nombre,
      monto: payment.monto,
      categoria: payment.categoria,
      frecuencia: payment.frecuencia,
      fechaPago: DateTime.now(),
      fechaOriginal: payment.fecha,
    );
    await LocalStorageService.addHistoryEntry(entradaHistorial);

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
    _history = await LocalStorageService.getHistory();
    notifyListeners();
    return actualizado;
  }

  List<Payment> byPeriod(PaymentPeriod period) =>
      _payments.where((p) => p.frecuencia == period).toList();

  double totalByPeriod(PaymentPeriod period) =>
      byPeriod(period).fold(0.0, (sum, p) => sum + p.monto);
}