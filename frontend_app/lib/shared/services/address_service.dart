import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dapm/shared/models/address_suggestion_model.dart';

class AddressService {
  late final Dio _dio;
  // Endpoint của Nominatim (dịch vụ Geocoding của OpenStreetMap)
  final String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Constructor để cấu hình Dio
  AddressService() {
    // Tạo một đối tượng Options để thiết lập header mặc định
    final baseOptions = BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        // <<-- ĐÂY LÀ THAY ĐỔI QUAN TRỌNG NHẤT -->>
        // Thêm User-Agent để tuân thủ chính sách của OpenStreetMap
        'User-Agent': 'AnLaGhienApp/1.0 (anlaghien.app.contact@email.com)',
      },
    );
    _dio = Dio(baseOptions);
  }

  Future<List<AddressSuggestion>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final fullQuery = '$query, Việt Nam';
      // Không cần truyền baseUrl nữa vì đã có trong BaseOptions
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': fullQuery,
          'format': 'json',
          'addressdetails': '1',
          'limit': 5,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => AddressSuggestion.fromJson(json)).toList();

    } catch (e) {
      debugPrint("Lỗi khi lấy gợi ý địa chỉ từ Nominatim: $e");
      return [];
    }
  }
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
        },
      );
      final List<dynamic> data = response.data;
      if (data.isNotEmpty) {
        final firstResult = data[0];
        final lat = double.tryParse(firstResult['lat']);
        final lon = double.tryParse(firstResult['lon']);
        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi chuyển đổi địa chỉ thành tọa độ: $e");
      return null;
    }
  }
}