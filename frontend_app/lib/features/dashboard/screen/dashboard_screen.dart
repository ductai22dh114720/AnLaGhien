import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/home_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/profile_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Sửa lại tên các class màn hình con cho đúng
  final List<Widget> _pages = [
    const HomeScreen(),
    const OrderScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  // Hàm xây dựng item cho thanh điều hướng, đã được tối ưu cho bảng màu
  Widget _buildNavItem(IconData iconData, String text, int index) {
    bool isSelected = _currentIndex == index;

    // Màu của Icon:
    // - Khi được chọn: màu cam (deepOrange) để nằm trên nền nút màu trắng.
    // - Khi không được chọn: màu trắng (white) để nằm trên nền bar màu cam.
    final iconColor = isSelected ? Colors.deepOrange : Colors.white;

    // Màu của Text:
    // - Luôn là màu trắng để dễ đọc trên nền bar màu cam.
    // - Khi được chọn sẽ sáng hơn và in đậm.
    final textColor = isSelected ? Colors.white : Colors.white.withOpacity(0.8);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 28,
        ), // Tăng kích thước icon một chút
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu đen từ bảng màu sẽ được sử dụng cho các trang có nền trắng.
    // Màu trắng sẽ là màu nền chính của các trang.
    // Màu cam sẽ là màu nhấn, dùng cho AppBar, BottomBar, Button...

    return Scaffold(
      // Các trang con (Home, Order,...) nên có nền trắng để phù hợp.
      // backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        // ===================================
        // CẬP NHẬT MÀU SẮC THEO BẢNG MÀU
        // ===================================

        // Nền chính của thanh điều hướng
        color: Colors.deepOrange,

        // Màu của vòng tròn nút được chọn -> Hiệu ứng Inverted
        buttonBackgroundColor: Colors.white,

        // Màu của khoảng trống phía sau đường cong (màu nền của trang)
        backgroundColor: Colors.transparent,

        // ===================================
        height: 65,
        animationDuration: Duration(milliseconds: 350),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          _buildNavItem(Icons.home, "Trang chủ", 0),
          _buildNavItem(Icons.shopping_bag, "Đơn hàng", 1),
          _buildNavItem(Icons.wallet_outlined, "Ví tiền", 2),
          _buildNavItem(Icons.person, "Cá nhân", 3),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}
