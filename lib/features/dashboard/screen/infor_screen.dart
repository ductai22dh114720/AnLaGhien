import 'package:flutter/material.dart';

class Infor extends StatefulWidget {
  const Infor({super.key});

  @override
  State<Infor> createState() => _InforState();
}

class _InforState extends State<Infor> {
  // Dữ liệu người dùng mẫu - sau này bạn sẽ lấy từ API hoặc SharedPreferences
  final String userName = "Nguyễn Thái Thành Đạt";
  final String userEmail = "dat.nguyen@email.com";
  final String avatarUrl =
      "https://i.pravatar.cc/150?img=12"; // URL ảnh đại diện mẫu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng màu nền xám nhạt để làm nổi bật các Card
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "TÀI KHOẢN CỦA TÔI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Nền trong suốt
        foregroundColor: Colors.black, // Màu chữ và icon là màu đen
        elevation: 0, // Bỏ shadow cho hiện đại
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- PHẦN THÔNG TIN NGƯỜI DÙNG ---
              _buildProfileHeader(),
              const SizedBox(height: 30),

              // --- NHÓM CHỨC NĂNG TÀI KHOẢN ---
              _buildSettingsGroup(
                title: "Tài khoản",
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: "Thông tin cá nhân",
                    onTap: () {
                      // Điều hướng đến trang sửa thông tin
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: "Địa chỉ của tôi",
                    onTap: () {
                      // Điều hướng đến trang quản lý địa chỉ
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.receipt_long_outlined,
                    title: "Lịch sử đơn hàng",
                    onTap: () {
                      // Điều hướng đến trang lịch sử đơn hàng
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- NHÓM CHỨC NĂNG HỖ TRỢ & CÀI ĐẶT ---
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

              // --- NÚT ĐĂNG XUẤT ---
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget header chứa avatar và tên người dùng
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
          style: TextStyle(
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

  // Widget để tạo một nhóm các mục cài đặt
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
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            // Dùng List.generate để tự động thêm Divider
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

  // Widget để tạo một mục lựa chọn trong danh sách
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: Colors.deepOrange, // Màu nhấn chủ đạo
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  // Widget riêng cho nút đăng xuất
  Widget _buildLogoutButton() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        onTap: () {
          // Hiển thị dialog xác nhận đăng xuất
          print("Đã nhấn nút Đăng xuất");
        },
        leading: Icon(Icons.logout, color: Colors.deepOrange),
        title: Text(
          "Đăng xuất",
          style: TextStyle(
            color:
                Colors.deepOrange, // Màu chữ đặc biệt cho hành động nguy hiểm
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
