// File: lib/shared/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;      // <<-- SỬA: Cho phép null
  final String? address;    // <<-- SỬA: Cho phép null
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,         // <<-- SỬA: Không còn là required
    this.address,       // <<-- SỬA: Không còn là required
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Cung cấp giá trị mặc định an toàn cho các trường không thể null
      id: json['_id'] ?? '', // Nếu _id là null, trả về chuỗi rỗng
      name: json['name'] ?? 'Người dùng mới', // Nếu name là null, trả về giá trị mặc định
      email: json['email'] ?? '', // Nếu email là null, trả về chuỗi rỗng
      role: json['role'] ?? 'customer',

      // Các trường nullable có thể nhận giá trị null trực tiếp
      phone: json['phone'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
    );
  }
}