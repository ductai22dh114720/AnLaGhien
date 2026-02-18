import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/login_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dapm/features/dashboard/screen/user_screen.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:flutter_dapm/shared/services/user_service.dart';
import 'package:flutter_dapm/shared/utils/custom_page_route.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int)? navigateToOrderTab;
  const ProfileScreen({super.key, this.navigateToOrderTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- BIẾN TRẠNG THÁI ---
  late Future<UserModel?> _userFuture;
  late Future<List<OrderModel>> _ordersFuture;

  // --- VÒNG ĐỜI WIDGET ---
  @override
  void initState() {
    super.initState();
    // SỬA LẠI: Khởi tạo các future trực tiếp, không gọi setState()
    _userFuture = UserService().getUserProfile();
    _ordersFuture = OrderService().getOrderHistory();
  }
  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepOrange.withAlpha(25),
          backgroundImage: NetworkImage(user.avatarUrl ?? "https://i.pravatar.cc/150?img=12"),
        ),
        const SizedBox(height: 12),
        Text(
            user.name,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
            )
        ),
        const SizedBox(height: 4),
        Text(
            user.email,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600]
            )
        ),
      ],
    );
  }

  // Hàm này dùng để tải lại dữ liệu khi cần (ví dụ: nhấn nút "Thử lại")
  void _reloadData() {
    setState(() {
      _userFuture = UserService().getUserProfile();
      _ordersFuture = OrderService().getOrderHistory();
    });
  }

  // --- HÀM LOGIC ---
  Future<void> _performLogout() async {
    final box = GetStorage();
    await box.remove('jwt_token');
    await GoogleSignIn().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Xác nhận Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: Colors.grey[700])),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout();
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- PHẦN BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("TÀI KHOẢN CỦA TÔI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError || !userSnapshot.hasData) {
            return _buildErrorState(); // Hàm này giờ sẽ gọi _reloadData
          }
          final user = userSnapshot.data!;

          // Sau khi có user, build tiếp Future cho đơn hàng
          return FutureBuilder<List<OrderModel>>(
            future: _ordersFuture,
            builder: (context, orderSnapshot) {
              // Vẫn có thể hiển thị profile dù đơn hàng đang tải hoặc lỗi
              List<OrderModel> orders = [];
              if (orderSnapshot.connectionState == ConnectionState.done && orderSnapshot.hasData) {
                orders = orderSnapshot.data!;
              }
              // Build giao diện chính với cả user và orders
              return _buildProfileView(user, orders);
            },
          );
        },
      ),
    );
  }


  // --- CÁC WIDGET HELPER ---
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Không thể tải dữ liệu người dùng.'),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: _reloadData, // Sửa lại để gọi hàm tải lại tất cả
              child: const Text('Thử lại')
          )
        ],
      ),
    );
  }

  // SỬA LẠI: hàm then() của Navigator
  Widget _buildProfileView(UserModel user, List<OrderModel> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 24),
          _buildMyPurchasesSection(orders),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            title: "Tài khoản",
            children: [
              _buildProfileOption(
                icon: Icons.person_outline,
                title: "Thông tin cá nhân",
                onTap: () {
                  Navigator.of(context).push(
                    CustomPageRoute(child: UserScreen(user: user), type: PageTransitionType.slide),
                  ).then((result) {
                    if (result == true) _reloadData(); // Tải lại cả user và đơn hàng
                  });
                },
              ),
              _buildProfileOption(icon: Icons.location_on_outlined, title: "Địa chỉ của tôi", onTap: () {}),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsGroup(
            title: "Hỗ trợ & Cài đặt",
            children: [
              _buildProfileOption(icon: Icons.notifications_none_outlined, title: "Thông báo", onTap: () {}),
              _buildProfileOption(icon: Icons.help_outline, title: "Trung tâm hỗ trợ", onTap: () {}),
              _buildProfileOption(icon: Icons.info_outline, title: "Về chúng tôi", onTap: () {}),
            ],
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // WIDGET MỚI: Xây dựng khu vực "Đơn mua"
  Widget _buildMyPurchasesSection(List<OrderModel> orders) {
    // Đếm số lượng đơn hàng cho mỗi trạng thái
    final pendingCount = orders.where((o) => o.status == 'pending').length;
    final confirmedCount = orders.where((o) => o.status == 'confirmed').length;
    final deliveryCount = orders.where((o) => o.status == 'out_for_delivery').length;
    final deliveredCount = orders.where((o) => o.status == 'delivered').length;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: [
          ListTile(
            title: const Text("Đơn mua", style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("Xem lịch sử mua hàng >", style: TextStyle(color: Colors.grey[600])),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OrderScreen()));
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPurchaseStatusItem(icon: Icons.wallet_giftcard_outlined, label: "Chờ xác nhận", count: pendingCount, onTap: () => _navigateToOrders(0)),
                _buildPurchaseStatusItem(icon: Icons.inventory_2_outlined, label: "Chờ lấy hàng", count: confirmedCount, onTap: () => _navigateToOrders(1)),
                _buildPurchaseStatusItem(icon: Icons.local_shipping_outlined, label: "Đang giao", count: deliveryCount, onTap: () => _navigateToOrders(2)),
                _buildPurchaseStatusItem(icon: Icons.star_border_outlined, label: "Đã giao", count: deliveredCount, onTap: () => _navigateToOrders(3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper để tạo một mục trạng thái đơn hàng
  Widget _buildPurchaseStatusItem({required IconData icon, required String label, required int count, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 75, // Giới hạn chiều rộng
        child: Column(
          children: [
            Badge(
              label: Text('$count'),
              isLabelVisible: count > 0,
              child: Icon(icon, size: 30, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Helper để điều hướng đến OrderScreen với tab được chọn
  void _navigateToOrders(int tabIndex) {
    // Kiểm tra xem callback có được truyền vào không
    if (widget.navigateToOrderTab != null) {
      // Nếu có, gọi callback để DashboardScreen xử lý việc chuyển tab
      widget.navigateToOrderTab!(tabIndex);
    } else {
      // Nếu không (trường hợp dự phòng), sử dụng cách cũ
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OrderScreen(initialTabIndex: tabIndex),
      ));
    }
  }
  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Card(
          elevation: 2, // Giảm elevation cho tinh tế hơn
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  // SỬA LẠI HÀM NÀY ĐỂ GỌI DIALOG
  Widget _buildLogoutButton() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        onTap: _showLogoutConfirmationDialog, // <-- Thay đổi ở đây
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ), // Dùng màu đỏ cho icon
        title: const Text(
          "Đăng xuất",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ), // Dùng màu đỏ cho text
        ),
      ),
    );
  }
}
