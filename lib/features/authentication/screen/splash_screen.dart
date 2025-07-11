import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/login_screen.dart';
import 'package:flutter_dapm/features/authentication/screen/signup_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/home_screen.dart'; // Giả sử màn hình tiếp theo là Login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Controller để điều khiển animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // --- Cấu hình Animation ---
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Thời gian của animation
    );

    // Animation mờ dần từ 0 (trong suốt) đến 1 (rõ nét)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Animation phóng to từ 0.8 đến 1.0
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Hiệu ứng nảy nhẹ
      ),
    );

    // Bắt đầu chạy animation
    _animationController.forward();

    // --- Hẹn giờ để chuyển màn hình ---
    Timer(const Duration(seconds: 3), () {
      // Sử dụng pushReplacement để người dùng không thể quay lại màn hình Splash
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Home(), // Thay bằng màn hình bạn muốn
        ),
      );
    });
  }

  @override
  void dispose() {
    // Giải phóng controller để tránh rò rỉ bộ nhớ
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền chủ đạo
      backgroundColor: Colors.deepOrange,
      body: Center(
        // Sử dụng ScaleTransition và FadeTransition để áp dụng animation
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hiển thị logo của bạn
                Image.asset(
                  'assets/logo_splash.png', // Đảm bảo đường dẫn đúng
                  width: 150, // Điều chỉnh kích thước logo nếu cần
                ),
                const SizedBox(height: 20),
                // Có thể thêm tên ứng dụng hoặc slogan ở đây
                const Text(
                  'Food App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
