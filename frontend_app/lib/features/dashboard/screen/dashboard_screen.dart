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
  late Animation<double> _verticalMainScreenSlideAnimation;

  // Animation cho lớp đệm (cam)
  late Animation<double> _middleLayerScaleAnimation;
  late Animation<double> _middleLayerSlideAnimation;
  late Animation<double> _verticalSlideAnimation;

  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  int _currentTabIndex = 0;
  int? _orderScreenInitialTabIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    final curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _slideAnimation = Tween<double>(begin: 0, end: 240).animate(curvedAnimation);
    // Màn hình chính co lại 20% và trượt nhiều
    _mainScreenScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _mainScreenSlideAnimation = Tween<double>(begin: 0, end: 270).animate(curvedAnimation);

    // Lớp đệm co lại 10% và trượt ít hơn
    _middleLayerScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(curvedAnimation);
    _middleLayerSlideAnimation = Tween<double>(begin: 0, end: 260).animate(curvedAnimation);

    // Trượt xuống dưới 50 pixels khi mở
    _verticalSlideAnimation = Tween<double>(begin: 0, end: 70).animate(curvedAnimation);
    _verticalMainScreenSlideAnimation = Tween<double>(begin: 0, end: 50).animate(curvedAnimation);
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
      _orderScreenInitialTabIndex = 0;
    });
    if (isMenuOpen) {
      toggleMenu();
    }
  }


  void navigateToOrderTab(int orderTabIndex) {
    setState(() {
      // Đặt index cho OrderScreen
      _orderScreenInitialTabIndex = orderTabIndex;
      // Chuyển sang tab của OrderScreen (index là 2 trong list _pages)
      _currentTabIndex = 2;
    });
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

          // Lớp 2: Lớp đệm màu trắng đục
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Padding(
                // Khi menu mở, thêm padding bên phải để tạo khoảng trống
                padding: EdgeInsets.only(right: _animationController.value * 60),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_middleLayerSlideAnimation.value, _verticalSlideAnimation.value * 0.5)
                    ..scale(_middleLayerScaleAnimation.value),
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
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
                  ..translate(_mainScreenSlideAnimation.value,_verticalMainScreenSlideAnimation.value)
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
                  navigateToOrderTab: navigateToOrderTab,
                  orderScreenInitialTabIndex: _orderScreenInitialTabIndex ?? 0,
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
  final Function(int) navigateToOrderTab;
  final int orderScreenInitialTabIndex;

  const MainScreen({
    super.key,
    required this.toggleMenu,
    required this.onTabChange,
    required this.currentTabIndex,
    required this.navigateToOrderTab,
    required this.orderScreenInitialTabIndex,
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
      OrderScreen(initialTabIndex: widget.orderScreenInitialTabIndex),
      ProfileScreen(navigateToOrderTab: widget.navigateToOrderTab),
    ];
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu index thay đổi, khởi tạo lại pages để truyền đúng giá trị
    if (widget.orderScreenInitialTabIndex != oldWidget.orderScreenInitialTabIndex ||
        widget.currentTabIndex != oldWidget.currentTabIndex) {
      _pages = [
        HomeScreen(toggleMenu: widget.toggleMenu),
        const WalletScreen(),
        OrderScreen(initialTabIndex: widget.orderScreenInitialTabIndex),
        ProfileScreen(navigateToOrderTab: widget.navigateToOrderTab),
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: widget.currentTabIndex, children: _pages),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // WIDGET MỚI: Tạo Bottom Nav Bar tùy chỉnh
  Widget _buildCustomBottomNavBar() {
    // Danh sách các icon cho bottom nav
    final List<IconData> icons = [
      Icons.home_filled,
      Icons.wallet,
      Icons.restaurant_menu,
      Icons.person,
    ];

    return Container(
      height: 70, // Tăng chiều cao
      decoration: const BoxDecoration(
        color: Color(0xFFFF4B3A), // Màu cam đậm
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          return _buildNavItem(
              icon: icons[index],
              index: index,
              isSelected: widget.currentTabIndex == index,
              onTap: widget.onTabChange
          );
        }),
      ),
    );
  }

  // WIDGET MỚI: Tạo từng item cho thanh Nav Bar
  Widget _buildNavItem({required IconData icon, required int index, required bool isSelected, required Function(int) onTap}) {
    return IconButton(
      onPressed: () => onTap(index),
      iconSize: 32, // Tăng kích thước icon
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
      ),
    );
  }
}