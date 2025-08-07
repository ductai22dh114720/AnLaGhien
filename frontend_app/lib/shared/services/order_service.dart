import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/cart_model.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  OrderService() {
    // Interceptor để tự động thêm token vào mỗi request, code này rất tốt!
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        // In lỗi ra console để debug
        debugPrint('Lỗi Dio: ${e.message}');
        if (e.response != null) {
          debugPrint('Data lỗi từ server: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  // Hàm tạo đơn hàng mới từ giỏ hàng
  Future<bool> createOrder({
    required CartModel cart, // Đổi tên model cho đúng
    required String deliveryAddress,
    required String paymentMethod,
    String? notes, // Tham số này không bắt buộc
  }) async {
    try {
      // SỬA LẠI URL CHO ĐÚNG VỚI BACKEND
      // Endpoint để tạo đơn hàng là '/orders' với phương thức POST
      const url = '${ApiConfig.baseUrl}/orders';

      // CHUẨN BỊ DỮ LIỆU GỬI ĐI
      // Backend sẽ tự lấy thông tin giỏ hàng từ token của user
      // Chúng ta chỉ cần gửi thông tin mà backend không có: địa chỉ và phương thức thanh toán
      final Map<String, dynamic> orderData = {
        'address': deliveryAddress,
        'paymentMethod': paymentMethod, // 'wallet' hoặc 'cod'
        // 'notes': notes, // Nếu backend có hỗ trợ thì gửi
      };

      debugPrint("Gửi yêu cầu POST đến: $url");
      debugPrint("Với dữ liệu: $orderData");

      final response = await _dio.post(url, data: orderData);

      // Khi tạo mới thành công, status code chuẩn là 201 (Created)
      return response.statusCode == 201;

    } on DioException catch (e) {
      // Interceptor đã in lỗi, ở đây chỉ cần log thêm nếu cần
      debugPrint("Lỗi DioException khi tạo đơn hàng trong OrderService: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Lỗi không xác định khi tạo đơn hàng: $e");
      return false;
    }
  }
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      const url = '${ApiConfig.baseUrl}/orders';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Chuyển đổi list JSON thành list OrderModel
        final List<dynamic> orderData = response.data;
        return orderData.map((json) => OrderModel.fromJson(json)).toList();
      }
      return []; // Trả về list rỗng nếu có lỗi không mong muốn
    } catch (e) {
      debugPrint("Lỗi khi lấy lịch sử đơn hàng: $e");
      return []; // Trả về list rỗng khi có exception
    }
  }
}