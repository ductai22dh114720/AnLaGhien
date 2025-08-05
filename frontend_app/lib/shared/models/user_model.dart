// File: lib/shared/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? avatarUrl; // Thêm trường này

  UserModel({
    required this.id, required this.name, required this.email,
    required this.phone, required this.address, this.avatarUrl
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      avatarUrl: json['avatarUrl'], // Có thể null
    );
  }
}