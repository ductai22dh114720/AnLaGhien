import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện này để format ngày tháng

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Key để quản lý và validate Form
  final _formKey = GlobalKey<FormState>();

  // Controllers để lấy dữ liệu từ các trường text
  final _nameController = TextEditingController();
  final _dobController = TextEditingController(); // Date of Birth
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị hủy
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút Đăng ký
  void _handleSignup() {
    // Validate toàn bộ form, nếu tất cả hợp lệ thì isVaid = true
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return; // Nếu không hợp lệ, dừng lại
    }
    // Nếu hợp lệ, tiếp tục xử lý
    debugPrint("Form hợp lệ!");
    debugPrint("Tên: ${_nameController.text}");
    debugPrint("Ngày sinh: ${_dobController.text}");
    debugPrint("Giới tính: $_selectedGender");
    // ... Lấy các thông tin khác và gọi API đăng ký tại đây
  }

  // Hàm hiển thị lịch chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange, // Màu header
              onPrimary: Colors.white, // Màu chữ trên header
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format ngày thành dd/MM/yyyy và gán vào controller
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Để tránh các thành phần hệ thống (tai thỏ, status bar)
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER ---
                  Text(
                    'Tạo tài khoản mới',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bắt đầu hành trình ẩm thực của bạn ngay!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // --- NÚT ĐĂNG KÝ BẰNG GOOGLE ---
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Gọi API đăng ký bằng Gmail
                      print("Đăng ký bằng Google");
                    },
                    icon: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                    ), // Cần có ảnh logo Google
                    label: Text(
                      'Đăng ký với Google',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- DẤU NGĂN CÁCH ---
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'HOẶC',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- CÁC TRƯỜNG NHẬP LIỆU ---
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Họ và tên',
                    icon: Icons.person_outline,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 16),

                  // Ngày tháng năm sinh (sử dụng onTap để mở lịch)
                  TextFormField(
                    controller: _dobController,
                    readOnly: true, // Không cho người dùng gõ tay
                    decoration: _inputDecoration(
                      'Ngày tháng năm sinh',
                      Icons.calendar_today_outlined,
                    ),
                    onTap: () => _selectDate(context),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng chọn ngày sinh' : null,
                  ),
                  const SizedBox(height: 16),

                  // Giới tính (sử dụng Dropdown)
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: _inputDecoration(
                      'Giới tính',
                      Icons.wc_outlined,
                    ),
                    items:
                        ['Nam', 'Nữ', 'Khác'].map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Vui lòng chọn giới tính' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _addressController,
                    labelText: 'Địa chỉ',
                    icon: Icons.location_on_outlined,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Vui lòng nhập email';
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                        return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _phoneController,
                    labelText: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
                      if (value.length < 10)
                        return 'Số điện thoại không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: _inputDecoration(
                      'Mật khẩu',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => _isPasswordObscured = !_isPasswordObscured,
                            ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (value.length < 6)
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nhập lại mật khẩu
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscured,
                    decoration: _inputDecoration(
                      'Nhập lại mật khẩu',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  _isConfirmPasswordObscured =
                                      !_isConfirmPasswordObscured,
                            ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                      if (value != _passwordController.text)
                        return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- NÚT ĐĂNG KÝ ---
                  ElevatedButton(
                    onPressed: _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- LINK ĐĂNG NHẬP ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Đã có tài khoản?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // Quay lại trang trước đó (Login)
                        },
                        child: Text(
                          "Đăng nhập ngay",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm helper để tạo TextFormField cho gọn
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(labelText, icon),
      validator: validator,
    );
  }

  // Hàm helper để tạo InputDecoration cho gọn
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.deepOrange),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
      ),
    );
  }
}
