import 'dart:math';

import '../game/case_model.dart';
import '../game/game_config.dart';
import '../game/game_session.dart';
import 'simulation_result.dart';

enum AutoStrategy {
  conservative,
}

class AutoSimulator {
  AutoSimulator({
    Random? random,
  }) : _random = random ?? Random();

  final Random _random;

  SimulationResult run({
    required int games,
    AutoStrategy strategy = AutoStrategy.conservative,
  }) {
    var totalHostProfit = 0;
    var totalPlayerAward = 0;
    var dealCount = 0;
    var finalChoiceCount = 0;

    for (var i = 0; i < games; i++) {
      final session = GameSession(random: _random);
      final playerPick = _random.nextInt(GameConfig.caseCount) + 1;
      session.choosePlayerCase(playerPick);

      while (session.phase == GamePhase.openingCases) {
        final candidates = session.cases
            .where((gameCase) => gameCase.status == CaseStatus.closed)
            .toList();
        final pick = candidates[_random.nextInt(candidates.length)];
        session.openCase(pick.number);

        if (session.phase == GamePhase.bankerOffer &&
            _shouldAcceptOffer(session)) {
          final result = session.acceptOffer();
          totalHostProfit += result.hostProfit;
          totalPlayerAward += result.awardedAmount;
          dealCount++;
          break;
        }

        if (session.phase == GamePhase.bankerOffer) {
          session.rejectOffer();
        }
      }

      if (session.phase == GamePhase.finalChoice) {
        final result = _random.nextBool()
            ? session.keepPlayerCase()
            : session.swapPlayerCase();
        totalHostProfit += result.hostProfit;
        totalPlayerAward += result.awardedAmount;
        finalChoiceCount++;
      }
    }

    return SimulationResult(
      games: games,
      totalHostProfit: totalHostProfit,
      totalPlayerAward: totalPlayerAward,
      dealCount: dealCount,
      finalChoiceCount: finalChoiceCount,
    );
  }

  bool _shouldAcceptOffer(GameSession session) {
    final playerCase = session.cases.firstWhere(
      (gameCase) => gameCase.number == session.playerCaseNumber,
    );
    final remaining = session.remainingAmounts;
    final expectedValue =
        remaining.fold<int>(0, (sum, amount) => sum + amount) / remaining.length;

    return session.currentOffer >= expectedValue * 0.9 ||
        session.currentOffer >= playerCase.amount * 1.5;
  }
}
