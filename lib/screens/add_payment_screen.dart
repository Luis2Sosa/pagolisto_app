import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/core/formatters.dart';
import 'package:pagolisto/models/payment.dart';


import '../services/lib/services/payments_controller.dart';

/// Pantalla para registrar un nuevo pago recurrente.
///
/// Al guardar, el pago se agrega a través de PaymentsController, que
/// se encarga de persistirlo y de avisar a HomeScreen (y a cualquier
/// otra pantalla que lo escuche) para que se refleje de inmediato,
/// sin necesidad de recargar nada a mano.
class AddPaymentScreen extends StatefulWidget {
  /// Se llama justo después de guardar el pago con éxito. Úsalo
  /// cuando esta pantalla vive dentro de un IndexedStack (como pestaña
  /// de MainNavigationScreen) para regresar al tab de Inicio. Si no
  /// se proporciona, la pantalla hace Navigator.pop(true) por su
  /// cuenta (comportamiento para cuando se abre con Navigator.push).
  final VoidCallback? onSaved;

  /// Oculta la flecha de "atrás" cuando esta pantalla se usa como
  /// pestaña fija (no tiene a dónde "regresar" con el Navigator).
  final bool showBackButton;

  const AddPaymentScreen({
    super.key,
    this.onSaved,
    this.showBackButton = true,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  final _notasController = TextEditingController();

  PaymentPeriod _frecuencia = PaymentPeriod.quincenal;
  PaymentCategory _categoria = PaymentCategory.otro;
  DateTime _fecha = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _montoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentGreen,
              onPrimary: Colors.black,
              surface: Color(0xFF16221C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _guardarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final monto = double.parse(
      _montoController.text.replaceAll(',', '').trim(),
    );

    final payment = Payment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      monto: monto,
      frecuencia: _frecuencia,
      fecha: _fecha,
      notas: _notasController.text.trim(),
      categoria: _categoria,
    );

    await PaymentsController.instance.addPayment(payment);

    if (!mounted) return;

    // Limpiamos el formulario por si el usuario vuelve a este tab
    // y quiere registrar otro pago.
    _nombreController.clear();
    _montoController.clear();
    _notasController.clear();
    setState(() {
      _isSaving = false;
      _frecuencia = PaymentPeriod.quincenal;
      _categoria = PaymentCategory.otro;
      _fecha = DateTime.now();
    });

    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
                child: Row(
                  children: [
                    if (widget.showBackButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      )
                    else
                      const SizedBox(width: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Añadir Pago',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Nombre'),
                        const SizedBox(height: 8),
                        _StyledTextField(
                          controller: _nombreController,
                          hint: 'Ej. Luz CFE',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Escribe un nombre para el pago';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        _CategoryPicker(
                          selected: _categoria,
                          onChanged: (cat) => setState(() => _categoria = cat),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Monto'),
                        const SizedBox(height: 8),
                        _StyledTextField(
                          controller: _montoController,
                          hint: '\$0.00',
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Escribe un monto';
                            }
                            final parsed =
                            double.tryParse(value.replaceAll(',', '').trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Escribe un monto válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Frecuencia'),
                        const SizedBox(height: 8),
                        _FrequencyToggle(
                          selected: _frecuencia,
                          onChanged: (period) =>
                              setState(() => _frecuencia = period),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Fecha'),
                        const SizedBox(height: 8),
                        _DateField(fecha: _fecha, onTap: _pickFecha),
                        const SizedBox(height: 20),
                        const _FieldLabel('Notas'),
                        const SizedBox(height: 8),
                        _StyledTextField(
                          controller: _notasController,
                          hint: 'Opcional',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 28),
                        _SaveButton(isSaving: _isSaving, onTap: _guardarPago),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.accentGreen,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted.withOpacity(0.6),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        errorStyle: GoogleFonts.montserrat(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final PaymentCategory selected;
  final ValueChanged<PaymentCategory> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PaymentCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = PaymentCategory.values[index];
          final isSelected = category == selected;
          return GestureDetector(
            onTap: () => onChanged(category),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? category.color.withOpacity(0.22)
                        : Colors.white.withOpacity(0.04),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Icon(category.icon, color: category.color, size: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  category.label,
                  style: GoogleFonts.montserrat(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? category.color : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FrequencyToggle extends StatelessWidget {
  final PaymentPeriod selected;
  final ValueChanged<PaymentPeriod> onChanged;

  const _FrequencyToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: PaymentPeriod.values.map((period) {
          final isSelected = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? AppColors.accentGreen.withOpacity(0.18)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                    isSelected ? AppColors.accentGreen : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime fecha;
  final VoidCallback onTap;

  const _DateField({required this.fecha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatFechaLarga(fecha),
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.accentGreen,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;

  const _SaveButton({required this.isSaving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          disabledBackgroundColor: AppColors.accentGreen.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isSaving
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2.4,
          ),
        )
            : Text(
          'GUARDAR PAGO',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}