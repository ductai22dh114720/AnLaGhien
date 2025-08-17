import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/features/dashboard/screen/cart_screen.dart';

class AppBarCartIcon extends StatelessWidget {
  final Color iconColor;

  const AppBarCartIcon({super.key, this.iconColor = Colors.black, });

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ CartProvider
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon:  Icon(Icons.shopping_cart_outlined, color: iconColor,),
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
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    cartProvider.totalItems > 9 ? '9+' : cartProvider.totalItems.toString(),
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