import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/cart_model.dart';
import 'package:flutter_dapm/shared/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  CartModel? _cart;
  bool _isLoading = false;

  // --- GETTERS ---
  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;

  // SỬA LỖI Ở ĐÂY
  int get totalItems {
    // Nếu giỏ hàng là null, trả về 0
    if (_cart == null) {
      return 0;
    }
    // Nếu giỏ hàng không null, tính tổng số lượng
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  // --- METHODS ---
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    _cart = await _cartService.getCart();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItemToCart(String menuItemId, {int quantity = 1}) async {
    // Có thể thêm trạng thái loading riêng cho từng item nếu muốn
    final updatedCart = await _cartService.addItem(menuItemId, quantity);
    if (updatedCart != null) {
      _cart = updatedCart;
      notifyListeners();
    } else {
      // TODO: Hiển thị thông báo lỗi cho người dùng
      debugPrint("Thêm sản phẩm thất bại");
    }
  }

  // HOÀN THIỆN CÁC HÀM CÒN LẠI
  Future<void> removeItemFromCart(String menuItemId) async {
    final updatedCart = await _cartService.removeItem(menuItemId);
    if (updatedCart != null) {
      _cart = updatedCart;
      notifyListeners();
    }
    // TODO: Xử lý lỗi
  }

  Future<void> clearCart() async {
    final success = await _cartService.clearCart();
    if (success) {
      // Tải lại giỏ hàng (bây giờ sẽ là rỗng)
      await fetchCart();
    }
    // TODO: Xử lý lỗi
  }
}