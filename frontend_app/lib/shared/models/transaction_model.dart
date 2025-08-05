// File: lib/shared/models/transaction_model.dart

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'deposit', 'payment', 'refund'
  final String status; // 'pending', 'completed', 'failed'
  final String? paymentMethod; // 'vnpay', 'momo', etc.
  final String? transactionCode; // Mã giao dịch từ cổng thanh toán
  final String? relatedOrder; // ID của đơn hàng liên quan
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.paymentMethod,
    this.transactionCode,
    this.relatedOrder,
    required this.createdAt,
  });

  // Factory constructor để tạo một instance từ JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'],
      amount: (json['amount'] as num).toDouble(), // Chuyển đổi an toàn từ num sang double
      type: json['type'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionCode: json['transactionCode'],
      relatedOrder: json['relatedOrder'],
      createdAt: DateTime.parse(json['createdAt']), // Chuyển đổi chuỗi ISO 8601 sang DateTime
    );
  }
}