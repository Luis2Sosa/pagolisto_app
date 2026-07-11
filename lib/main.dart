import 'package:flutter/material.dart';
import 'package:pagolisto/screens/start_screen.dart';
import 'package:pagolisto/screens/main_navigation_screen.dart';

void main() {
  runApp(const PagoListoApp());
}

class PagoListoApp extends StatelessWidget {
  const PagoListoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pago Listo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StartScreen(),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}