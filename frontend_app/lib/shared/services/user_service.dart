import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  UserService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tự động thêm token vào header cho mỗi request
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<UserModel?> uploadAvatar(File imageFile) async {
    try {
      const String url = '${ApiConfig.baseUrl}/user/avatar';

      // Tạo FormData để gửi file
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        // 'avatar' phải khớp với tên trong upload.single('avatar') ở backend
        "avatar": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi upload avatar: $e");
      return null;
    }
  }
  Future<UserModel?> getUserProfile() async {
    try {
      const String url = '${ApiConfig.baseUrl}/user/profile';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi lấy profile: $e");
      return null;
    }
  }
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      const String url = '${ApiConfig.baseUrl}/user/profile';
      final response = await _dio.put(url, data: userData); // Dùng phương thức PUT
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi khi cập nhật profile: $e");
      return false;
    }
  }
}