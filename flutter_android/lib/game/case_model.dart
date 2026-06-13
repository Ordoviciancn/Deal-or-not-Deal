enum CaseStatus { closed, selected, opened }

class GameCase {
  const GameCase({
    required this.number,
    required this.amount,
    required this.status,
  });

  final int number;
  final int amount;
  final CaseStatus status;

  GameCase copyWith({
    int? number,
    int? amount,
    CaseStatus? status,
  }) {
    return GameCase(
      number: number ?? this.number,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
}
