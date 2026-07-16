import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pagolisto/core/app_colors.dart';
import 'package:pagolisto/screens/add_payment_screen.dart';
import 'package:pagolisto/screens/home_screen.dart';
import 'package:pagolisto/screens/history_screen.dart';
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

  // Permite comunicarse con HomeScreen aunque viva dentro del IndexedStack.
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  // Pestañas principales de la aplicación.
  List<Widget> get _tabs => [
    HomeScreen(key: _homeKey),

    AddPaymentScreen(
      showBackButton: false,
      onSaved: _goToHomeAndRefresh,
    ),

    const _PlaceholderTab(
      title: 'Consejos Financieros',
    ),

    const HistoryScreen(),
  ];

  /// Regresa a Inicio y actualiza los pagos mostrados.
  void _goToHomeAndRefresh() {
    setState(() {
      _currentIndex = 0;
    });

    _homeKey.currentState?.refreshSelectedPeriod();
  }

  /// Controla los cambios de pestaña desde la barra inferior.
  void _onTabSelected(int index) {
    if (index == 0) {
      _goToHomeAndRefresh();
    } else {
      setState(() {
        _currentIndex = index;
      });
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


/// Pantalla temporal para pestañas que todavía no están construidas.
class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({
    required this.title,
  });

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