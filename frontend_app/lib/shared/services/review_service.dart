// lib/shared/services/review_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/review_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReviewService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ReviewService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('Lỗi Dio trong ReviewService: ${e.response?.data ?? e.message}');
        return handler.next(e);
      },
    ));
  }

  // Gửi một đánh giá mới
  Future<bool> postReview({
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    try {
      const url = '${ApiConfig.baseUrl}/reviews';
      final response = await _dio.post(
        url,
        data: {
          'orderId': orderId,
          'rating': rating,
          'comment': comment,
        },
      );
      return response.statusCode == 201; // Created
    } catch (e) {
      debugPrint("Lỗi khi gửi đánh giá: $e");
      return false;
    }
  }

  // Lấy chi tiết đánh giá theo ID đơn hàng
  Future<ReviewModel?> getReviewByOrderId(String orderId) async {
    try {
      final url = '${ApiConfig.baseUrl}/reviews/by-order/$orderId';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return ReviewModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi khi lấy chi tiết đánh giá: $e");
      return null;
    }
  }

  // Lấy tất cả đánh giá của người dùng
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      const url = '${ApiConfig.baseUrl}/reviews/my-reviews';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi khi lấy danh sách đánh giá: $e");
      return [];
    }
  }
}