import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/models/address_model.dart';

class AddressService {
  final Dio _dio = Dio();
  // Sửa lại Base URL để bao gồm /api
  final String _baseUrl = 'https://provinces.open-api.vn/api';

  Future<List<Province>> getProvinces() async {
    try {
      // Endpoint đúng là /p/
      final response = await _dio.get('$_baseUrl/p/');
      final List<dynamic> data = response.data;
      // API này trả về `code` và `name`
      return data
          .map((json) => Province(id: json['code'], name: json['name']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching provinces: $e");
      return [];
    }
  }

  Future<List<District>> getDistricts(int provinceCode) async {
    try {
      // Endpoint đúng là /p/{provinceCode}?depth=2
      final response = await _dio.get('$_baseUrl/p/$provinceCode?depth=2');
      final List<dynamic> data = response.data['districts'];
      // API này trả về `code` và `name`
      return data
          .map((json) => District(id: json['code'], name: json['name']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching districts: $e");
      return [];
    }
  }

  Future<List<Ward>> getWards(int districtCode) async {
    try {
      // Endpoint đúng là /d/{districtCode}?depth=2
      final response = await _dio.get('$_baseUrl/d/$districtCode?depth=2');
      final List<dynamic> data = response.data['wards'];
      // API này trả về `code` và `name`
      return data
          .map((json) => Ward(id: json['code'], name: json['name']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching wards: $e");
      return [];
    }
  }
}
