import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/checkout_screen.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để tự động rebuild khi giỏ hàng thay đổi
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text("Giỏ hàng của bạn"),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            actions: [
              // Nút xóa toàn bộ giỏ hàng
              if (cartProvider.cart != null && cartProvider.cart!.items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () {
                    // TODO: Hiển thị dialog xác nhận trước khi xóa
                    cartProvider.clearCart();
                  },
                )
            ],
          ),
          body: cartProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartProvider.cart == null || cartProvider.cart!.items.isEmpty
              ? _buildEmptyCart() // Tách ra widget riêng
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: cartProvider.cart!.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cart!.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cartItem.menuItem.imageUrl ?? 'https://via.placeholder.com/150',
                                width: 80, height: 80, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(currencyFormatter.format(cartItem.menuItem.price), style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            // Phần chỉnh sửa số lượng
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () {
                                    if (cartItem.quantity > 1) {
                                      cartProvider.addItemToCart(cartItem.menuItem.id, quantity: -1);
                                    } else {
                                      cartProvider.removeItemFromCart(cartItem.menuItem.id);
                                    }
                                  },
                                ),
                                Text(cartItem.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => cartProvider.addItemToCart(cartItem.menuItem.id, quantity: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context, currencyFormatter, cartProvider),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined, // Sửa tên icon
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            "Giỏ hàng của bạn đang trống!",
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget cho phần footer (Tổng tiền và nút Thanh toán)
  Widget _buildCheckoutSection(BuildContext context, NumberFormat formatter, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // Sửa lỗi deprecated
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng cộng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                formatter.format(provider.cart!.totalPrice),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Điều hướng đến CheckoutScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CheckoutScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tiến hành Thanh toán', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}