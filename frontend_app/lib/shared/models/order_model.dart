// lib/models/order_model.dart

import 'package:flutter/cupertino.dart';

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
    final menuItemData = json['menuItem'] as Map<String, dynamic>?;

    return OrderItemModel(
      name: menuItemData?['name'] as String? ?? 'Sản phẩm không còn tồn tại',
      imageUrl: menuItemData?['imageUrl'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      priceAtOrder: (json['priceAtOrder'] as num? ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;
  final String restaurantName;
  final bool isReviewed;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    required this.restaurantName,
    required this.isReviewed,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String restName = 'Không rõ nhà hàng';
    try {
      final itemsList = json['items'] as List?;
      if (itemsList != null && itemsList.isNotEmpty) {
        final firstItem = itemsList.first as Map<String, dynamic>?;
        final menuItem = firstItem?['menuItem'] as Map<String, dynamic>?;
        final restaurant = menuItem?['restaurant'] as Map<String, dynamic>?;
        restName = restaurant?['name'] as String? ?? restName;
      }
    } catch (e) {
      debugPrint("Lỗi khi parse tên nhà hàng: $e");
    }

    return OrderModel(
      id: json['_id'] as String? ?? '',
      items: (json['items'] as List? ?? [])
          .map((itemJson) => OrderItemModel.fromJson(itemJson))
          .toList(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'unknown',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      restaurantName: restName,
      isReviewed: json['isReviewed'] as bool? ?? false,
    );
  }
}