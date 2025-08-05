// File: lib/features/dashboard/screens/user_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/services/user_service.dart';

class UserScreen extends StatefulWidget {
  final UserModel user;
  const UserScreen({super.key, required this.user});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  // Controllers cho các TextField
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // Trạng thái UI
  bool _isEditing = false;
  bool _isLoading = false;

  // Trạng thái bản đồ
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(10.7769, 106.7009); // Mặc định ở TPHCM
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu ban đầu
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);

    // TODO: Sau này, chuyển đổi widget.user.address thành tọa độ và gán vào _initialPosition

    // Thêm marker ban đầu
    _markers.add(
      Marker(
        point: _initialPosition,
        width: 80.0,
        height: 80.0,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    };

    final success = await _userService.updateUserProfile(updatedData);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
        Navigator.of(context).pop(true); // Trả về true để màn hình trước biết cần tải lại
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _goToPosition(LatLng position) {
    _mapController.move(position, 16.0);
    setState(() {
      _markers = [
        Marker(
          point: position,
          width: 80.0,
          height: 80.0,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      ];
    });
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
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
              onPressed: () {
                if (_isEditing) {
                  _handleUpdateProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- AVATAR ---
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(widget.user.avatarUrl ?? "https://i.pravatar.cc/150?img=12"),
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

                // --- FORM THÔNG TIN ---
                _buildUserInfoField(label: "Họ và tên", icon: Icons.person, controller: _nameController, isEditing: _isEditing),
                const SizedBox(height: 20),
                _buildUserInfoField(label: "Email", icon: Icons.email, controller: _emailController, isEditing: false),
                const SizedBox(height: 20),
                _buildUserInfoField(label: "Số điện thoại", icon: Icons.phone, controller: _phoneController, isEditing: _isEditing),
                const SizedBox(height: 20),
                _buildUserInfoField(label: "Địa chỉ", icon: Icons.location_on, controller: _addressController, isEditing: _isEditing, maxLines: 3),

                // --- WIDGET BẢN ĐỒ ---
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialPosition,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.flutter_dapm',
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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