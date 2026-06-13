import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/money_formatter.dart';

class RemainingAmountsPanel extends StatelessWidget {
  const RemainingAmountsPanel({
    super.key,
    required this.remainingAmounts,
  });

  final List<int> remainingAmounts;

  @override
  Widget build(BuildContext context) {
    final remainingSet = remainingAmounts.toSet();
    final values = GameConfig.prizePool;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E6E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Amounts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
              childAspectRatio: 4.2,
            ),
            itemBuilder: (context, index) {
              final amount = values[index];
              final isRemaining = remainingSet.contains(amount);
              return AnimatedOpacity(
                opacity: isRemaining ? 1 : 0.25,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isRemaining
                        ? const Color(0xFFF2FBF7)
                        : const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isRemaining
                          ? const Color(0xFFCDEBDD)
                          : const Color(0xFFE1E1E1),
                    ),
                  ),
                  child: Text(
                    formatMoney(amount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration:
                              isRemaining ? null : TextDecoration.lineThrough,
                        ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
