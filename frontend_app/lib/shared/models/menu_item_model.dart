class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}