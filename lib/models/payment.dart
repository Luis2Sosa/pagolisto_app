import 'package:flutter/material.dart';

/// Frecuencia con la que se repite un pago.
enum PaymentPeriod { quincenal, mensual }

extension PaymentPeriodX on PaymentPeriod {
  String get label => this == PaymentPeriod.quincenal ? 'Quincenal' : 'Mensual';
}

/// Categoría de un pago: define el ícono y el color con el que se
/// muestra en las tarjetas de "Próximos Pagos".
enum PaymentCategory { casa, luz, agua, internet, netflix, tarjeta, otro }

extension PaymentCategoryX on PaymentCategory {
  IconData get icon {
    switch (this) {
      case PaymentCategory.casa:
        return Icons.home_rounded;
      case PaymentCategory.luz:
        return Icons.lightbulb_rounded;
      case PaymentCategory.agua:
        return Icons.water_drop_rounded;
      case PaymentCategory.internet:
        return Icons.wifi_rounded;
      case PaymentCategory.netflix:
        return Icons.smart_display_rounded;
      case PaymentCategory.tarjeta:
        return Icons.credit_card_rounded;
      case PaymentCategory.otro:
        return Icons.receipt_long_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PaymentCategory.casa:
        return const Color(0xFF4ADE80);
      case PaymentCategory.luz:
        return const Color(0xFFFACC15);
      case PaymentCategory.agua:
        return const Color(0xFF38BDF8);
      case PaymentCategory.internet:
        return const Color(0xFFA78BFA);
      case PaymentCategory.netflix:
        return const Color(0xFFF87171);
      case PaymentCategory.tarjeta:
        return const Color(0xFFFB923C);
      case PaymentCategory.otro:
        return const Color(0xFF9CA3AF);
    }
  }

  String get label {
    switch (this) {
      case PaymentCategory.casa:
        return 'Casa';
      case PaymentCategory.luz:
        return 'Luz';
      case PaymentCategory.agua:
        return 'Agua';
      case PaymentCategory.internet:
        return 'Internet';
      case PaymentCategory.netflix:
        return 'Netflix';
      case PaymentCategory.tarjeta:
        return 'Tarjeta';
      case PaymentCategory.otro:
        return 'Otro';
    }
  }
}

/// Un pago recurrente registrado por el usuario (renta, luz,
/// internet, suscripciones, etc.).
class Payment {
  final String id;
  final String nombre;
  final double monto;
  final PaymentPeriod frecuencia;
  final DateTime fecha;
  final String notas;
  final PaymentCategory categoria;
  final bool pagado;

  const Payment({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.frecuencia,
    required this.fecha,
    this.notas = '',
    this.categoria = PaymentCategory.otro,
    this.pagado = false,
  });

  Payment copyWith({
    String? id,
    String? nombre,
    double? monto,
    PaymentPeriod? frecuencia,
    DateTime? fecha,
    String? notas,
    PaymentCategory? categoria,
    bool? pagado,
  }) {
    return Payment(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      monto: monto ?? this.monto,
      frecuencia: frecuencia ?? this.frecuencia,
      fecha: fecha ?? this.fecha,
      notas: notas ?? this.notas,
      categoria: categoria ?? this.categoria,
      pagado: pagado ?? this.pagado,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'monto': monto,
    'frecuencia': frecuencia.name,
    'fecha': fecha.toIso8601String(),
    'notas': notas,
    'categoria': categoria.name,
    'pagado': pagado,
  };

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      monto: (json['monto'] as num).toDouble(),
      frecuencia: PaymentPeriod.values.firstWhere(
            (e) => e.name == json['frecuencia'],
        orElse: () => PaymentPeriod.mensual,
      ),
      fecha: DateTime.parse(json['fecha'] as String),
      notas: json['notas'] as String? ?? '',
      categoria: PaymentCategory.values.firstWhere(
            (e) => e.name == json['categoria'],
        orElse: () => PaymentCategory.otro,
      ),
      pagado: json['pagado'] as bool? ?? false,
    );
  }
}