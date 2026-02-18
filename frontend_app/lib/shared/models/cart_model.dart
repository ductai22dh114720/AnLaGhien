import 'package:flutter_dapm/shared/models/menu_item_model.dart'; // Sẽ tạo file này

// Đại diện cho một món hàng trong giỏ
class CartItemModel {
  final MenuItemModel menuItem;
  final int quantity;

  CartItemModel({required this.menuItem, required this.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menuItem: MenuItemModel.fromJson(json['menuItem']),
      quantity: json['quantity'],
    );
  }
}

// Đại diện cho toàn bộ giỏ hàng
class CartModel {
  final String id;
  final List<CartItemModel> items;

  // Tính tổng tiền ở phía client
  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + (item.menuItem.price * item.quantity));
  }

  CartModel({required this.id, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<CartItemModel> cartItems = itemsList.map((i) => CartItemModel.fromJson(i)).toList();

    return CartModel(
      id: json['_id'],
      items: cartItems,
    );
  }
}