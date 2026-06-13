import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_deal_simulator/game/game_config.dart';
import 'package:ticket_deal_simulator/game/game_result.dart';
import 'package:ticket_deal_simulator/game/game_session.dart';

void main() {
  test('new game has 26 cases and full remaining pool', () {
    final session = GameSession();

    expect(session.cases, hasLength(GameConfig.caseCount));
    expect(session.remainingAmounts, GameConfig.prizePool);
    expect(session.phase, GamePhase.choosingPlayerCase);
  });

  test('ticket economics are applied to final result', () {
    const award = 250000;
    const result = GameResult(
      awardedAmount: award,
      ticketCost: GameConfig.ticketCost,
      reason: 'test',
    );

    expect(result.playerNetProfit, award - GameConfig.ticketCost);
    expect(result.hostProfit, GameConfig.ticketCost - award);
  });
}
