import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  PaymentService() {
    // Thêm Interceptor để tự động gắn token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Hàm tạo yêu cầu thanh toán VNPay
  Future<String?> createVnpayPaymentUrl(int amount) async {
    try {
      const String apiUrl = '${ApiConfig.baseUrl}/payment/vnpay-create';
      final response = await _dio.post(apiUrl, data: {'amount': amount});

      if (response.statusCode == 200 && response.data['paymentUrl'] != null) {
        return response.data['paymentUrl'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Lỗi khi tạo URL VNPay: $e');
      return null;
    }
  }
}