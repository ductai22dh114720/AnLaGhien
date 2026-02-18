// lib/shared/provider/wallet_provider.dart

import 'package:flutter/material.dart';
// Đảm bảo bạn đã có model này
import 'package:flutter_dapm/shared/models/transaction_model.dart';
import 'package:flutter_dapm/shared/services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();

  // Sửa lại các biến state để lưu trữ thông tin mới
  double? _balance; // Số dư
  List<TransactionModel>? _transactions; // Lịch sử giao dịch

  // Tạo các getter để các widget khác có thể truy cập
  double? get balance => _balance;
  List<TransactionModel>? get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Hàm để tải thông tin ví từ server
  Future<void> fetchWallet() async {
    _isLoading = true;
    notifyListeners(); // Thông báo để UI hiển thị loading

    // Gọi hàm getWalletInfo từ service của bạn
    final walletData = await _walletService.getWalletInfo();

    if (walletData != null) {
      // Nếu có dữ liệu, gán giá trị cho các biến state
      _balance = walletData['balance'];
      _transactions = walletData['transactions'];
    } else {
      // Nếu không có dữ liệu (lỗi hoặc null), reset các giá trị
      _balance = null;
      _transactions = null;
    }

    _isLoading = false;
    notifyListeners(); // Thông báo để UI cập nhật số dư và giao dịch mới
  }

  // Hàm để xóa thông tin ví khi đăng xuất
  void clearWallet() {
    _balance = null;
    _transactions = null;
    notifyListeners();
  }
}