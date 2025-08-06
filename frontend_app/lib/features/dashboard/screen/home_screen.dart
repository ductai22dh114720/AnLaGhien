import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter_dapm/features/authentication/screen/details_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/profile_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/shared/theme/app_styles.dart';
import 'package:flutter_dapm/shared/widgets/app_bar_cart_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- BIẾN TRẠNG THÁI ---
  bool burger = true, pizza = false, burrito = false, drink = false; // Mặc định chọn burger
  late Future<List<MenuItemModel>> _menuItemsFuture;
  final ProductService _productService = ProductService();

  // --- VÒNG ĐỜI WIDGET ---
  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _productService.getAllMenuItems();
  }

  // --- HÀM LOGIC ---
  void _navigateToDetails(MenuItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          menuItemId: item.id,
          imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
          title: item.name,
          description: "Đây là mô tả mẫu cho món ăn.", // TODO: Thêm trường description vào model
          price: item.price,
        ),
      ),
    );
  }

  // --- PHẦN BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('TRANG CHỦ'),
        centerTitle: true,
        actions: const [AppBarCartIcon(), SizedBox(width: 10)],
      ),
      drawer: _buildDrawer(), // Gọi hàm helper
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh Mục', style: AppStyles.headlineTextFeildStyle()),
              const SizedBox(height: 20.0),
              _buildCategorySelector(), // Gọi hàm helper
              const SizedBox(height: 30.0),
              _buildProductSections(), // Tách ra widget riêng cho dễ đọc
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HELPER (ĐÃ ĐƯA TRỞ LẠI VÀO TRONG CLASS) ---

  Widget _buildProductSections() {
    return FutureBuilder<List<MenuItemModel>>(
      future: _menuItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có sản phẩm nào."));
        }

        final allItems = snapshot.data!;
        final popularItems = allItems.take(4).toList();
        final suggestedItems = allItems.skip(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phổ biến', style: AppStyles.headlineTextFeildStyle()),
            const SizedBox(height: 10.0),
            _buildPopularCarousel(popularItems),
            const SizedBox(height: 30.0),
            Text('Gợi ý cho bạn', style: AppStyles.headlineTextFeildStyle()),
            const SizedBox(height: 10.0),
            _buildSuggestedList(suggestedItems),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.deepOrange[100], // Màu nền nhẹ nhàng hơn
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrange),
              child: const Center(child: Text('L O G O', style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Trang Chủ'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.person), title: const Text('Trang Cá Nhân'), onTap: () { Navigator.pop(context); Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
            ListTile(leading: const Icon(Icons.shopping_cart), title: const Text('Đơn hàng'), onTap: () { Navigator.pop(context); Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderScreen())); }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryIcon(() => setState(() { burger = true; pizza = false; drink = false; burrito = false; }), 'assets/burger.png', burger),
        _buildCategoryIcon(() => setState(() { burger = false; pizza = false; drink = false; burrito = true; }), 'assets/burrito.png', burrito),
        _buildCategoryIcon(() => setState(() { burger = false; pizza = true; drink = false; burrito = false; }), 'assets/pizza.png', pizza),
        _buildCategoryIcon(() => setState(() { burger = false; pizza = false; drink = true; burrito = false; }), 'assets/drink.png', drink),
      ],
    );
  }

  Widget _buildCategoryIcon(VoidCallback onTap, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3.0, borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(color: isSelected ? Colors.deepOrange : Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
          child: Image.asset(imagePath, height: 50, width: 50, fit: BoxFit.contain, color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildPopularCarousel(List<MenuItemModel> items) {
    return CarouselSlider.builder(
      itemCount: items.length,
      itemBuilder: (context, index, realIndex) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _navigateToDetails(item),
          child: _buildHorizontalProductCard(item),
        );
      },
      options: CarouselOptions(height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.55),
    );
  }

  Widget _buildSuggestedList(List<MenuItemModel> items) {
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _navigateToDetails(item),
          child: _buildVerticalProductCard(item),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 15.0),
    );
  }

  Widget _buildHorizontalProductCard(MenuItemModel item) {
    return Container(
      child: Material(
        color: Colors.white, elevation: 3.0, borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(15.0), child: Image.network(item.imageUrl ?? 'https://via.placeholder.com/150', fit: BoxFit.cover, width: double.infinity))),
              const SizedBox(height: 10.0),
              Text(item.name, style: AppStyles.boldTextFeildStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5.0),
              Text('${item.price.toStringAsFixed(0)}đ', style: AppStyles.boldTextFeildStyle()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalProductCard(MenuItemModel item) {
    return Material(
      color: Colors.white, elevation: 3.0, borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(item.imageUrl ?? 'https://via.placeholder.com/150', height: 120, width: 120, fit: BoxFit.cover),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppStyles.boldTextFeildStyle()),
                  const SizedBox(height: 5.0),
                  Text("Mô tả ngắn gọn...", style: AppStyles.lightTextFeildStyle()),
                  const SizedBox(height: 10.0),
                  Text('${item.price.toStringAsFixed(0)}đ', style: AppStyles.boldTextFeildStyle()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}