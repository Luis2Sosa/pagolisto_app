/// Utilidades de formato compartidas por toda la app, para no
/// repetir esta lógica en cada pantalla.
library formatters;

const List<String> _mesesLargos = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const List<String> _mesesCortos = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

/// Formatea un monto como moneda, ej: 12450.5 -> "$12,450.50".
String formatCurrency(double value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final parts = absValue.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final decPart = parts[1];

  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final remaining = intPart.length - i;
    if (i != 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(intPart[i]);
  }

  final intFormatted = buffer.toString();
  return '${isNegative ? '-' : ''}\$$intFormatted.$decPart';
}

/// Fecha larga, ej: "18 / Julio / 2024".
String formatFechaLarga(DateTime date) {
  final mes = _mesesLargos[date.month - 1];
  return '${date.day} / $mes / ${date.year}';
}

/// Fecha corta, ej: "15 Jul".
String formatFechaCorta(DateTime date) {
  final mes = _mesesCortos[date.month - 1];
  return '${date.day} $mes';
}