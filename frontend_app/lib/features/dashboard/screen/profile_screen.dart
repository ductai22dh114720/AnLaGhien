import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/login_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dữ liệu người dùng mẫu - sau này bạn sẽ lấy từ API hoặc SharedPreferences
  final String userName = "Nguyễn Thái Thành Đạt";
  final String userEmail = "dat.nguyen@email.com";
  final String avatarUrl = "https://i.pravatar.cc/150?img=12";

  // --- HÀM MỚI ĐỂ XỬ LÝ LOGIC ĐĂNG XUẤT ---
  Future<void> _performLogout() async {
    // 1. Xóa token đã lưu
    final box = GetStorage();
    // Giả sử bạn lưu token với key là 'jwt_token' sau khi đăng nhập thành công
    await box.remove('jwt_token');

    // 2. Đăng xuất khỏi tài khoản Google (nếu cần)
    // Dòng này đảm bảo lần sau khi nhấn "Đăng nhập với Google", cửa sổ chọn tài khoản sẽ hiện lại.
    await GoogleSignIn().signOut();

    // 3. Điều hướng về trang Login và xóa hết các màn hình cũ
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        // Dùng MaterialPageRoute hoặc CustomPageRoute tùy bạn
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
      );
    }
  }

  // --- HÀM MỚI ĐỂ HIỂN THỊ DIALOG XÁC NHẬN ---
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Xác nhận Đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy', style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Dùng màu đỏ cho hành động nguy hiểm
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog trước
                _performLogout(); // Sau đó thực hiện đăng xuất
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "TÀI KHOẢN CỦA TÔI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildSettingsGroup(
                title: "Tài khoản",
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: "Thông tin cá nhân",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: "Địa chỉ của tôi",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.receipt_long_outlined,
                    title: "Lịch sử đơn hàng",
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingsGroup(
                title: "Hỗ trợ & Cài đặt",
                children: [
                  _buildProfileOption(
                    icon: Icons.notifications_none_outlined,
                    title: "Thông báo",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: "Trung tâm hỗ trợ",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    title: "Về chúng tôi",
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HELPER ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepOrange.withOpacity(0.1),
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(height: 12),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
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
