import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // --- Dữ liệu mẫu (sau này sẽ lấy từ API) ---
  final String userName = "Nguyễn Thái Thành Đạt";
  double currentBalance = 250000; // Số dư hiện tại
  final List<Map<String, dynamic>> transactionHistory = [
    {
      'type': 'Nạp tiền',
      'amount': 100000,
      'date': DateTime(2024, 7, 28, 10, 30),
      'method': 'VNPay',
    },
    {
      'type': 'Thanh toán đơn hàng',
      'amount': -45000,
      'date': DateTime(2024, 7, 27, 18, 45),
      'orderId': '#12345',
    },
    {
      'type': 'Hoàn tiền',
      'amount': 20000,
      'date': DateTime(2024, 7, 26, 9, 15),
      'orderId': '#12340',
    },
    {
      'type': 'Nạp tiền',
      'amount': 200000,
      'date': DateTime(2024, 7, 25, 14, 0),
      'method': 'MoMo',
    },
    {
      'type': 'Thanh toán đơn hàng',
      'amount': -25000,
      'date': DateTime(2024, 7, 24, 12, 5),
      'orderId': '#12333',
    },
  ];

  // Hàm để format số thành tiền tệ Việt Nam
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "VÍ CỦA TÔI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      shadowColor: Colors.deepOrange.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
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
            Text(
              userName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currencyFormatter.format(currentBalance),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Số dư hiện tại',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nạp tiền vào ví",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPaymentMethodButton(
              'assets/momo_logo.png', // Cần có ảnh logo MoMo
              'MoMo',
              () {
                // TODO: Bắt đầu luồng nạp tiền MoMo
                print('Nạp tiền bằng MoMo');
              },
            ),
            _buildPaymentMethodButton(
              'assets/vnpay_logo.png', // Cần có ảnh logo VNPay
              'VNPay',
              () {
                // TODO: Bắt đầu luồng nạp tiền VNPay
                print('Nạp tiền bằng VNPay');
              },
            ),
            _buildPaymentMethodButton(
              'assets/bank.png', // Cần có ảnh logo ngân hàng
              'Ngân hàng',
              () {
                // TODO: Bắt đầu luồng nạp tiền qua ngân hàng
                print('Nạp tiền bằng Ngân hàng');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(
    String assetPath,
    String label,
    VoidCallback onPressed,
  ) {
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
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
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
