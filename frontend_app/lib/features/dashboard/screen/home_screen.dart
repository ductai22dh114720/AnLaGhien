import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/search_screen.dart';
// Import các model, provider và service cần thiết
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/shared/widgets/app_bar_cart_icon.dart';
//Import Widget
import 'package:flutter_dapm/shared/widgets/product_card_widget.dart';
import 'package:google_fonts/google_fonts.dart'; // <<<--- IMPORT

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleMenu;

  const HomeScreen({super.key, required this.toggleMenu});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Sử dụng TickerProviderStateMixin để quản lý TabController
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<MenuItemModel>> _menuItemsFuture;
  final ProductService _productService = ProductService();

  // Danh sách các danh mục
  final List<String> _categories = ['Foods', 'Drinks', 'Snacks', 'Sauce'];

  // HÀM MỚI: Xử lý khi người dùng gửi yêu cầu tìm kiếm
  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          // Điều hướng đến SearchScreen và truyền query
          builder: (context) => SearchScreen(searchQuery: query.trim()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _menuItemsFuture = _productService.getAllMenuItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFA4A0C); // Màu cam chủ đạo

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: widget.toggleMenu, // Gọi hàm được truyền vào
        ),
        actions: const [AppBarCartIcon(), SizedBox(width: 16)],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            // Phần header chứa tiêu đề và thanh tìm kiếm
            SliverToBoxAdapter(child: _buildHeader()),
            // Thanh TabBar được "ghim" lại khi cuộn
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs:
                      _categories
                          .map((String name) => Tab(text: name))
                          .toList(),
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3.0,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        // Phần thân chứa danh sách sản phẩm
        body: FutureBuilder<List<MenuItemModel>>(
          future: _menuItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có sản phẩm nào."));
            }
            final allItems = snapshot.data!;

            // UI cho danh sách sản phẩm
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              // Padding trên để ảnh nổi lên
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cột
                mainAxisSpacing: 30,
                crossAxisSpacing: 20,
                childAspectRatio: 0.65, // Tỉ lệ chiều rộng/chiều cao của card
              ),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                return ProductCardWidget(item: allItems[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS HELPER MỚI ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delicious\nfood for you",
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            onSubmitted: (value) {
              _handleSearch(value); // Gọi hàm xử lý khi nhấn enter/search
            },
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              filled: true,
              fillColor: const Color(0xFFEFEEEE),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Class helper để ghim TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF2F2F2), // Màu nền giống Scaffold
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
