import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/screens/webview_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // --- DỮ LIỆU MẪU ---
  final String userName = "Nguyễn Thái Thành Đạt";
  double currentBalance = 250000;
  final List<Map<String, dynamic>> transactionHistory = [
    {'type': 'Nạp tiền', 'amount': 100000, 'date': DateTime(2024, 7, 28, 10, 30), 'method': 'VNPay'},
    {'type': 'Thanh toán đơn hàng', 'amount': -45000, 'date': DateTime(2024, 7, 27, 18, 45), 'orderId': '#12345'},
  ];

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // --- HÀM LOGIC XỬ LÝ SỰ KIỆN ---

  void _handleTopUpWithMoMo() {
    debugPrint('Nạp tiền bằng MoMo');
    // TODO: Tích hợp MoMo
  }

  void _handleTopUpWithBank() {
    debugPrint('Nạp tiền bằng Ngân hàng');
  }

  Future<void> _handleTopUpWithVnpay() async {
    const int amount = 50000;

    try {
      final dio = Dio();
      const String apiUrl = '${ApiConfig.baseUrl}/payment/vnpay-create';
      final response = await dio.post(apiUrl, data: {'amount': amount});

      // Kiểm tra context trước khi sử dụng
      if (!mounted) return;

      if (response.statusCode == 200 && response.data['paymentUrl'] != null) {
        final String paymentUrl = response.data['paymentUrl'];

        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WebViewScreen(initialUrl: paymentUrl, title: 'Thanh toán VNPay'),
          ),
        );

        // Kiểm tra context lần nữa sau khi quay về từ WebView
        if (!mounted) return;

        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nạp tiền thành công!'), backgroundColor: Colors.green));
          // TODO: Gọi API để cập nhật lại số dư ví và refresh UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao dịch đã bị hủy hoặc thất bại.'), backgroundColor: Colors.orange));
        }
      }
    } on DioException catch (e) {
      debugPrint('Lỗi khi gọi API VNPay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo yêu cầu thanh toán.'), backgroundColor: Colors.red));
      }
    }
  }

  // --- PHẦN BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("VÍ CỦA TÔI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 30),
              _buildTopUpSection(),
              const SizedBox(height: 30),
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS HELPER ---

  Widget _buildBalanceCard() {
    return Card(
      elevation: 5,
      shadowColor: Colors.deepOrange.withAlpha(50), // Sửa lỗi deprecated
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity, // Đảm bảo card chiếm hết chiều rộng
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: TextStyle(fontSize: 18, color: Colors.white.withAlpha(230))), // Sửa lỗi deprecated
            const SizedBox(height: 10),
            Text(currencyFormatter.format(currentBalance), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Số dư hiện tại', style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204))), // Sửa lỗi deprecated
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nạp tiền vào ví", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPaymentMethodButton('assets/momo_logo.png', 'MoMo', _handleTopUpWithMoMo),
            _buildPaymentMethodButton('assets/vnpay_logo.png', 'VNPay', _handleTopUpWithVnpay),
            _buildPaymentMethodButton('assets/bank.png', 'Ngân hàng', _handleTopUpWithBank),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String assetPath, String label, VoidCallback onPressed) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 5) // Sửa lỗi deprecated
                ]
            ),
            child: Image.asset(assetPath, width: 40, height: 40),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lịch sử giao dịch",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Dùng ListView.builder nếu danh sách dài
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactionHistory.length,
          itemBuilder: (context, index) {
            final transaction = transactionHistory[index];
            bool isCredit = transaction['amount'] > 0; // Giao dịch cộng tiền
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isCredit ? Icons.add : Icons.remove,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                transaction['type'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy, HH:mm').format(transaction['date']),
              ),
              trailing: Text(
                '${isCredit ? '+' : ''}${currencyFormatter.format(transaction['amount'])}',
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          separatorBuilder:
              (context, index) => const Divider(indent: 16, endIndent: 16),
        ),
      ],
    );
  }
}
