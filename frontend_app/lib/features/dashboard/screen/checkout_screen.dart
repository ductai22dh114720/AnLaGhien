import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentMethod { wallet, cod } // Các phương thức thanh toán

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  PaymentMethod? _selectedMethod = PaymentMethod.wallet;
  bool _isProcessing = false; // Trạng thái cho màn hình chờ

  // Hàm xử lý khi nhấn nút Đặt hàng
  Future<void> _handlePlaceOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán.')));
      return;
    }
    if (cartProvider.cart == null) return;

    setState(() => _isProcessing = true);

    final deliveryAddress = "123 Sư Vạn Hạnh, P12, Q10, TPHCM"; // TODO: Lấy địa chỉ thật của user
    final paymentMethod = _selectedMethod == PaymentMethod.wallet ? 'wallet' : 'cod';

    final success = await _orderService.createOrder(
      cart: cartProvider.cart!,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        // Xóa giỏ hàng sau khi đặt thành công
        await cartProvider.clearCart();
        _showOrderSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thất bại, vui lòng thử lại.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dialog thông báo đặt hàng thành công
  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog( // Sửa lại builder context
        title: const Text("Đặt hàng thành công!"),
        content: const Text("Cảm ơn bạn đã đặt hàng. Đơn hàng của bạn đang được xử lý."),
        actions: [
          TextButton(
            onPressed: () {
              // Đóng dialog và quay về màn hình đầu tiên (thường là Home)
              Navigator.of(dialogContext).popUntil((route) => route.isFirst);
            },
            child: const Text("Về trang chủ"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Không listen ở đây để tránh rebuild không cần thiết
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Xác nhận Đơn hàng"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      // --- BẮT ĐẦU CẤU TRÚC ĐÚNG ---
      body: Stack(
        children: [
          // LỚP 1: GIAO DIỆN CHÍNH
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần địa chỉ giao hàng
                const Text("Giao đến", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.deepOrange),
                    title: const Text("Nguyễn Đức Tài", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: Lấy tên thật
                    subtitle: const Text("123 Sư Vạn Hạnh, Phường 12, Quận 10, TP. Hồ Chí Minh"), // TODO: Lấy địa chỉ thật
                    trailing: TextButton(onPressed: () {}, child: const Text("Thay đổi")),
                  ),
                ),
                const SizedBox(height: 24),

                // Tóm tắt đơn hàng
                const Text("Tóm tắt đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dùng Consumer ở đây để chỉ rebuild widget này khi totalItems thay đổi
                        Consumer<CartProvider>(
                          builder: (context, provider, child) =>
                              Text("Tổng tạm tính (${provider.totalItems} món)"),
                        ),
                        Text(currencyFormatter.format(cartProvider.cart!.totalPrice)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Chọn phương thức thanh toán
                const Text("Phương thức thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        title: const Text('Thanh toán bằng ví'),
                        subtitle: const Text('Số dư: 50.000đ'), // TODO: Lấy số dư thật từ WalletProvider
                        value: PaymentMethod.wallet,
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value),
                        activeColor: Colors.deepOrange,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      RadioListTile<PaymentMethod>(
                        title: const Text('Thanh toán khi nhận hàng (COD)'),
                        value: PaymentMethod.cod,
                        groupValue: _selectedMethod,
                        onChanged: (value) => setState(() => _selectedMethod = value),
                        activeColor: Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Nút đặt hàng
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePlaceOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Đặt hàng (${currencyFormatter.format(cartProvider.cart!.totalPrice)})',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ), // Kết thúc Padding

          // LỚP 2: LỚP PHỦ LOADING
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha(120),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ], // Kết thúc children của Stack
      ), // Kết thúc Stack
    ); // Kết thúc Scaffold
  }
}