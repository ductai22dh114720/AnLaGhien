import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/home_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/menu_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/profile_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _animationController;
  // Animation cho màn hình chính (trắng)
  late Animation<double> _mainScreenScaleAnimation;
  late Animation<double> _mainScreenSlideAnimation;
  // Animation cho lớp đệm (cam)
  late Animation<double> _middleLayerScaleAnimation;
  late Animation<double> _middleLayerSlideAnimation;
  late Animation<double> _verticalSlideAnimation;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    final curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    // Màn hình chính co lại 20% và trượt nhiều
    _mainScreenScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _mainScreenSlideAnimation = Tween<double>(begin: 0, end: 240).animate(curvedAnimation);

    // Lớp đệm co lại 10% và trượt ít hơn
    _middleLayerScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _middleLayerSlideAnimation = Tween<double>(begin: 0, end: 220).animate(curvedAnimation);

    // Trượt xuống dưới 50 pixels khi mở
    _verticalSlideAnimation = Tween<double>(begin: 0, end: 50).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    isMenuOpen = !isMenuOpen;
    if (isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  void changeTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    if (isMenuOpen) {
      toggleMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFA4A0C), // Màu nền gốc
      body: Stack(
        children: [
          // Lớp 1: MenuScreen
          MenuScreen(
            onMenuItemTap: (index) => changeTab(index),
            currentTabIndex: _currentTabIndex,
            onSignOut: () { /* TODO: Logic đăng xuất */ },
          ),

          // Lớp 2: Lớp đệm màu cam
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(_middleLayerSlideAnimation.value,_verticalSlideAnimation.value * 0.5)
                  ..scale(_middleLayerScaleAnimation.value),
                alignment: Alignment.centerLeft,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                // Bo góc cho lớp đệm
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),

          // Lớp 3: Màn hình chính
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(_mainScreenSlideAnimation.value)
                  ..scale(_mainScreenScaleAnimation.value),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_animationController.value * 30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_animationController.value * 0.25),
                        blurRadius: 30.0,
                        offset: const Offset(-5, 0), // Đổ bóng sang trái
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_animationController.value * 30),
                    child: child,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: isMenuOpen ? toggleMenu : null,
              onPanUpdate: (details) {
                if (details.delta.dx > 4 && !isMenuOpen) toggleMenu();
                if (details.delta.dx < -4 && isMenuOpen) toggleMenu();
              },
              child: AbsorbPointer(
                absorbing: isMenuOpen,
                child: MainScreen(
                  toggleMenu: toggleMenu,
                  onTabChange: (index) => changeTab(index),
                  currentTabIndex: _currentTabIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleMenu;
  final Function(int) onTabChange;
  final int currentTabIndex;

  const MainScreen({
    super.key,
    required this.toggleMenu,
    required this.onTabChange,
    required this.currentTabIndex,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(toggleMenu: widget.toggleMenu),
      const WalletScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: IndexedStack(index: widget.currentTabIndex, children: _pages),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // WIDGET MỚI: Tạo Bottom Nav Bar tùy chỉnh
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 70, // Chiều cao của thanh nav
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_outlined, index: 0),
          _buildNavItem(icon: Icons.account_balance_wallet_outlined, index: 1),
          _buildNavItem(icon: Icons.receipt_long_outlined, index: 2),
          _buildNavItem(icon: Icons.person_outline, index: 3),
        ],
      ),
    );
  }

  // WIDGET MỚI: Tạo từng item cho thanh Nav Bar
  Widget _buildNavItem({required IconData icon, required int index}) {
    bool isSelected = widget.currentTabIndex == index;
    return InkWell(
      onTap: () => widget.onTabChange(index),
      borderRadius: BorderRadius.circular(30), // Bo tròn hiệu ứng nhấn
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiệu ứng gạch chân
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: isSelected ? 25 : 0, // Chiều rộng thay đổi khi được chọn
              decoration: BoxDecoration(
                color: const Color(0xFFFA4A0C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFA4A0C) : const Color(0xFFADADAF),
              size: 28,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}