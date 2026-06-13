import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../game/money_formatter.dart';
import '../simulation/auto_simulator.dart';
import '../simulation/simulation_result.dart';
import '../widgets/stat_tile.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  static const routeName = '/simulation';

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  SimulationResult? _result;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulation Stats')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Run automated games',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'The simulator picks cases randomly and accepts strong banker offers using the shared game rules.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _RunButton(games: 1000, onPressed: _runSimulation),
                _RunButton(games: 10000, onPressed: _runSimulation),
                _RunButton(games: 100000, onPressed: _runSimulation),
              ],
            ),
            if (_isRunning) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              StatTile(
                label: 'Games',
                value: '${_result!.games}',
              ),
              const SizedBox(height: 12),
              StatTile(
                label: 'Average Host Profit',
                value: formatMoney(_result!.averageHostProfit),
                color: const Color(0xFF123B32),
              ),
              const SizedBox(height: 12),
              StatTile(
                label: 'Average Player Award',
                value: formatMoney(_result!.averagePlayerAward),
              ),
              const SizedBox(height: 12),
              StatTile(
                label: 'Deal Rate',
                value: '${(_result!.dealRate * 100).toStringAsFixed(1)}%',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runSimulation(int games) async {
    setState(() => _isRunning = true);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final result = await compute(_runSimulationJob, games);

    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _isRunning = false;
    });
  }
}

SimulationResult _runSimulationJob(int games) {
  return AutoSimulator().run(games: games);
}

class _RunButton extends StatelessWidget {
  const _RunButton({
    required this.games,
    required this.onPressed,
  });

  final int games;
  final ValueChanged<int> onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () => onPressed(games),
      child: Text('$games games'),
    );
  }
}
