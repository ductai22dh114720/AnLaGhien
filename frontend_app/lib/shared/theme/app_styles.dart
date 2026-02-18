import 'package:flutter/material.dart';

// Đổi tên class cho đúng quy ước
class AppStyles {
  // Sửa tên hàm thành lowerCamelCase
  static TextStyle boldTextFeildStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      fontFamily: 'Anton',
    );
  }

  // Sửa tên hàm thành lowerCamelCase
  static TextStyle headlineTextFeildStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Anton',
    );
  }

  // Sửa tên hàm thành lowerCamelCase
  static TextStyle lightTextFeildStyle() {
    return const TextStyle(
      color: Colors.black54,
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
    );
  }
}