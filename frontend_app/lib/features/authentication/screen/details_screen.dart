import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';

// SỬA LỖI 1: Tên class nên theo quy ước UpperCamelCase
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  // SỬA LỖI 2: createState phải trả về State<DetailsScreen>
  State<DetailsScreen> createState() => _DetailsScreenState();
}

// SỬA LỖI 3: State class phải kế thừa từ State<T>
class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SỬA LỖI 4: Thiếu dấu hai chấm `body:` và dấu ngoặc `()`
      body: SafeArea(
        child: Padding(
          // SỬA LỖI 5: Thiếu `padding:` và các dấu ngoặc, dấu phẩy
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // SỬA LỖI 6: Thiếu dấu ngoặc vuông `[` và các dấu phẩy
            children: [
              // Nút quay lại
              GestureDetector(
                // SỬA LỖI 7: Thiếu `{}` và `;`
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8), // Tăng padding một chút
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),

              const SizedBox(height: 20), // Tăng khoảng cách

              // Ảnh sản phẩm
              Center(
                child: Image.asset(
                  // SỬA LỖI 8: Thiếu dấu `/` trong đường dẫn và dấu phẩy
                  'assets/burger_2gagion.jpg',
                  // SỬA LỖI 9: Sai cú pháp tính toán và thiếu dấu phẩy
                  height: MediaQuery.of(context).size.height / 3,
                ),
              ),
              const SizedBox(height: 20),

              // Tên sản phẩm
              Text(
                'Combo Burger Gà + Khoai',
                // SỬA LỖI 10: Thiếu `style:`
                // Giả sử tên class là AppStyles
              ),
              const SizedBox(height: 10),

              // Mô tả sản phẩm
              Text(
                'Phần ăn tiện lợi gồm 1 miếng gà giòn rụm kết hợp cùng khoai tây chiên vàng, thích hợp cho bữa ăn nhanh, ngon miệng.',
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 24),

              // Phần chọn số lượng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Số lượng',
                    // SỬA LỖI 11: Thiếu `style:`
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(), // Đẩy phần footer xuống dưới

              // Tổng tiền + nút thêm vào giỏ hàng
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tổng tiền', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          // SỬA LỖI 12: Sai cú pháp tính toán
                          Text(
                            '${(quantity * 55000).toStringAsFixed(0)}đ',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Lấy ID của sản phẩm (bạn cần truyền nó vào màn hình này)
                        final productId = "some_product_id"; // <-- Thay bằng ID thật
                        Provider.of<CartProvider>(context, listen: false).addItemToCart(productId, quantity: quantity);

                        // Hiển thị thông báo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), duration: Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      label: const Text(
                        'Thêm vào giỏ',
                        // SỬA LỖI 13: Thiếu `style:`
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      // SỬA LỖI 14: Thiếu `style:`
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper để tránh lặp code cho nút + và -
  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
          side: BorderSide(color: Colors.grey.shade300)
      ),
      child: Icon(icon, color: Colors.deepOrange),
    );
  }
}