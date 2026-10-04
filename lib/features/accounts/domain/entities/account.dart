enum AccountType { savings, checking }

class Account {
  const Account({
    required this.id,
    required this.type,
    required this.displayName,
    required this.maskedNumber,
    required this.availableBalance,
  });

  final String id;
  final AccountType type;
  final String displayName;
  final String maskedNumber;
  final double availableBalance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          displayName == other.displayName &&
          maskedNumber == other.maskedNumber &&
          availableBalance == other.availableBalance;

  @override
  int get hashCode =>
      Object.hash(id, type, displayName, maskedNumber, availableBalance);
}
