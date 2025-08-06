import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/features/dashboard/screen/cart_screen.dart';

class AppBarCartIcon extends StatelessWidget {
  const AppBarCartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ CartProvider
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                // Điều hướng đến trang Giỏ hàng
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            // Chỉ hiển thị huy hiệu nếu có sản phẩm trong giỏ
            if (cartProvider.totalItems > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartProvider.totalItems.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}