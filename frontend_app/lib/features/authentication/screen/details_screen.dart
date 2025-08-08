import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/features/dashboard/screen/checkout_screen.dart'; // <<<--- IMPORT
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/shared/theme/app_styles.dart';
import 'package:intl/intl.dart'; // <<<--- IMPORT

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

  // --- HÀM LOGIC MỚI ---
  void _buyNow() {
    // 1. Thêm sản phẩm hiện tại vào giỏ hàng
    Provider.of<CartProvider>(context, listen: false).addItemToCart(widget.menuItemId, quantity: quantity);

    // 2. Chuyển ngay đến màn hình thanh toán
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  void _addToCart() {
    Provider.of<CartProvider>(context, listen: false).addItemToCart(widget.menuItemId, quantity: quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm vào giỏ hàng!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView( // Sử dụng CustomScrollView để có hiệu ứng đẹp hơn
        slivers: [
          // --- PHẦN HÌNH ẢNH VÀ APPBAR ---
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero( // Hiệu ứng chuyển cảnh ảnh
                tag: widget.menuItemId, // Dùng ID sản phẩm làm tag
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const Icon(Icons.fastfood, size: 100, color: Colors.grey),
                ),
              ),
            ),
          ),

          // --- PHẦN THÔNG TIN SẢN PHẨM ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm và Giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        currencyFormatter.format(widget.price),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  const Text("Mô tả", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 24),

                  // Chọn số lượng
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // --- PHẦN FOOTER VỚI CÁC NÚT HÀNH ĐỘNG ---
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // Widget footer
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Nút Thêm vào giỏ
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Thêm giỏ'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.deepOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Nút Mua ngay
          Expanded(
            child: ElevatedButton(
              onPressed: _buyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Mua ngay', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút +/-
  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      child: Icon(icon, size: 20),
    );
  }
}