import 'game_config.dart';
import 'money_formatter.dart';

class Banker {
  const Banker();

  int makeOffer({
    required Iterable<int> unopenedAmounts,
    required int completedOfferRounds,
  }) {
    final amounts = unopenedAmounts.toList(growable: false);
    if (amounts.isEmpty) {
      return 0;
    }

    final total = amounts.fold<int>(0, (sum, value) => sum + value);
    final average = total / amounts.length;
    final discountIndex = completedOfferRounds.clamp(
      0,
      GameConfig.offerDiscounts.length - 1,
    ) as int;
    final discount = GameConfig.offerDiscounts[discountIndex];

    return clampOffer(average * discount);
  }
}
