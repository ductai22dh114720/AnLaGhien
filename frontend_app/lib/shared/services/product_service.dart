import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';

class ProductService {
  final Dio _dio = Dio();

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
}