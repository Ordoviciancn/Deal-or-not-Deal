import 'package:flutter/material.dart';

import '../game/case_model.dart';
import '../game/game_config.dart';
import '../game/game_result.dart';
import '../game/game_session.dart';
import '../game/money_formatter.dart';
import '../widgets/case_grid.dart';
import '../widgets/remaining_amounts_panel.dart';
import '../widgets/stat_tile.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _session;

  @override
  void initState() {
    super.initState();
    _session = GameSession();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = switch (_session.phase) {
      GamePhase.choosingPlayerCase => 'Choose your case',
      GamePhase.openingCases =>
        'Open ${_session.boxesRemainingThisRound} case(s)',
      GamePhase.bankerOffer => 'Banker offer',
      GamePhase.finalChoice => 'Final choice',
      GamePhase.finished => 'Finished',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Deal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Round',
                    value: '${_session.roundNumber}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Ticket Cost',
                    value: formatMoney(GameConfig.ticketCost),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              statusText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (_session.playerCaseNumber != null) ...[
              const SizedBox(height: 4),
              Text('Your case: #${_session.playerCaseNumber}'),
            ],
            const SizedBox(height: 14),
            CaseGrid(
              cases: _session.cases,
              onCaseTap: _handleCaseTap,
            ),
            const SizedBox(height: 16),
            RemainingAmountsPanel(
              remainingAmounts: _session.remainingAmounts,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCaseTap(GameCase gameCase) async {
    if (_session.phase == GamePhase.choosingPlayerCase) {
      setState(() => _session.choosePlayerCase(gameCase.number));
      return;
    }

    if (_session.phase != GamePhase.openingCases ||
        gameCase.status != CaseStatus.closed) {
      return;
    }

    final openedAmount = _session.openCase(gameCase.number);
    setState(() {});

    await _showOpenedAmount(openedAmount);

    if (!mounted) {
      return;
    }

    if (_session.phase == GamePhase.bankerOffer) {
      await _showBankerOfferDialog();
    } else if (_session.phase == GamePhase.finalChoice) {
      await _showFinalChoiceDialog();
    }
  }

  Future<void> _showOpenedAmount(int amount) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Case Opened'),
        content: Text('This case contained ${formatMoney(amount)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBankerOfferDialog() {
    final offer = _session.currentOffer;
    final net = offer - GameConfig.ticketCost;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Banker Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offer: ${formatMoney(offer)}'),
            const SizedBox(height: 8),
            Text('Net after ticket: ${formatMoney(net)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _session.rejectOffer());
            },
            child: const Text('No Deal'),
          ),
          FilledButton(
            onPressed: () {
              final result = _session.acceptOffer();
              Navigator.of(context).pop();
              _goToResult(result);
            },
            child: const Text('Deal'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFinalChoiceDialog() {
    final otherCase = _session.finalUnopenedNonPlayerCases.single;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Keep or Swap?'),
        content: Text(
          'Only your case #${_session.playerCaseNumber} and case #${otherCase.number} remain.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              final result = _session.keepPlayerCase();
              Navigator.of(context).pop();
              _goToResult(result);
            },
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () {
              final result = _session.swapPlayerCase();
              Navigator.of(context).pop();
              _goToResult(result);
            },
            child: const Text('Swap'),
          ),
        ],
      ),
    );
  }

  void _goToResult(GameResult result) {
    Navigator.of(context).pushReplacementNamed(
      ResultScreen.routeName,
      arguments: result,
    );
  }
}
