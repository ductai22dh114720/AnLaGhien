// File: lib/shared/services/wallet_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/transaction_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  WalletService() {
    // Sử dụng Interceptor để tự động thêm JWT token vào header của mỗi request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Đọc token từ bộ nhớ an toàn
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            // Thêm header Authorization
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Cho phép request tiếp tục
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Xử lý lỗi (ví dụ: token hết hạn - 401 Unauthorized)
          debugPrint('Lỗi Interceptor: ${e.response?.statusCode} - ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Hàm để lấy thông tin ví và lịch sử giao dịch
  Future<Map<String, dynamic>?> getWalletInfo() async {
    try {
      const String url = '${ApiConfig.baseUrl}/wallet/info';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Lấy dữ liệu từ response
        final double balance = (response.data['balance'] as num).toDouble();
        final List<dynamic> transactionsJson = response.data['transactions'];

        // Chuyển đổi list JSON thành list các đối tượng TransactionModel
        final List<TransactionModel> transactions = transactionsJson
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        // Trả về một Map chứa cả hai thông tin
        return {
          'balance': balance,
          'transactions': transactions,
        };
      }
      return null; // Trả về null nếu status code không phải 200
    } catch (e) {
      debugPrint("Lỗi khi lấy thông tin ví: $e");
      return null; // Trả về null nếu có lỗi xảy ra
    }
  }
}