import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import '../../../shared/theme/app_styles.dart';

class DetailsScreen extends StatefulWidget {
  final String menuItemId;
  final String imageUrl;
  final String title;
  final String description;
  final double price;

  const DetailsScreen({
    super.key,
    required this.menuItemId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút quay lại
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // Ảnh sản phẩm
              Center(
                // SỬA LỖI CHÍNH: Dùng Image.network thay vì Image.asset để tải ảnh từ URL
                child: Image.network(
                  widget.imageUrl,
                  height: MediaQuery.of(context).size.height / 3,
                  fit: BoxFit.contain,
                  // Thêm errorBuilder để hiển thị icon thay thế nếu ảnh lỗi
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: MediaQuery.of(context).size.height / 4, color: Colors.grey);
                  },
                  // Thêm loadingBuilder để hiển thị vòng xoay khi đang tải
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Tên và mô tả sản phẩm (lấy từ widget)
              Text(widget.title, style: AppStyles.headlineTextFeildStyle()),
              const SizedBox(height: 10),
              Text(widget.description, style: TextStyle(color: Colors.grey[600], height: 1.5)),
              const SizedBox(height: 24),

              // Phần chọn số lượng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => setState(() => quantity++),
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
                          // SỬA LỖI: Sử dụng giá tiền từ widget.price
                          Text(
                            '${(quantity * widget.price).toStringAsFixed(0)}đ',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItemToCart(widget.menuItemId, quantity: quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã thêm vào giỏ hàng!'), duration: Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      label: const Text('Thêm vào giỏ', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.deepOrange),
    );
  }
}