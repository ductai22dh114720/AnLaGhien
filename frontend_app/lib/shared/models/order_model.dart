// lib/models/order_model.dart

// Model cho một món trong đơn hàng
class OrderItemModel {
  final String name;
  final String? imageUrl;
  final int quantity;
  final double priceAtOrder;

  OrderItemModel({
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.priceAtOrder,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // menuItem có thể là null nếu sản phẩm bị xóa, cần xử lý
    final menuItemData = json['menuItem'] as Map<String, dynamic>? ?? {};

    return OrderItemModel(
      name: menuItemData['name'] ?? 'Sản phẩm đã bị xóa',
      imageUrl: menuItemData['imageUrl'],
      quantity: json['quantity'],
      priceAtOrder: (json['priceAtOrder'] as num).toDouble(),
    );
  }
}

// Model cho cả đơn hàng
class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      items: (json['items'] as List)
          .map((itemJson) => OrderItemModel.fromJson(itemJson))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}