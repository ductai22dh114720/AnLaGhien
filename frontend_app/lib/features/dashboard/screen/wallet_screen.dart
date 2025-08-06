import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/transaction_model.dart';
import 'package:flutter_dapm/shared/screens/webview_screen.dart';
import 'package:flutter_dapm/shared/services/wallet_service.dart';
import 'package:flutter_dapm/shared/services/payment_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _walletService = WalletService();
  final _paymentService = PaymentService();

  late Future<Map<String, dynamic>?> _walletInfoFuture;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Biến để lưu tên người dùng
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Hàm để tải cả thông tin ví và tên người dùng
  void _loadInitialData() {
    _loadUserName();
    _loadWalletInfo();
  }

  void _loadUserName() {
    final box = GetStorage();
    // Giả sử bạn đã lưu tên user vào GetStorage với key 'user_name' lúc đăng nhập
    final savedName = box.read<String>('user_name');
    if (savedName != null) {
      setState(() {
        _userName = savedName;
      });
    }
  }

  void _loadWalletInfo() {
    setState(() {
      _walletInfoFuture = _walletService.getWalletInfo();
    });
  }

  Future<void> _handleTopUpWithVnpay() async {
    const int amount = 50000;

    // Gọi hàm từ PaymentService
    final String? paymentUrl = await _paymentService.createVnpayPaymentUrl(amount);

    if (!mounted) return;

    if (paymentUrl != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebViewScreen(initialUrl: paymentUrl, title: 'Thanh toán VNPay'),
        ),
      );

      if (!mounted) return;

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nạp tiền thành công!'), backgroundColor: Colors.green));
        _loadWalletInfo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao dịch đã bị hủy hoặc thất bại.'), backgroundColor: Colors.orange));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo yêu cầu thanh toán.'), backgroundColor: Colors.red));
    }
  }

  // --- PHẦN BUILD UI ---

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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _walletInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Không thể tải dữ liệu ví."), ElevatedButton(onPressed: _loadWalletInfo, child: const Text("Thử lại"))]));
          }

          final walletData = snapshot.data!;
          final double balance = (walletData['balance'] as num).toDouble();
          final List<TransactionModel> transactions = walletData['transactions'];

          return RefreshIndicator(
            onRefresh: () async => _loadWalletInfo(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(_userName, balance), // <-- Truyền tên và số dư thật
                    const SizedBox(height: 30),
                    _buildTopUpSection(),
                    const SizedBox(height: 30),
                    _buildTransactionHistory(transactions), // <-- Truyền danh sách giao dịch thật
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS HELPER ---

  Widget _buildBalanceCard(String userName, double balance) {
    return Card(
      elevation: 5,
      shadowColor: Colors.deepOrange.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [Colors.deepOrange, Colors.orange.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: TextStyle(fontSize: 18, color: Colors.white.withAlpha(230))),
            const SizedBox(height: 10),
            Text(currencyFormatter.format(balance), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Số dư hiện tại', style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204))),
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
              'assets/vnpay_logo.png',
              'VNPay',
              _handleTopUpWithVnpay,
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
                  color: Colors.grey.withAlpha(25),
                  spreadRadius: 1,
                  blurRadius: 5,
                ), // Sửa lỗi deprecated
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

  Widget _buildTransactionHistory(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text("Chưa có giao dịch nào."));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lịch sử giao dịch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length, // <-- Dùng transactions.length
          itemBuilder: (context, index) {
            final transaction = transactions[index]; // <-- Lấy từ danh sách thật
            bool isCredit = transaction.amount > 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red),
              ),
              title: Text(transaction.type == 'deposit' ? 'Nạp tiền' : 'Thanh toán', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('dd/MM/yyyy, HH:mm').format(transaction.createdAt)),
              trailing: Text(
                '${isCredit ? '+' : ''}${currencyFormatter.format(transaction.amount)}',
                style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
        ),
      ],
    );
  }
}