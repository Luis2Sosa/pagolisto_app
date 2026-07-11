import 'package:flutter/foundation.dart';

import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/services/local_storage_service.dart';

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

  Future<void> deletePayment(String id) async {
    await LocalStorageService.deletePayment(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  Future<void> togglePaid(String id) async {
    await LocalStorageService.togglePaymentPaid(id);
    _payments = await LocalStorageService.getPayments();
    notifyListeners();
  }

  List<Payment> byPeriod(PaymentPeriod period) =>
      _payments.where((p) => p.frecuencia == period).toList();

  double totalByPeriod(PaymentPeriod period) =>
      byPeriod(period).fold(0.0, (sum, p) => sum + p.monto);
}