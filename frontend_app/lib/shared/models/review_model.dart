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

// <<< THÊM MODEL CON CHO THÔNG TIN KHÁCH HÀNG >>>
class ReviewCustomerInfo {
  final String id;
  final String name;
  final String? avatarUrl;

  ReviewCustomerInfo({required this.id, required this.name, this.avatarUrl});

  factory ReviewCustomerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewCustomerInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Anonymous User',
      avatarUrl: json['avatarUrl'],
    );
  }
}

// <<< THÊM MODEL CON CHO THÔNG TIN SẢN PHẨM TRONG ĐƠN HÀNG >>>
class ReviewOrderItem {
  final String name;
  final String? imageUrl;

  ReviewOrderItem({required this.name, this.imageUrl});

  factory ReviewOrderItem.fromJson(Map<String, dynamic> json) {
    return ReviewOrderItem(
      name: json['name'] ?? 'Unknown Product',
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
  final ReviewCustomerInfo customer;
  final List<ReviewOrderItem> orderItems;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.restaurant,
    required this.customer,
    required this.orderItems,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Lấy thông tin sản phẩm từ object 'order' được populate
    final orderData = json['order'] as Map<String, dynamic>?;
    final itemsList = (orderData?['items'] as List? ?? [])
        .map((item) => ReviewOrderItem.fromJson(item['menuItem'] ?? {}))
        .toList();

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
      // <<< THÊM VÀO FACTORY >>>
      customer: json['customer'] != null
          ? ReviewCustomerInfo.fromJson(json['customer'])
          : ReviewCustomerInfo(id: '', name: 'Anonymous User'),
      orderItems: itemsList,
    );
  }
}