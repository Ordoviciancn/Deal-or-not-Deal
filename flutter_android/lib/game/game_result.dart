class GameResult {
  const GameResult({
    required this.awardedAmount,
    required this.ticketCost,
    required this.reason,
  });

  final int awardedAmount;
  final int ticketCost;
  final String reason;

  int get playerNetProfit => awardedAmount - ticketCost;

  int get hostProfit => ticketCost - awardedAmount;
}
