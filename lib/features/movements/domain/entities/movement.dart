enum MovementType { credit, debit }

class Movement {
  const Movement({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.occurredAt,
  });

  final String id;
  final String accountId;
  final MovementType type;
  final double amount;
  final String currency;
  final String description;
  final DateTime occurredAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          accountId == other.accountId &&
          type == other.type &&
          amount == other.amount &&
          currency == other.currency &&
          description == other.description &&
          occurredAt == other.occurredAt;

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    type,
    amount,
    currency,
    description,
    occurredAt,
  );
}
