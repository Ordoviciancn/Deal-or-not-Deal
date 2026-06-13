import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'screens/simulation_screen.dart';

void main() {
  runApp(const TicketDealApp());
}

class TicketDealApp extends StatelessWidget {
  const TicketDealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Deal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6F5B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        ResultScreen.routeName: (_) => const ResultScreen(),
        SimulationScreen.routeName: (_) => const SimulationScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
