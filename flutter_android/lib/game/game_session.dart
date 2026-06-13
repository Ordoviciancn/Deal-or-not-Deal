import 'dart:math';

import 'banker.dart';
import 'case_model.dart';
import 'game_config.dart';
import 'game_result.dart';

enum GamePhase {
  choosingPlayerCase,
  openingCases,
  bankerOffer,
  finalChoice,
  finished,
}

class GameSession {
  GameSession({
    Random? random,
    Banker banker = const Banker(),
  })  : _random = random ?? Random(),
        _banker = banker {
    _cases = _buildShuffledCases();
  }

  final Random _random;
  final Banker _banker;

  late List<GameCase> _cases;
  int? _playerCaseNumber;
  int _roundIndex = 0;
  int _openedThisRound = 0;
  int _offerRoundsCompleted = 0;
  int? _currentOffer;
  GamePhase _phase = GamePhase.choosingPlayerCase;
  GameResult? _result;

  List<GameCase> get cases => List.unmodifiable(_cases);

  int? get playerCaseNumber => _playerCaseNumber;

  int get roundNumber => _roundIndex + 1;

  int get ticketCost => GameConfig.ticketCost;

  int get currentOffer => _currentOffer ?? 0;

  GamePhase get phase => _phase;

  GameResult? get result => _result;

  int get boxesToOpenThisRound {
    if (_roundIndex >= GameConfig.openingSchedule.length) {
      return GameConfig.openingSchedule.last;
    }
    return GameConfig.openingSchedule[_roundIndex];
  }

  int get boxesRemainingThisRound =>
      max(0, boxesToOpenThisRound - _openedThisRound);

  bool get isAtFinalChoice => _phase == GamePhase.finalChoice;

  List<int> get remainingAmounts {
    final values = _cases
        .where((gameCase) => gameCase.status != CaseStatus.opened)
        .map((gameCase) => gameCase.amount)
        .toList();
    values.sort();
    return values;
  }

  List<int> get openedAmounts {
    final values = _cases
        .where((gameCase) => gameCase.status == CaseStatus.opened)
        .map((gameCase) => gameCase.amount)
        .toList();
    values.sort();
    return values;
  }

  List<GameCase> get finalUnopenedNonPlayerCases {
    return _cases
        .where(
          (gameCase) =>
              gameCase.status == CaseStatus.closed &&
              gameCase.number != _playerCaseNumber,
        )
        .toList(growable: false);
  }

  void choosePlayerCase(int caseNumber) {
    _ensurePhase(GamePhase.choosingPlayerCase);
    _updateCase(caseNumber, CaseStatus.selected);
    _playerCaseNumber = caseNumber;
    _phase = GamePhase.openingCases;
  }

  int openCase(int caseNumber) {
    _ensurePhase(GamePhase.openingCases);

    final gameCase = _caseByNumber(caseNumber);
    if (gameCase.status != CaseStatus.closed) {
      throw StateError('Only closed non-player cases can be opened.');
    }

    _updateCase(caseNumber, CaseStatus.opened);
    _openedThisRound++;

    if (_shouldEnterFinalChoice()) {
      _phase = GamePhase.finalChoice;
      return gameCase.amount;
    }

    if (_openedThisRound >= boxesToOpenThisRound) {
      _currentOffer = _banker.makeOffer(
        unopenedAmounts: remainingAmounts,
        completedOfferRounds: _offerRoundsCompleted,
      );
      _offerRoundsCompleted++;
      _phase = GamePhase.bankerOffer;
    }

    return gameCase.amount;
  }

  void rejectOffer() {
    _ensurePhase(GamePhase.bankerOffer);
    _currentOffer = null;
    _roundIndex++;
    _openedThisRound = 0;

    if (_shouldEnterFinalChoice()) {
      _phase = GamePhase.finalChoice;
    } else {
      _phase = GamePhase.openingCases;
    }
  }

  GameResult acceptOffer() {
    _ensurePhase(GamePhase.bankerOffer);
    return _finish(currentOffer, 'Deal accepted');
  }

  GameResult keepPlayerCase() {
    _ensurePhase(GamePhase.finalChoice);
    final selected = _cases.firstWhere(
      (gameCase) => gameCase.number == _playerCaseNumber,
    );
    return _finish(selected.amount, 'Kept original case');
  }

  GameResult swapPlayerCase() {
    _ensurePhase(GamePhase.finalChoice);
    final otherCases = finalUnopenedNonPlayerCases;
    if (otherCases.length != 1) {
      throw StateError('Swap requires exactly one other closed case.');
    }
    return _finish(otherCases.single.amount, 'Swapped final case');
  }

  void reset() {
    _cases = _buildShuffledCases();
    _playerCaseNumber = null;
    _roundIndex = 0;
    _openedThisRound = 0;
    _offerRoundsCompleted = 0;
    _currentOffer = null;
    _phase = GamePhase.choosingPlayerCase;
    _result = null;
  }

  List<GameCase> _buildShuffledCases() {
    final amounts = [...GameConfig.prizePool]..shuffle(_random);
    return List.generate(
      GameConfig.caseCount,
      (index) => GameCase(
        number: index + 1,
        amount: amounts[index],
        status: CaseStatus.closed,
      ),
    );
  }

  bool _shouldEnterFinalChoice() {
    final unopenedCount =
        _cases.where((gameCase) => gameCase.status != CaseStatus.opened).length;
    return _playerCaseNumber != null && unopenedCount == 2;
  }

  GameResult _finish(int awardedAmount, String reason) {
    _phase = GamePhase.finished;
    _result = GameResult(
      awardedAmount: awardedAmount,
      ticketCost: GameConfig.ticketCost,
      reason: reason,
    );
    return _result!;
  }

  GameCase _caseByNumber(int caseNumber) {
    return _cases.firstWhere(
      (gameCase) => gameCase.number == caseNumber,
      orElse: () => throw RangeError('Case $caseNumber does not exist.'),
    );
  }

  void _updateCase(int caseNumber, CaseStatus status) {
    _cases = [
      for (final gameCase in _cases)
        if (gameCase.number == caseNumber)
          gameCase.copyWith(status: status)
        else
          gameCase,
    ];
  }

  void _ensurePhase(GamePhase expected) {
    if (_phase != expected) {
      throw StateError('Expected phase $expected but found $_phase.');
    }
  }
}
