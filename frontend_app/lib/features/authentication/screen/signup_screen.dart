import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dapm/shared/models/address_suggestion_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_dapm/features/dashboard/screen/dashboard_screen.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/services/address_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // --- 1. KHAI BÁO BIẾN --- //
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();
  final _storage = const FlutterSecureStorage();

  // Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Trạng thái Form
  String? _selectedGender;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  List<AddressSuggestion> _placeSuggestions = [];
  Timer? _debounce;
  bool _isSearchingAddress = false;

  // ------------------- 2. VÒNG ĐỜI WIDGET ------------------- //
  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ------------------- 3. CÁC HÀM XỬ LÝ LOGIC ------------------- //

  void _onAddressChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      if (input.isNotEmpty) {
        if (mounted) setState(() => _isSearchingAddress = true);
        // SỬA LẠI Ở ĐÂY
        _placeSuggestions = await _addressService.getAutocompleteSuggestions(input);
        if (mounted) setState(() => _isSearchingAddress = false);
      } else {
        if (mounted) setState(() => _placeSuggestions = []);
      }
    });
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng kiểm tra lại các thông tin.'), backgroundColor: Colors.orange));
      return;
    }

    // SỬA LẠI: Lấy địa chỉ trực tiếp từ _addressController
    final Map<String, dynamic> userData = {
      "name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "dob": _dobController.text,
      "gender": _selectedGender,
    };

    try {
      final dio = Dio();
      const String apiUrl = '${ApiConfig.baseUrl}/auth/signup';
      final response = await dio.post(apiUrl, data: userData);
      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      _showErrorSnackBar(e);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) return;

      final dio = Dio();
      const String apiUrl = '${ApiConfig.baseUrl}/auth/google';
      final response = await dio.post(apiUrl, data: {'idToken': idToken});

      if (response.statusCode == 200 && mounted) {
        _loginSuccess(response.data['token']);
      }
    } catch (error) {
      debugPrint("Lỗi đăng ký Google: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký bằng Google thất bại.'), backgroundColor: Colors.red));
      }
    }
  }

  // Tách logic xử lý sau khi đăng nhập thành công
  Future<void> _loginSuccess(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  // Tách logic hiển thị lỗi
  void _showErrorSnackBar(DioException e) {
    String errorMessage = "Đã có lỗi xảy ra. Vui lòng thử lại.";
    if (e.response != null) {
      errorMessage = e.response?.data['message'] ?? errorMessage;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ------------------- 4. PHẦN BUILD UI ------------------- //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER ---
                  const Text(
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
                    onPressed: _handleGoogleSignUp,
                    icon: Image.asset('assets/google_logo.png', height: 24),
                    label: const Text(
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'HOẶC',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- CÁC TRƯỜNG NHẬP LIỆU CƠ BẢN ---
                  // --- CÁC TRƯỜNG NHẬP LIỆU CƠ BẢN ---
                  _buildTextFormField(controller: _nameController, labelText: 'Họ và tên', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _dobController, readOnly: true, decoration: _inputDecoration('Ngày tháng năm sinh', Icons.calendar_today_outlined), onTap: () => _selectDate(context), validator: (v) => v!.isEmpty ? 'Vui lòng chọn ngày sinh' : null),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>( value: _selectedGender, decoration: _inputDecoration('Giới tính', Icons.wc_outlined), items: ['Nam', 'Nữ', 'Khác'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (v) => setState(() => _selectedGender = v), validator: (v) => v == null ? 'Vui lòng chọn giới tính' : null),
                  const SizedBox(height: 16),

                  _buildTextFormField(controller: _addressController, labelText: 'Nhập địa chỉ', icon: Icons.location_on_outlined, onChanged: _onAddressChanged, validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null),

                  // SỬA LẠI PHẦN HIỂN THỊ GỢI Ý
                  if (_isSearchingAddress)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: CircularProgressIndicator()))
                  else if (_placeSuggestions.isNotEmpty)
                    _buildSuggestionsList(), // <-- Sửa tên hàm

                  const SizedBox(height: 16),

                  // --- CÁC TRƯỜNG CÒN LẠI ---
                  // ... (Email, Phone, Password, Confirm Password)
                  _buildTextFormField(controller: _emailController, labelText: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'))], validator: (v) { if (v!.isEmpty) return 'Vui lòng nhập email'; if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Email không hợp lệ'; return null; }),
                  const SizedBox(height: 16),
                  _buildTextFormField(controller: _phoneController, labelText: 'Số điện thoại', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) { if (v!.isEmpty) return 'Vui lòng nhập số điện thoại'; if (v.length < 10) return 'Số điện thoại không hợp lệ'; return null; }),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passwordController, obscureText: _isPasswordObscured, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[\u0300-\u036f]'))], decoration: _inputDecoration('Mật khẩu', Icons.lock_outline).copyWith(suffixIcon: IconButton(icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured))), validator: (v) { if (v!.isEmpty) return 'Vui lòng nhập mật khẩu'; if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự'; return null; }),
                  const SizedBox(height: 16),
                  TextFormField(controller: _confirmPasswordController, obscureText: _isConfirmPasswordObscured, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[\u0300-\u036f]'))], decoration: _inputDecoration('Nhập lại mật khẩu', Icons.lock_outline).copyWith(suffixIcon: IconButton(icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured))), validator: (v) { if (v!.isEmpty) return 'Vui lòng nhập lại mật khẩu'; if (v != _passwordController.text) return 'Mật khẩu không khớp'; return null; }),
                  const SizedBox(height: 32),
                  // --- NÚT ĐĂNG KÝ VÀ LINK ĐĂNG NHẬP ---
                  ElevatedButton(
                    onPressed: _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
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

  // ------------------- 5. CÁC HÀM HELPER CHO UI ------------------- //


  Widget _buildSuggestionsList() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4)],
      ),
      child: ListView.builder(
        itemCount: _placeSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _placeSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_pin, color: Colors.grey),
            title: Text(suggestion.displayName), // <-- Sửa ở đây
            onTap: () {
              setState(() {
                _addressController.text = suggestion.displayName; // <-- Sửa ở đây
                _placeSuggestions = [];
              });
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(labelText, icon),
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
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
        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
      ),
    );
  }
}
