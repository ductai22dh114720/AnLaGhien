import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ProductService() {
    // Thêm Interceptor để tự động gửi token
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

  // Hàm cũ: Lấy tất cả menu items (public)
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      const url = '${ApiConfig.baseUrl}/menu-items';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MenuItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi khi lấy danh sách món ăn: $e");
      return [];
    }
  }

  // --- CÁC HÀM MỚI CHO ADMIN ---

  // [ADMIN] Tạo món ăn mới
  Future<MenuItemModel?> createMenuItem(Map<String, dynamic> data) async {
    try {
      const url = '${ApiConfig.baseUrl}/menu-items';
      final response = await _dio.post(url, data: data);
      if (response.statusCode == 201) {
        return MenuItemModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi tạo món ăn: $e");
      return null;
    }
  }

  // [ADMIN] Cập nhật món ăn
  Future<MenuItemModel?> updateMenuItem(String id, Map<String, dynamic> data) async {
    try {
      final url = '${ApiConfig.baseUrl}/menu-items/$id';
      final response = await _dio.put(url, data: data);
      if (response.statusCode == 200) {
        return MenuItemModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi cập nhật món ăn: $e");
      return null;
    }
  }

  // [ADMIN] Xóa món ăn
  Future<bool> deleteMenuItem(String id) async {
    try {
      final url = '${ApiConfig.baseUrl}/menu-items/$id';
      final response = await _dio.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi khi xóa món ăn: $e");
      return false;
    }
  }
}
