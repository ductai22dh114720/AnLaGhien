import 'dart:ui'; // Import để sử dụng ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/login_screen.dart';

// Model và danh sách contents giữ nguyên
class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

List<OnboardingContent> contents = [
  OnboardingContent(
    image: 'assets/onboarding_1.png',
    title: 'Khám phá món ăn yêu thích',
    description:
        'Tìm kiếm và khám phá hàng ngàn món ăn ngon từ các nhà hàng xung quanh bạn một cách dễ dàng.',
  ),
  OnboardingContent(
    image: 'assets/onboarding_2.png',
    title: 'Giao hàng nhanh chóng',
    description:
        'Đặt hàng chỉ với vài cú chạm và nhận món ăn nóng hổi được giao đến tận cửa nhà bạn trong tích tắc.',
  ),
  OnboardingContent(
    image: 'assets/onboarding_3.png',
    title: 'Thanh toán an toàn',
    description:
        'Tận hưởng nhiều phương thức thanh toán tiện lợi, an toàn và nhận nhiều ưu đãi hấp dẫn.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lớp nền PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: contents.length,
            itemBuilder: (_, i) {
              return Image.asset(
                contents[i].image,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),

          // Lớp phủ gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Nội dung
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // --- CẢI TIẾN: NÚT "Bỏ qua" với nền blur ---
                  _buildSkipButton(),

                  const Spacer(),

                  _buildTextContent(),

                  const SizedBox(height: 30),

                  // --- CẢI TIẾN: Nút điều hướng có cursor pointer ---
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CẢI TIẾN 2: NÚT BỎ QUA VỚI NỀN BLUR VÀ POINTER
  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Màu nền mờ
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ), // Viền mờ
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click, // Hiển thị con trỏ tay
                child: TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget cho phần nội dung Text (giữ nguyên)
  Widget _buildTextContent() {
    // ... code giữ nguyên ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            contents[_currentPageIndex].title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            contents[_currentPageIndex].description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // CẢI TIẾN 1: THÊM POINTER CHO CÁC NÚT BẤM
  Widget _buildBottomNavigation() {
    bool isLastPage = _currentPageIndex == contents.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dấu chấm chỉ báo
          Row(
            children: List.generate(
              contents.length,
              (index) => buildDot(index),
            ),
          ),

          // Nút "Tiếp theo" / "Bắt đầu"
          MouseRegion(
            cursor: SystemMouseCursors.click, // Con trỏ tay cho toàn bộ nút
            child: SizedBox(
              height: 60,
              width: isLastPage ? 140 : 60,
              child: ElevatedButton(
                onPressed: () {
                  if (isLastPage) {
                    _navigateToLogin();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape:
                      isLastPage
                          ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                          : const CircleBorder(),
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child:
                      isLastPage
                          ? const Text(
                            "Bắt đầu",
                            key: ValueKey('get_started_text'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                          : const Icon(
                            Icons.arrow_forward_ios,
                            key: ValueKey('next_icon'),
                            color: Colors.white,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho một dấu chấm chỉ báo (giữ nguyên)
  Widget buildDot(int index) {
    // ... code giữ nguyên ...
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10,
      width: _currentPageIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            _currentPageIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
      ),
    );
  }
}
