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
  FinancialTip(
    titulo: 'Usa efectivo para tus gastos variables',
    descripcion:
    'Sacar un presupuesto semanal en efectivo para comida, salidas '
        'o antojos hace que el gasto se sienta real, a diferencia de '
        'una tarjeta que nunca "se acaba".',
    highlight: 'Ver el dinero salir de tu mano cambia cómo lo gastas.',
    icono: Icons.payments_rounded,
    color: Color(0xFF4ADE80),
  ),
  FinancialTip(
    titulo: '¿Lo necesito o lo quiero?',
    descripcion:
    'Antes de pagar, hazte esta pregunta en voz alta. No se trata '
        'de no darte gustos nunca, sino de hacerlo de forma '
        'consciente y no automática.',
    highlight: 'Un segundo de pausa evita muchos arrepentimientos.',
    icono: Icons.psychology_alt_rounded,
    color: Color(0xFFFACC15),
  ),
  FinancialTip(
    titulo: 'Revisa tu estado de cuenta cada semana',
    descripcion:
    'Los cargos duplicados, las renovaciones que se te olvidaron o '
        'los errores bancarios se resuelven fácil si los detectas a '
        'tiempo, y muy difícil si los notas meses después.',
    highlight: 'Cinco minutos a la semana valen más que una sorpresa a fin de mes.',
    icono: Icons.fact_check_rounded,
    color: Color(0xFF38BDF8),
  ),
  FinancialTip(
    titulo: 'No toda oferta es un ahorro real',
    descripcion:
    'Algunas tiendas suben el precio unos días antes de la "oferta" '
        'para que el descuento se vea más grande de lo que es. '
        'Compara con el precio de antes si puedes.',
    highlight: 'Un descuento solo ahorra si de verdad ibas a comprarlo.',
    icono: Icons.local_offer_rounded,
    color: Color(0xFFF87171),
  ),
  FinancialTip(
    titulo: 'Un presupuesto no es una cárcel',
    descripcion:
    'Piensa en tu presupuesto como un mapa, no como una lista de '
        'prohibiciones. Un mapa te dice a dónde puedes ir sin '
        'perderte, no te encierra en un solo camino.',
    highlight: 'Planear no es limitarte: es decidir tú, no el saldo.',
    icono: Icons.map_rounded,
    color: Color(0xFFA78BFA),
  ),
  FinancialTip(
    titulo: 'Cocina para varios días',
    descripcion:
    'Preparar comida para dos o tres días de una sola vez reduce '
        'tanto el tiempo en la cocina como la tentación de pedir '
        'algo a domicilio "porque ya no hay nada que comer".',
    highlight: 'Menos pedidos de última hora, menos gasto sin planear.',
    icono: Icons.restaurant_rounded,
    color: Color(0xFFFB923C),
  ),
  FinancialTip(
    titulo: 'Negocia tus tarifas fijas',
    descripcion:
    'Internet, cable, plan de celular... muchas veces una llamada '
        'para preguntar por promociones vigentes baja el pago sin '
        'cambiar de proveedor.',
    highlight: 'Una llamada de diez minutos puede bajar tu recibo cada mes.',
    icono: Icons.support_agent_rounded,
    color: Color(0xFF34D399),
  ),
  FinancialTip(
    titulo: 'El tiempo hace crecer hasta lo poco',
    descripcion:
    'Ahorrar una cantidad pequeña pero constante, desde ahora, '
        'termina sumando más de lo que parece cuando le das tiempo '
        'para crecer.',
    highlight: 'Empezar hoy con poco vale más que esperar a tener mucho.',
    icono: Icons.trending_up_rounded,
    color: Color(0xFF60A5FA),
  ),
  FinancialTip(
    titulo: 'Registra hasta lo más chico',
    descripcion:
    'Un pago de 20 no parece importante por sí solo, pero si se te '
        'olvida anotar varios de esos a la semana, tu control de '
        'gastos deja de ser real.',
    highlight: 'Un registro completo, aunque sea de montos chicos, vale más que uno "casi" completo.',
    icono: Icons.checklist_rounded,
    color: Color(0xFF2DD4BF),
  ),
  FinancialTip(
    titulo: 'Identifica tus gatillos de gasto',
    descripcion:
    'Aburrimiento, estrés, cansancio... muchas compras no planeadas '
        'nacen de una emoción, no de una necesidad real. Notarlo es '
        'el primer paso para pausarlo.',
    highlight: 'Reconocer el gatillo te da la opción de elegir distinto.',
    icono: Icons.self_improvement_rounded,
    color: Color(0xFFF472B6),
  ),
  FinancialTip(
    titulo: 'Revisa tus renovaciones automáticas',
    descripcion:
    'Muchas apps y servicios se renuevan solos y te avisan poco o '
        'nada antes de cobrarte otro periodo. Revisa las fechas de '
        'corte de lo que tengas activo.',
    highlight: 'Cancelar a tiempo es mucho más fácil que pedir un reembolso.',
    icono: Icons.event_repeat_rounded,
    color: Color(0xFFF87171),
  ),
  FinancialTip(
    titulo: 'Duerme antes de una compra grande',
    descripcion:
    'Para decisiones de dinero importantes, dale una noche de por '
        'medio. Con la cabeza descansada es más fácil ver si de '
        'verdad conviene o si fue el momento el que empujó la '
        'decisión.',
    highlight: 'Las mejores decisiones de dinero rara vez se toman con prisa.',
    icono: Icons.bedtime_rounded,
    color: Color(0xFFFACC15),
  ),
  FinancialTip(
    titulo: 'Ponle un límite a los antojos',
    descripcion:
    'Definir de antemano un monto mensual para "gastos sin '
        'justificación" te deja disfrutar sin culpa, y a la vez '
        'evita que se salga de control.',
    highlight: 'Un límite claro te da permiso de gastar sin remordimiento.',
    icono: Icons.pie_chart_rounded,
    color: Color(0xFF4ADE80),
  ),
  FinancialTip(
    titulo: 'Comparte lo que se pueda compartir',
    descripcion:
    'Varios servicios de streaming y suscripciones tienen planes '
        'familiares pensados para varias personas. Si ya lo pagas '
        'solo, revisa si te conviene compartirlo.',
    highlight: 'El mismo servicio, dividido entre más personas, cuesta menos.',
    icono: Icons.group_rounded,
    color: Color(0xFF38BDF8),
  ),
  FinancialTip(
    titulo: 'Revisa las comisiones de tu banco',
    descripcion:
    'Cuotas de manejo, comisiones por retiro fuera de red, cargos '
        'por saldo mínimo... muchas veces existen formas de evitarlas '
        'que el banco no te explica a menos que preguntes.',
    highlight: 'Lo que no cuestionas, lo sigues pagando.',
    icono: Icons.account_balance_rounded,
    color: Color(0xFFA78BFA),
  ),
  FinancialTip(
    titulo: 'No gastes de más solo por ganar puntos',
    descripcion:
    'La recompensa de una tarjeta o programa de puntos solo vale la '
        'pena si de todos modos ibas a hacer esa compra. Comprar '
        'más "para llegar a la meta" casi nunca sale a cuenta.',
    highlight: 'Los puntos que te cuestan más de lo que valen no son un beneficio.',
    icono: Icons.card_giftcard_rounded,
    color: Color(0xFFFB923C),
  ),
  FinancialTip(
    titulo: 'Planea tu quincena antes de que llegue',
    descripcion:
    'Saber, aunque sea a grandes rasgos, en qué se va a ir tu '
        'próximo pago antes de que caiga te evita decisiones de '
        'último momento con el dinero recién llegado.',
    highlight: 'Un plan simple de antemano gana siempre a improvisar sobre la marcha.',
    icono: Icons.event_available_rounded,
    color: Color(0xFF34D399),
  ),
  FinancialTip(
    titulo: 'Cuidado con "meses sin intereses"',
    descripcion:
    'Diferir un pago a varios meses sigue siendo un compromiso fijo '
        'futuro, aunque hoy no te cueste nada extra. Revisa que ese '
        'compromiso quepa en tus próximos pagos antes de aceptarlo.',
    highlight: 'Sin intereses no significa sin compromiso.',
    icono: Icons.calendar_month_rounded,
    color: Color(0xFFF472B6),
  ),
  FinancialTip(
    titulo: 'Pequeños hábitos bajan el recibo',
    descripcion:
    'Apagar luces que no usas, desconectar aparatos en espera, '
        'cerrar bien las llaves de agua... son cambios chicos que, '
        'sostenidos en el tiempo, sí se notan en el pago mensual.',
    highlight: 'No hace falta un gran cambio; con constancia basta.',
    icono: Icons.bolt_rounded,
    color: Color(0xFF60A5FA),
  ),
  FinancialTip(
    titulo: 'Reconoce tus logros de ahorro',
    descripcion:
    'Cuidar el dinero es más fácil de sostener si también celebras '
        'cuando te va bien, no solo cuando te preocupas por lo que '
        'gastaste de más.',
    highlight: 'La disciplina dura más cuando también se siente bien.',
    icono: Icons.emoji_events_rounded,
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