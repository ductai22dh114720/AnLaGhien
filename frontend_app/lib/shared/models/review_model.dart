// lib/shared/models/review_model.dart

// Model con để chứa thông tin nhà hàng được populate từ backend
class ReviewRestaurantInfo {
  final String id;
  final String name;
  final String? imageUrl;

  ReviewRestaurantInfo({required this.id, required this.name, this.imageUrl});

  factory ReviewRestaurantInfo.fromJson(Map<String, dynamic> json) {
    return ReviewRestaurantInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Restaurant',
      imageUrl: json['imageUrl'],
    );
  }
}

class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final ReviewRestaurantInfo restaurant;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.restaurant,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      restaurant: json['restaurant'] != null
          ? ReviewRestaurantInfo.fromJson(json['restaurant'])
          : ReviewRestaurantInfo(id: '', name: 'Unknown Restaurant'),
    );
  }
}