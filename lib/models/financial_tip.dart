import 'package:flutter/material.dart';

/// Un consejo financiero para cuidar los gastos.
///
/// El banco de consejos vive en [financialTips] (más abajo en este
/// mismo archivo) y es contenido curado, no calculado a partir de
/// los pagos del usuario — por eso no depende de PaymentsController
/// ni de ningún storage.
class FinancialTip {
  final String titulo;
  final String descripcion;

  /// Frase corta que resume el beneficio o la acción concreta,
  /// mostrada en verde y en negritas dentro de la tarjeta (ej. "Esto
  /// puede ahorrarte cientos de pesos al mes").
  final String highlight;

  final IconData icono;
  final Color color;

  const FinancialTip({
    required this.titulo,
    required this.descripcion,
    required this.highlight,
    required this.icono,
    required this.color,
  });
}

/// Banco de consejos. El orden no importa para la rotación (se
/// elige por índice calculado a partir de la fecha), pero conviene
/// mantenerlos variados para que dos días seguidos no se sientan
/// repetitivos.
const List<FinancialTip> financialTips = [
  FinancialTip(
    titulo: 'Revisa tus suscripciones',
    descripcion:
    'Streaming, música, gimnasio... es fácil perder la cuenta de a '
        'cuántas cosas estás pagando cada mes. Revisa tu lista de '
        'pagos y pregúntate: ¿de verdad uso todo esto?',
    highlight: 'Cancelar una sola suscripción que no usas ya es ganancia.',
    icono: Icons.subscriptions_rounded,
    color: Color(0xFFF87171),
  ),
  FinancialTip(
    titulo: 'La regla de las 24 horas',
    descripcion:
    'Antes de una compra que no estaba planeada, espera un día '
        'completo. La mayoría de los antojos de compra se enfrían '
        'solos con el tiempo.',
    highlight: 'Menos compras impulsivas, más control de tu dinero.',
    icono: Icons.timer_rounded,
    color: Color(0xFFFACC15),
  ),
  FinancialTip(
    titulo: 'Lo que no se anota, se olvida',
    descripcion:
    'Registrar cada pago, aunque sea pequeño, es lo que te deja ver '
        'el panorama completo de tus gastos en vez de solo suponerlo.',
    highlight: 'Por eso existe esta app: para que no se te escape nada.',
    icono: Icons.edit_note_rounded,
    color: Color(0xFF38BDF8),
  ),
  FinancialTip(
    titulo: 'Aparta antes de gastar',
    descripcion:
    'En vez de ahorrar "lo que sobre" a fin de mes, aparta tu '
        'ahorro apenas recibas tu pago. Lo que ya no ves, no lo '
        'gastas por accidente.',
    highlight: 'Ahorrar primero, gastar después.',
    icono: Icons.savings_rounded,
    color: Color(0xFF4ADE80),
  ),
  FinancialTip(
    titulo: 'Compara antes de comprar',
    descripcion:
    'Dedicar cinco minutos a comparar precios entre dos o tres '
        'lugares antes de una compra grande casi siempre vale la pena.',
    highlight: 'Cinco minutos de comparar pueden ahorrarte horas de trabajo.',
    icono: Icons.compare_arrows_rounded,
    color: Color(0xFFA78BFA),
  ),
  FinancialTip(
    titulo: 'Cuidado con el gasto hormiga',
    descripcion:
    'Un café, una app, una propina extra... son montos chicos que '
        'por separado no se sienten, pero sumados al mes pueden ser '
        'más de lo que crees.',
    highlight: 'Súmalos una vez este mes; te va a sorprender el total.',
    icono: Icons.coffee_rounded,
    color: Color(0xFFFB923C),
  ),
  FinancialTip(
    titulo: 'Un fondo para lo inesperado',
    descripcion:
    'Un fondo de emergencia no es para "algún día": es para que un '
        'imprevisto no te obligue a usar tarjeta de crédito o pedir '
        'prestado.',
    highlight: 'Empieza chico. Lo importante es que exista.',
    icono: Icons.shield_rounded,
    color: Color(0xFF34D399),
  ),
  FinancialTip(
    titulo: 'Paga tu tarjeta completa',
    descripcion:
    'Pagar solo el mínimo de la tarjeta de crédito hace que los '
        'intereses se acumulen mes con mes, y el saldo nunca baja de '
        'verdad.',
    highlight: 'Pagar el total evita que la deuda crezca sola.',
    icono: Icons.credit_card_off_rounded,
    color: Color(0xFFF472B6),
  ),
  FinancialTip(
    titulo: 'Automatiza lo que puedas',
    descripcion:
    'Programar tus pagos fijos (renta, luz, internet) evita '
        'recargos por olvido y te quita una preocupación de la '
        'cabeza cada quincena.',
    highlight: 'Menos que recordar, menos que se te pase.',
    icono: Icons.autorenew_rounded,
    color: Color(0xFF60A5FA),
  ),
  FinancialTip(
    titulo: 'Ponle nombre a tus metas',
    descripcion:
    'No es lo mismo "ahorrar" que "ahorrar para el enganche del '
        'coche". Una meta con nombre y fecha es mucho más fácil de '
        'cumplir que una intención vaga.',
    highlight: 'Las metas concretas se cumplen; las vagas se olvidan.',
    icono: Icons.flag_rounded,
    color: Color(0xFF2DD4BF),
  ),
];

/// Devuelve el consejo que corresponde a "hoy", de forma que sea el
/// mismo durante todo el día y cambie automáticamente al día
/// siguiente. Rota por todo [financialTips] y luego vuelve a
/// empezar.
///
/// Se puede pasar [ahora] explícitamente para pruebas; si se omite,
/// usa la fecha real del dispositivo.
FinancialTip tipDelDia({DateTime? ahora}) {
  final fecha = ahora ?? DateTime.now();
  final diaDelAnio = fecha.difference(DateTime(fecha.year, 1, 1)).inDays;
  final indice = diaDelAnio % financialTips.length;
  return financialTips[indice];
}

/// Número de consejo del día (1-based) dentro del ciclo, solo para
/// mostrar algo como "Consejo 4 de 10" en la pantalla.
int numeroDeTipDelDia({DateTime? ahora}) {
  final fecha = ahora ?? DateTime.now();
  final diaDelAnio = fecha.difference(DateTime(fecha.year, 1, 1)).inDays;
  return (diaDelAnio % financialTips.length) + 1;
}