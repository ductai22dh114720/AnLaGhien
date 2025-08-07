class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  // --- THÊM CÁC TRƯỜNG CÒN THIẾU ---
  final String? description;
  final String? restaurantId; // ID của nhà hàng mà món ăn này thuộc về
  final String? category;
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    // --- THÊM VÀO CONSTRUCTOR ---
    this.description,
    this.restaurantId,
    this.category,
    required this.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    // Xử lý restaurant object lồng nhau
    String? restId;
    if (json['restaurant'] is String) {
      restId = json['restaurant'];
    } else if (json['restaurant'] is Map<String, dynamic>) {
      restId = json['restaurant']['_id'];
    }

    return MenuItemModel(
      id: json['_id'],
      name: json['name'] ?? 'N/A',
      price: (json['price'] as num? ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      // --- LẤY DỮ LIỆU TỪ JSON ---
      description: json['description'],
      restaurantId: restId,
      category: json['category'],
      isAvailable: json['isAvailable'] ?? false, // Mặc định là false nếu không có
    );
  }
}