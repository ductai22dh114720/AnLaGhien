import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // <<<--- IMPORT
import 'package:intl/intl.dart';

// Import các model, provider và service cần thiết
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/provider/user_provider.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';


// Import các màn hình
import 'package:flutter_dapm/features/authentication/screen/details_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/profile_screen.dart';
import 'package:flutter_dapm/shared/widgets/app_bar_cart_icon.dart';

//Import Widget
import 'package:flutter_dapm/shared/widgets/product_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
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
    const Color backgroundColor = Color(0xFFF2F2F2); // Màu nền xám nhạt

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: const [AppBarCartIcon(), SizedBox(width: 16)],
      ),
      drawer: _buildDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            // Phần header chứa tiêu đề và thanh tìm kiếm
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Thanh TabBar được "ghim" lại khi cuộn
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _categories.map((String name) => Tab(text: name)).toList(),
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
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có sản phẩm nào."));
            }
            final allItems = snapshot.data!;

            // UI cho danh sách sản phẩm
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20), // Padding trên để ảnh nổi lên
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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