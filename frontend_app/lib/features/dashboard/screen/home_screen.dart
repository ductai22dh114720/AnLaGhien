import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/features/authentication/screen/details_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/search_screen.dart';
//Import Provider
import 'package:flutter_dapm/shared/provider/user_provider.dart';

//Import Widget
import 'package:flutter_dapm/shared/widgets/app_bar_cart_icon.dart';


import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleMenu;

  const HomeScreen({super.key, required this.toggleMenu});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MenuItemModel>> _menuItemsFuture;
  final ProductService _productService = ProductService();
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.fastfood_outlined, 'name': 'Snacks'},
    {'icon': Icons.restaurant_menu_outlined, 'name': 'Meal'},
    {'icon': Icons.eco_outlined, 'name': 'Vegan'},
    {'icon': Icons.cake_outlined, 'name': 'Dessert'},
    {'icon': Icons.local_drink_outlined, 'name': 'Drinks'},
  ];


  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _productService.getAllMenuItems();
  }

  void _navigateToDetails(MenuItemModel item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          DetailsScreen(
            menuItemId: item.id,
            imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
            title: item.name,
            description: item.description ?? "Chưa có mô tả.",
            price: item.price,
          ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9A825), // Màu nền vàng
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Phần Header
            _buildHeader(),
            // Phần Thân
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategories(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Best Seller", () {}),
                        const SizedBox(height: 16),
                        _buildBestSellerList(),
                        const SizedBox(height: 24),
                        _buildPromoBanner(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Recommend", () {}),
                        const SizedBox(height: 16),
                        _buildRecommendGrid(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS HELPER MỚI ---

  // --- SỬA LẠI HÀM NÀY ---
  Widget _buildHeader() {
    // Lấy tên user, chỉ lấy tên đầu tiên, có kiểm tra null an toàn
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userName = user?.name.split(' ').first ?? 'User';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.menu, color: Colors.white, size: 30), onPressed: widget.toggleMenu),
              Row(
                children: [
                  AppBarCartIcon(iconColor: Colors.white),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_none_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Text("Good Morning, $userName", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Rise And Shine! It's Breakfast Time", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 20),

          // --- THÊM LOGIC TÌM KIẾM VÀO ĐÂY ---
          GestureDetector(
            onTap: () {
              // Điều hướng đến màn hình SearchScreen khi người dùng nhấn vào
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: AbsorbPointer( // AbsorbPointer ngăn không cho TextField nhận focus và mở bàn phím
              child: TextField(
                // enabled: false, // Một cách khác để vô hiệu hóa
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF9A825) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: Icon(category['icon'], color: isSelected ? Colors.white : Colors.deepOrange, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(category['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onViewAll, child: const Text("View All >", style: TextStyle(color: Colors.deepOrange))),
        ],
      ),
    );
  }

  Widget _buildBestSellerList() {
    return SizedBox(
      height: 200,
      child: FutureBuilder<List<MenuItemModel>>(
        future: _menuItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.take(4).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildBestSellerCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildBestSellerCard(MenuItemModel item) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return GestureDetector(
      onTap: () => _navigateToDetails(item),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(item.imageUrl ?? '', width: 140, height: 200, fit: BoxFit.cover)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
            ),
            Positioned(
              bottom: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  currencyFormatter.format(item.price), // SỬ DỤNG BIẾN ĐÃ KHAI BÁO
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    final List<String> imgList = [
      'assets/promo1.jpg',
      'assets/promo2.jpg',
      'assets/promo3.jpg',
    ];

    return CarouselSlider.builder(
      itemCount: imgList.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: AssetImage(imgList[index]),
                fit: BoxFit.cover
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 150.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.85,
      ),
    );
  }

  Widget _buildRecommendGrid() {
    return FutureBuilder<List<MenuItemModel>>(
      future: _menuItemsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final items = snapshot.data!.skip(4).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildRecommendCard(items[index]),
        );
      },
    );
  }

  Widget _buildRecommendCard(MenuItemModel item) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return GestureDetector(
      onTap: () => _navigateToDetails(item),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(item.imageUrl ?? '', width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Text("5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(currencyFormatter.format(item.price), style: const TextStyle(color: Colors.deepOrange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}