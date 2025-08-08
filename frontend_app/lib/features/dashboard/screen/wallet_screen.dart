import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dapm/shared/models/transaction_model.dart';
import 'package:flutter_dapm/shared/screens/webview_screen.dart';
import 'package:flutter_dapm/shared/services/payment_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _paymentService = PaymentService();

  late Future<Map<String, dynamic>?> _walletInfoFuture;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Biến để lưu tên người dùng
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Gọi fetchWallet ngay khi màn hình khởi tạo để đảm bảo có dữ liệu mới nhất
    // listen: false vì chúng ta không cần rebuild initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).fetchWallet();
    });
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

  // Hàm refresh, chỉ cần gọi hàm của provider
  Future<void> _refreshWallet() async {
    await Provider.of<WalletProvider>(context, listen: false).fetchWallet();
  }

  Future<void> _showTopUpDialog() async {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Người dùng phải nhấn nút
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Nhập số tiền cần nạp'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              // Chỉ cho phép nhập số
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                labelText: 'Số tiền (VND)',
                hintText: 'Ví dụ: 50000',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                final amount = int.tryParse(value);
                // Giới hạn số tiền nạp tối thiểu
                if (amount == null || amount < 10000) {
                  return 'Số tiền phải lớn hơn 10,000đ';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Xác nhận'),
              onPressed: () {
                // Kiểm tra form hợp lệ
                if (formKey.currentState!.validate()) {
                  final amount = int.parse(amountController.text);
                  // Đóng dialog trước
                  Navigator.of(dialogContext).pop();
                  // Sau đó gọi hàm xử lý thanh toán với số tiền đã nhập
                  _handleTopUpWithVnpay(amount);
                }
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _handleTopUpWithVnpay(int amount) async {
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
        _refreshWallet();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWallet,
          )
        ],
      ),
      // SỬ DỤNG CONSUMER ĐỂ LẮNG NGHE WALLETPROVIDER
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          // Trạng thái đang tải
          if (walletProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái không có dữ liệu (lỗi hoặc chưa đăng nhập)
          if (walletProvider.balance == null || walletProvider.transactions == null) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Không thể tải dữ liệu ví."), ElevatedButton(onPressed: _refreshWallet, child: const Text("Thử lại"))]));
          }

          // Trạng thái có dữ liệu
          final double balance = walletProvider.balance!;
          final List<TransactionModel> transactions = walletProvider.transactions!;

          return RefreshIndicator(
            onRefresh: _refreshWallet,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(_userName, balance),
                    const SizedBox(height: 30),
                    _buildTopUpSection(),
                    const SizedBox(height: 30),
                    _buildTransactionHistory(transactions),
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
              _showTopUpDialog,
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
    // THÊM BƯỚC LỌC DỮ LIỆU Ở ĐÂY
    // Giả sử trạng thái hoàn thành có tên là 'completed' trong model của bạn
    final completedTransactions = transactions
        .where((transaction) => transaction.status == 'completed')
        .toList();

    // Kiểm tra danh sách SAU KHI đã lọc
    if (completedTransactions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Text("Chưa có giao dịch nào hoàn thành."),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lịch sử giao dịch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Sử dụng danh sách đã lọc để build ListView
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: completedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = completedTransactions[index]; // Lấy từ danh sách đã lọc
            bool isCredit = transaction.amount > 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red),
              ),
              title: Text(
                  _getTransactionTitle(transaction.type), // Dùng hàm helper cho gọn
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
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
  // (Tùy chọn) Thêm hàm helper để dịch 'type' ra Tiếng Việt
  String _getTransactionTitle(String type) {
    switch (type) {
      case 'deposit':
        return 'Nạp tiền vào ví';
      case 'payment':
        return 'Thanh toán đơn hàng';
      case 'withdraw':
        return 'Rút tiền';
      default:
        return 'Giao dịch khác';
    }
  }
}