import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/models/address_suggestion_model.dart';

class AddressService {
  final Dio _dio = Dio();
  // Endpoint của Nominatim (dịch vụ Geocoding của OpenStreetMap)
  final String _baseUrl = 'https://nominatim.openstreetmap.org';

  Future<List<AddressSuggestion>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Thêm "Việt Nam" vào query để ưu tiên kết quả
      final fullQuery = '$query, Việt Nam';

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': fullQuery,
          'format': 'json',
          'addressdetails': '1', // Lấy thêm chi tiết địa chỉ
          'limit': 5, // Giới hạn 5 kết quả
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => AddressSuggestion.fromJson(json)).toList();

    } catch (e) {
      debugPrint("Lỗi khi lấy gợi ý địa chỉ từ Nominatim: $e");
      return [];
    }
  }
}