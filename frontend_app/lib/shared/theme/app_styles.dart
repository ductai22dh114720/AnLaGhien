import 'package:flutter/material.dart';

class WidgetSupport {
  static TextStyle boldTextFeildStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      fontFamily: 'Anton',
    );
  }

  static TextStyle HeadlineTextFeildStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Anton',
    );
  }

  static TextStyle LightTextFeildStyle() {
    return TextStyle(
      color: Colors.black54, // Màu xám nhẹ
      fontSize: 15.0,
      fontWeight: FontWeight.w500, // Độ đậm vừa phải
    );
  }
}
