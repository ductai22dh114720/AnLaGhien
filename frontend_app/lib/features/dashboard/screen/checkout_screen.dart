import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:flutter_dapm/shared/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentMethod { wallet, cod }

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService(); // Thêm UserService
  late Future<UserModel?> _userProfileFuture; // Future để lấy dữ liệu user

  PaymentMethod? _selectedMethod = PaymentMethod.wallet;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Bắt đầu gọi API để lấy thông tin user ngay khi màn hình được build
    _userProfileFuture = _userService.getUserProfile();
  }

  // SỬA LẠI HÀM NÀY: Nhận UserModel làm tham số
  Future<void> _handlePlaceOrder(UserModel user) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán.')));
      return;
    }

    // Kiểm tra xem người dùng đã có địa chỉ hay chưa
    final deliveryAddress = user.address;
    if (deliveryAddress == null || deliveryAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật địa chỉ trong trang cá nhân trước khi đặt hàng.')),
      );
      return;
    }

    if (cartProvider.cart == null) return;

    setState(() => _isProcessing = true);

    final paymentMethod = _selectedMethod == PaymentMethod.wallet ? 'wallet' : 'cod';

    final success = await _orderService.createOrder(
      cart: cartProvider.cart!,
      deliveryAddress: deliveryAddress, // SỬ DỤNG ĐỊA CHỈ THẬT
      paymentMethod: paymentMethod,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        await cartProvider.clearCart();
        await Provider.of<WalletProvider>(context, listen: false).fetchWallet();
        _showOrderSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thất bại, vui lòng thử lại.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Đặt hàng thành công!"),
        content: const Text("Cảm ơn bạn đã đặt hàng. Đơn hàng của bạn đang được xử lý."),
        actions: [
          TextButton(
            onPressed: () {
              // Đóng dialog trước
              Navigator.of(dialogContext).pop();

              // SAU ĐÓ, đóng CheckoutScreen và trả về một giá trị để báo hiệu thành công
              // Giá trị 'true' này sẽ được OrderScreen nhận
              Navigator.of(context).pop(true); // <<-- THAY ĐỔI QUAN TRỌNG
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Xác nhận Đơn hàng"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      // SỬ DỤNG FutureBuilder ĐỂ HIỂN THỊ GIAO DIỆN
      body: FutureBuilder<UserModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          // TRẠNG THÁI 1: ĐANG TẢI DỮ LIỆU
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // TRẠNG THÁI 2: CÓ LỖI HOẶC KHÔNG CÓ DỮ LIỆU
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Không thể tải thông tin người dùng. Vui lòng thử lại.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          // TRẠNG THÁI 3: TẢI DỮ LIỆU THÀNH CÔNG
          final user = snapshot.data!;

          // Trả về giao diện chính với dữ liệu thật
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần địa chỉ giao hàng với dữ liệu thật
                    const Text("Giao đến", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.deepOrange),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.address ?? "Vui lòng cập nhật địa chỉ"),
                        trailing: TextButton(onPressed: () { /* TODO: Chuyển đến trang profile để sửa */ }, child: const Text("Thay đổi")),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tóm tắt đơn hàng (giữ nguyên)
                    const Text("Tóm tắt đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<CartProvider>(builder: (context, provider, child) => Text("Tổng tạm tính (${provider.totalItems} món)")),
                            Text(currencyFormatter.format(cartProvider.cart!.totalPrice)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chọn phương thức thanh toán (giữ nguyên)
                    const Text("Phương thức thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<PaymentMethod>(
                            title: const Text('Thanh toán bằng ví'),
                            subtitle: const Text('Số dư: 50.000đ'),
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
                        // SỬA LẠI: Truyền user vào hàm xử lý
                        onPressed: _isProcessing ? null : () => _handlePlaceOrder(user),
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
              ),
              // Lớp phủ loading
              if (_isProcessing)
                Container(
                  color: Colors.black.withAlpha(120),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
            ],
          );
        },
      ),
    );
  }
}