import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/money_formatter.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/stat_tile.dart';
import 'game_screen.dart';
import 'simulation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            Text(
              'Ticket Deal',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF123B32),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pay the ticket, pick your case, then decide whether the banker is generous enough.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            StatTile(
              label: 'Ticket Price',
              value: formatMoney(GameConfig.ticketCost),
            ),
            const SizedBox(height: 12),
            StatTile(
              label: 'Top Prize',
              value: formatMoney(GameConfig.maxPrize),
              color: const Color(0xFFB7791F),
            ),
            const SizedBox(height: 28),
            PrimaryActionButton(
              label: 'Start Game',
              icon: Icons.play_arrow,
              onPressed: () => Navigator.of(context).pushNamed(
                GameScreen.routeName,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                SimulationScreen.routeName,
              ),
              icon: const Icon(Icons.query_stats),
              label: const Text('Simulation Stats'),
            ),
          ],
        ),
      ),
    );
  }
}
