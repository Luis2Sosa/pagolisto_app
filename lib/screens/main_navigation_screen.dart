import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/screens/add_payment_screen.dart';
import 'package:pagolisto/screens/home_screen.dart';
import 'package:pagolisto/widgets/bottom_nav_bar.dart';

/// Contenedor principal con pestañas: mantiene la barra de navegación
/// fija abajo y cambia el contenido de arriba según la pestaña activa,
/// sin recargar toda la pantalla ni perder el estado de cada una.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // GlobalKey para poder "hablarle" directamente al estado de
  // HomeScreen desde aquí, aunque viva permanentemente dentro del
  // IndexedStack (y por lo tanto nunca vuelva a pasar por
  // initState). La usamos para pedirle que recalcule la pestaña
  // (quincenal/mensual) con más pagos justo cuando el usuario
  // regresa a Inicio.
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  // TODO: reemplazar los placeholders restantes por las pantallas
  // reales conforme se vayan construyendo (TipsScreen, HistoryScreen).
  //
  // No es "static const" porque AddPaymentScreen necesita un
  // callback (onSaved) que depende de este State para poder hacer
  // setState y regresar al tab de Inicio después de guardar.
  List<Widget> get _tabs => [
    HomeScreen(key: _homeKey),
    AddPaymentScreen(
      showBackButton: false,
      onSaved: _goToHomeAndRefresh,
    ),
    const _PlaceholderTab(title: 'Consejos Financieros'),
    const _PlaceholderTab(title: 'Historial'),
  ];

  /// Cambia a la pestaña de Inicio y le pide que recalcule cuál
  /// periodo (quincenal/mensual) tiene más pagos. Se usa tanto al
  /// tocar el ícono de Inicio en la barra inferior como al terminar
  /// de guardar un pago nuevo desde AddPaymentScreen.
  void _goToHomeAndRefresh() {
    setState(() => _currentIndex = 0);
    _homeKey.currentState?.refreshSelectedPeriod();
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      _goToHomeAndRefresh();
    } else {
      setState(() => _currentIndex = index);
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
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _tabs,
                ),
              ),
              BottomNavBar(
                currentIndex: _currentIndex,
                onTabSelected: _onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla temporal para pestañas que aún no se han construido.
class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title\n(próximamente)',
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}