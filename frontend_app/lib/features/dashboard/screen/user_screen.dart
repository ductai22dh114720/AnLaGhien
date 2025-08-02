import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  // Thay vì một Map, chúng ta định nghĩa rõ các tham số cần thiết
  // Điều này an toàn và dễ đọc hơn
  final String userName;
  final String userEmail;
  final String avatarUrl;
  // Bạn có thể thêm các trường khác như phone, address nếu ProfileScreen có

  const UserScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // Controllers để quản lý dữ liệu trên các TextField
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false; // Trạng thái bật/tắt chỉnh sửa

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với dữ liệu được truyền vào từ widget
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    // Giả sử phone và address chưa có, bạn có thể để trống hoặc truyền vào
    _phoneController = TextEditingController(text: "0987654321"); // Dữ liệu mẫu
    _addressController = TextEditingController(text: "123 Đường ABC, Phường X, Quận Y, TP. Z"); // Dữ liệu mẫu
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Nút Chỉnh sửa / Lưu
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // TODO: Gọi API để lưu thông tin mới
                  debugPrint("Lưu thông tin: ${_nameController.text}");
                }
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.avatarUrl), // Sử dụng avatarUrl từ widget
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Mở thư viện ảnh để chọn ảnh mới
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),

              // Form thông tin
              _buildUserInfoField(
                label: "Họ và tên",
                icon: Icons.person,
                controller: _nameController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 20),
              _buildUserInfoField(
                label: "Email",
                icon: Icons.email,
                controller: _emailController,
                isEditing: false, // Email thường không được phép chỉnh sửa
              ),
              const SizedBox(height: 20),
              _buildUserInfoField(
                label: "Số điện thoại",
                icon: Icons.phone,
                controller: _phoneController,
                isEditing: _isEditing,
              ),
              const SizedBox(height: 20),
              _buildUserInfoField(
                label: "Địa chỉ",
                icon: Icons.location_on,
                controller: _addressController,
                isEditing: _isEditing,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper để tạo một trường thông tin
  Widget _buildUserInfoField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isEditing = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      maxLines: maxLines,
      style: TextStyle(color: isEditing ? Colors.black : Colors.grey[700]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: isEditing ? Colors.white : Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isEditing ? Colors.grey.shade300 : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }
}