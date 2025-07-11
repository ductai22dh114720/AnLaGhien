import 'package:flutter/material.dart';
// Import màn hình Splash của bạn
import 'package:flutter_dapm/features/authentication/screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      debugShowCheckedModeBanner: false, // Tắt banner "Debug"
      theme: ThemeData(
        // Định nghĩa màu chủ đạo cho toàn bộ ứng dụng
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white, // Màu nền mặc định
        fontFamily: 'Poppins', // Ví dụ sử dụng một font chữ đẹp
      ),
      // Màn hình đầu tiên của ứng dụng
      home: const SplashScreen(),
    );
  }
}
