class SimulationResult {
  const SimulationResult({
    required this.games,
    required this.totalHostProfit,
    required this.totalPlayerAward,
    required this.dealCount,
    required this.finalChoiceCount,
  });

  final int games;
  final int totalHostProfit;
  final int totalPlayerAward;
  final int dealCount;
  final int finalChoiceCount;

  double get averageHostProfit => totalHostProfit / games;

  double get averagePlayerAward => totalPlayerAward / games;

  double get dealRate => dealCount / games;
}
