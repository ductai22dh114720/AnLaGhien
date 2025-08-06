import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/cart_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  CartService() {
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

  Future<CartModel?> getCart() async {
    try {
      const url = '${ApiConfig.baseUrl}/cart';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi lấy giỏ hàng: $e");
      return null;
    }
  }

  Future<CartModel?> addItem(String menuItemId, int quantity) async {
    try {
      const url = '${ApiConfig.baseUrl}/cart/add';
      final response = await _dio.post(url, data: {
        'menuItemId': menuItemId,
        'quantity': quantity,
      });
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi thêm vào giỏ: $e");
      return null;
    }
  }
  Future<CartModel?> removeItem(String menuItemId) async {
    try {
      // Sử dụng phương thức DELETE
      final url = '${ApiConfig.baseUrl}/cart/remove/$menuItemId';
      final response = await _dio.delete(url);
      if (response.statusCode == 200) {
        return CartModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi xóa sản phẩm khỏi giỏ: $e");
      return null;
    }
  }

  Future<bool> clearCart() async {
    try {
      const url = '${ApiConfig.baseUrl}/cart/clear';
      final response = await _dio.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi khi xóa giỏ hàng: $e");
      return false;
    }
  }
}
// TODO: Viết thêm hàm removeItem, clearCart
