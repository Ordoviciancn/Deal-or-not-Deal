class GameConfig {
  const GameConfig._();

  static const int caseCount = 26;
  static const int ticketCost = 100000;

  static const List<int> prizePool = [
    1,
    5,
    10,
    25,
    50,
    75,
    100,
    200,
    300,
    500,
    750,
    1000,
    2000,
    3000,
    5000,
    7500,
    10000,
    15000,
    20000,
    30000,
    50000,
    75000,
    100000,
    250000,
    500000,
    1000000,
  ];

  static const List<int> openingSchedule = [6, 5, 4, 3, 2, 1, 1, 1, 1];

  static const List<double> offerDiscounts = [
    0.35,
    0.45,
    0.55,
    0.65,
    0.75,
    0.82,
    0.88,
    0.92,
  ];

  static int get maxPrize => prizePool.last;
}
