import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/details_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/profile_screen.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/shared/theme/app_styles.dart';
import 'package:flutter_dapm/shared/widgets/app_bar_cart_icon.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/user_provider.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool burger = true,
      pizza = false,
      burrito = false,
      drink = false;
  late Future<List<MenuItemModel>> _menuItemsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _productService.getAllMenuItems();
  }

  void _navigateToDetails(MenuItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DetailsScreen(
              menuItemId: item.id,
              imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
              title: item.name,
              description: "Đây là mô tả mẫu cho món ăn.",
              // TODO: Thêm trường description vào model
              price: item.price,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider
        .of<UserProvider>(context, listen: false)
        .user
        ?.name ?? 'Bạn';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền nhẹ nhàng hơn
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Nền trong suốt
        elevation: 0,
        foregroundColor: Colors.black,
        // Icon màu đen
        title: Text('Xin chào, $userName!', style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
        // Căn lề trái
        actions: const [AppBarCartIcon(), SizedBox(width: 10)],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(), // <<<--- THÊM THANH TÌM KIẾM
              const SizedBox(height: 24.0),
              Text('Danh mục', style: AppStyles.headlineTextFeildStyle()),
              const SizedBox(height: 16.0),
              _buildCategorySelector(),
              const SizedBox(height: 24.0),
              _buildProductSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm món ăn...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

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
    final currencyFormatter = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'đ');

    return Drawer(
      child: Container(
        color: Colors.deepOrange[100],
        child: Consumer<UserProvider>( // <<<--- BỌC TOÀN BỘ BẰNG CONSUMER
          builder: (context, userProvider, child) {
            // Kiểm tra xem người dùng có phải admin không
            final bool isAdmin = userProvider.isAdmin;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.deepOrange),
                  child: Center(child: Text('L O G O',
                      style: TextStyle(color: Colors.white, fontSize: 24))),
                ),

                // --- MỤC CHUNG CHO CẢ USER VÀ ADMIN ---
                if (!isAdmin) // Chỉ hiện ví cho customer
                  Consumer<WalletProvider>(
                    builder: (context, walletProvider, child) {
                      final balance = walletProvider.balance ?? 0.0;
                      return ListTile(
                        leading: const Icon(
                            Icons.account_balance_wallet_outlined, color: Colors
                            .deepOrange),
                        title: const Text('Số dư ví', style: TextStyle(
                            fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          currencyFormatter.format(balance),
                          style: const TextStyle(fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: walletProvider.isLoading
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          onPressed: walletProvider.isLoading ? null : () {
                            Provider
                                .of<WalletProvider>(context, listen: false)
                                .fetchWallet();
                          },
                        ),
                      );
                    },
                  ),
                if (!isAdmin) const Divider(),

                // --- MỤC DÀNH RIÊNG CHO ADMIN ---
                if (isAdmin)
                  ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text("QUẢN LÝ", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_alt_outlined),
                      title: const Text('Quản lý Người dùng'),
                      onTap: () {
                        // TODO: Navigator.push đến AdminUserManagementScreen
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.restaurant_menu_outlined),
                      title: const Text('Quản lý Món ăn'),
                      onTap: () {
                        // TODO: Navigator.push đến AdminMenuManagementScreen
                      },
                    ),
                    const Divider(),
                  ],

                // --- MỤC DÀNH RIÊNG CHO CUSTOMER ---
                if (!isAdmin)
                  ...[
                    ListTile(leading: const Icon(Icons.home),
                        title: const Text('Trang Chủ'),
                        onTap: () => Navigator.pop(context)),
                    ListTile(leading: const Icon(Icons.person),
                        title: const Text('Trang Cá Nhân'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (
                                  context) => const ProfileScreen()));
                        }),
                    ListTile(leading: const Icon(Icons.shopping_cart),
                        title: const Text('Đơn hàng'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (
                                  context) => const OrderScreen()));
                        }),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryIcon(() =>
            setState(() {
              burger = true;
              pizza = false;
              drink = false;
              burrito = false;
            }), 'assets/burger.png', burger),
        _buildCategoryIcon(() =>
            setState(() {
              burger = false;
              pizza = false;
              drink = false;
              burrito = true;
            }), 'assets/burrito.png', burrito),
        _buildCategoryIcon(() =>
            setState(() {
              burger = false;
              pizza = true;
              drink = false;
              burrito = false;
            }), 'assets/pizza.png', pizza),
        _buildCategoryIcon(() =>
            setState(() {
              burger = false;
              pizza = false;
              drink = true;
              burrito = false;
            }), 'assets/drink.png', drink),
      ],
    );
  }

  Widget _buildCategoryIcon(VoidCallback onTap, String imagePath,
      bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3.0, borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? Colors.deepOrange : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
          child: Image.asset(imagePath, height: 50,
              width: 50,
              fit: BoxFit.contain,
              color: isSelected ? Colors.white : Colors.black),
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
      options: CarouselOptions(height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.55),
    );
  }

  Widget _buildSuggestedList(List<MenuItemModel> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
    final currencyFormatter = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'đ');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần hình ảnh
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15.0)),
              child: Image.network(
                item.imageUrl ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) =>
                progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stack) =>
                const Icon(Icons.broken_image, color: Colors.grey, size: 50),
              ),
            ),
          ),
          // Phần thông tin
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(currencyFormatter.format(item.price),
                    style: const TextStyle(color: Colors.deepOrange,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildVerticalProductCard(MenuItemModel item) {
    final currencyFormatter = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'đ');
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                item.imageUrl ?? 'https://via.placeholder.com/150',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stack) =>
                const Icon(Icons.fastfood, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: SizedBox(
                height: 100, // Đảm bảo chiều cao đồng bộ
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                    Text("Mô tả ngắn...", style: TextStyle(
                        color: Colors.grey[600], fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormatter.format(item.price),
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange)),
                        // Nút thêm nhanh
                        InkWell(
                          onTap: () {
                            Provider
                                .of<CartProvider>(context, listen: false)
                                .addItemToCart(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã thêm vào giỏ hàng!'),
                                  duration: Duration(seconds: 1)),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.deepOrange,
                            child: Icon(
                                Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}