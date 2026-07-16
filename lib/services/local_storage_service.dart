import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pagolisto/models/payment.dart';
import 'package:pagolisto/models/payment_history_entry.dart';

/// Centraliza todo el acceso a almacenamiento local (SharedPreferences).
///
/// Ninguna pantalla debe llamar a SharedPreferences directamente:
/// siempre a través de este servicio, para que el resto de la app no
/// dependa de cómo ni dónde se guardan los datos.
class LocalStorageService {
  LocalStorageService._();

  static const String _keyUserName = 'user_name';
  static const String _keyPayments = 'payments_list';
  static const String _keyHistory = 'payments_history';

  /// Guarda el nombre del usuario.
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name.trim());
  }

  /// Devuelve el nombre guardado, o cadena vacía si no existe.
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? '';
  }

  /// True si el usuario ya completó el registro de nombre.
  static Future<bool> hasUserName() async {
    final name = await getUserName();
    return name.isNotEmpty;
  }

  /// Devuelve todos los pagos guardados.
  static Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyPayments) ?? [];
    return raw
        .map((item) => Payment.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  /// Sobrescribe la lista completa de pagos.
  static Future<void> _savePayments(List<Payment> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = payments.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyPayments, raw);
  }

  /// Agrega un pago nuevo a la lista existente.
  static Future<void> addPayment(Payment payment) async {
    final payments = await getPayments();
    payments.add(payment);
    await _savePayments(payments);
  }

  /// Reemplaza un pago existente (por id) con su versión actualizada.
  static Future<void> updatePayment(Payment updated) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      payments[index] = updated;
      await _savePayments(payments);
    }
  }

  /// Alterna el estado "pagado" de un pago.
  static Future<void> togglePaymentPaid(String id) async {
    final payments = await getPayments();
    final index = payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      payments[index] = payments[index].copyWith(pagado: !payments[index].pagado);
      await _savePayments(payments);
    }
  }

  /// Borra un pago por id.
  static Future<void> deletePayment(String id) async {
    final payments = await getPayments();
    payments.removeWhere((p) => p.id == id);
    await _savePayments(payments);
  }

  /// Devuelve todo el historial de pagos ya confirmados, sin ningún
  /// orden garantizado (quien lo lea debe ordenarlo si lo necesita).
  static Future<List<PaymentHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyHistory) ?? [];
    return raw
        .map((item) =>
        PaymentHistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  /// Sobrescribe la lista completa de historial.
  static Future<void> _saveHistory(List<PaymentHistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_keyHistory, raw);
  }

  /// Agrega una entrada nueva al historial (un pago recién
  /// confirmado). El historial nunca se edita ni se borra desde la
  /// UI normal: es un registro permanente de lo que ya se pagó.
  static Future<void> addHistoryEntry(PaymentHistoryEntry entry) async {
    final history = await getHistory();
    history.add(entry);
    await _saveHistory(history);
  }

  /// Borra todos los datos guardados (útil para pruebas / logout).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}