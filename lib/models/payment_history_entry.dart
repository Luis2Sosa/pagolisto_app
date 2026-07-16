import 'package:pagolisto/models/payment.dart';

/// Registro histórico de un pago ya confirmado como realizado.
///
/// Se crea automáticamente cada vez que el usuario confirma "¿Ya
/// realizaste este pago?" (ver PaymentsController.registrarPagoYAvanzar).
/// A diferencia de [Payment] — que representa el PRÓXIMO cobro
/// pendiente y va cambiando de fecha cada vez que se paga — un
/// [PaymentHistoryEntry] es una fotografía fija de un pago que ya
/// se hizo: una vez creado, nunca vuelve a cambiar. Por eso el
/// historial puede mostrar meses pasados de forma confiable, aunque
/// el pago original ya haya "avanzado" a una fecha futura.
class PaymentHistoryEntry {
  /// Id propio de esta entrada de historial (no es el id del pago
  /// recurrente, porque un mismo pago recurrente genera muchas
  /// entradas de historial a lo largo del tiempo).
  final String id;

  /// Id del [Payment] recurrente del que proviene este pago, por si
  /// en el futuro se quiere navegar "ver todos los pagos de Luz".
  final String paymentId;

  final String nombre;
  final double monto;
  final PaymentCategory categoria;
  final PaymentPeriod frecuencia;

  /// Momento en que el usuario confirmó el pago (lo que se muestra
  /// en el historial).
  final DateTime fechaPago;

  /// Fecha de cobro que tenía el pago originalmente (antes de
  /// avanzar al siguiente ciclo). Se guarda por si más adelante se
  /// quiere distinguir pagos hechos a tiempo vs. tarde.
  final DateTime fechaOriginal;

  const PaymentHistoryEntry({
    required this.id,
    required this.paymentId,
    required this.nombre,
    required this.monto,
    required this.categoria,
    required this.frecuencia,
    required this.fechaPago,
    required this.fechaOriginal,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'paymentId': paymentId,
    'nombre': nombre,
    'monto': monto,
    'categoria': categoria.name,
    'frecuencia': frecuencia.name,
    'fechaPago': fechaPago.toIso8601String(),
    'fechaOriginal': fechaOriginal.toIso8601String(),
  };

  factory PaymentHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryEntry(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      nombre: json['nombre'] as String,
      monto: (json['monto'] as num).toDouble(),
      categoria: PaymentCategory.values.firstWhere(
            (e) => e.name == json['categoria'],
        orElse: () => PaymentCategory.otro,
      ),
      frecuencia: PaymentPeriod.values.firstWhere(
            (e) => e.name == json['frecuencia'],
        orElse: () => PaymentPeriod.mensual,
      ),
      fechaPago: DateTime.parse(json['fechaPago'] as String),
      fechaOriginal: DateTime.parse(json['fechaOriginal'] as String),
    );
  }
}