import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/cart_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  OrderService() {
    // Interceptor để tự động thêm token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Hàm tạo đơn hàng mới từ giỏ hàng
  Future<bool> createOrder({
    required CartModel cart,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // Chuẩn bị dữ liệu `items` theo đúng định dạng mà backend yêu cầu
      final itemsData = cart.items.map((item) => {
        'menuItem': item.menuItem.id,
        'quantity': item.quantity,
        'priceAtOrder': item.menuItem.price,
      }).toList();

      final Map<String, dynamic> orderData = {
        // Giả sử giỏ hàng chỉ có sản phẩm từ 1 nhà hàng
        // Bạn cần thêm logic để lấy restaurantId này
        'restaurantId': "RESTAURANT_ID_CUA_BAN", // <<-- THAY THẾ BẰNG ID NHÀ HÀNG THẬT
        'items': itemsData,
        'totalAmount': cart.totalPrice,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'notes': notes ?? '',
      };

      const url = '${ApiConfig.baseUrl}/orders/create';
      final response = await _dio.post(url, data: orderData);

      return response.statusCode == 201; // Trả về true nếu tạo thành công

    } catch (e) {
      debugPrint("Lỗi khi tạo đơn hàng: $e");
      return false;
    }
  }
}