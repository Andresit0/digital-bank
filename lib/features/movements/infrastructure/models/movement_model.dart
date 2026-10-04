class MovementModel {
  const MovementModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.occurredAt,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type != 'credit' && type != 'debit') {
      throw FormatException('unknown movement type: $type');
    }
    return MovementModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      type: type,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );
  }

  final String id;
  final String accountId;
  final String type;
  final double amount;
  final String currency;
  final String description;
  final DateTime occurredAt;
}
