import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/game_result.dart';
import '../game/money_formatter.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/stat_tile.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)?.settings.arguments as GameResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No result found.')),
      );
    }

    final playerColor = result.playerNetProfit >= 0
        ? const Color(0xFF1A6F5B)
        : const Color(0xFFB42318);

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              result.reason,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 18),
            StatTile(
              label: 'Awarded Amount',
              value: formatMoney(result.awardedAmount),
            ),
            const SizedBox(height: 12),
            StatTile(
              label: 'Ticket Cost',
              value: formatMoney(GameConfig.ticketCost),
            ),
            const SizedBox(height: 12),
            StatTile(
              label: 'Player Net Profit',
              value: formatMoney(result.playerNetProfit),
              color: playerColor,
            ),
            const SizedBox(height: 12),
            StatTile(
              label: 'Host Profit',
              value: formatMoney(result.hostProfit),
              color: const Color(0xFF123B32),
            ),
            const SizedBox(height: 26),
            PrimaryActionButton(
              label: 'Play Again',
              icon: Icons.replay,
              onPressed: () => Navigator.of(context).pushReplacementNamed(
                GameScreen.routeName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
