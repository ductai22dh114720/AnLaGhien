// lib/models/wallet_model.dart
class WalletModel {
  final String id;
  final String userId;
  double balance;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['_id'],
      userId: json['user'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}