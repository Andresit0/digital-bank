class AccountModel {
  const AccountModel({
    required this.id,
    required this.type,
    required this.displayName,
    required this.maskedNumber,
    required this.availableBalance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type != 'savings' && type != 'checking') {
      throw FormatException('unknown account type: $type');
    }
    return AccountModel(
      id: json['id'] as String,
      type: type,
      displayName: json['displayName'] as String,
      maskedNumber: json['maskedNumber'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
    );
  }

  final String id;
  final String type;
  final String displayName;
  final String maskedNumber;
  final double availableBalance;
}
