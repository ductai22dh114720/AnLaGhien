import 'package:flutter/material.dart';

class TextBottom extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obsCureText;

  const TextBottom({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obsCureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obsCureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent),
        ),
      ),
    );
  }
}
