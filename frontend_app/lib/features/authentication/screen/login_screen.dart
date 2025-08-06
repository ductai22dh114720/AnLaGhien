import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/features/authentication/screen/signup_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/dashboard_screen.dart';
import 'package:flutter_dapm/shared/utils/custom_page_route.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final _box = GetStorage();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final dio = Dio();
      const apiUrl = '${ApiConfig.baseUrl}/auth/google';
      final response = await dio.post(apiUrl, data: {'idToken': googleAuth.idToken});
      if (response.statusCode == 200 && mounted) {
        await _loginSuccess(response);
      }
    } catch (e) {
      debugPrint("Lỗi đăng nhập Google: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập Google thất bại.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      const apiUrl = '${ApiConfig.baseUrl}/auth/login';
      final response = await dio.post(apiUrl, data: {
        'email': _emailController.text, 'password': _passwordController.text,
      });
      if (response.statusCode == 200 && mounted) {
        await _loginSuccess(response);
      }
    } on DioException catch (e) {
      String errorMessage = "Đăng nhập thất bại. Vui lòng thử lại.";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginSuccess(Response response) async {
    final token = response.data['token'];
    final userName = response.data['user']['name'];
    await _storage.write(key: 'jwt_token', value: token);
    await _box.write('user_name', userName);
    if (mounted) {
      // Tải giỏ hàng trước khi vào trang chủ
      await Provider.of<CartProvider>(context, listen: false).fetchCart();
      Navigator.of(context).pushReplacement(
        CustomPageRoute(child: const DashboardScreen(), type: PageTransitionType.scale),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      CustomPageRoute(child: const SignupScreen(), type: PageTransitionType.slide),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- BẮT ĐẦU CẤU TRÚC ĐÚNG ---
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // LỚP 1: GIAO DIỆN CHÍNH
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- HEADER & LOGO ---
                      Image.asset('assets/logo_splash.png', height: 100),
                      const SizedBox(height: 24),
                      const Text('Chào mừng trở lại!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Đăng nhập để tiếp tục khám phá', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 40),

                      // --- FORM NHẬP LIỆU ---
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email', Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscured,
                        decoration: _inputDecoration('Mật khẩu', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[600]),
                            onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {}, child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w500))),
                      ),
                      const SizedBox(height: 24),

                      // --- NÚT ĐĂNG NHẬP ---
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin, // Vô hiệu hóa nút khi đang loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          shadowColor: Colors.deepOrange.withOpacity(0.4),
                        ),
                        child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 32),

                      // --- CÁC LỰA CHỌN KHÁC ---
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('HOẶC ĐĂNG NHẬP VỚI', style: TextStyle(color: Colors.grey))),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn, // Vô hiệu hóa nút khi đang loading
                        icon: Image.asset('assets/google_logo.png', height: 24),
                        label: const Text('Google', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 40),

                      // --- FOOTER: LINK ĐĂNG KÝ ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Chưa có tài khoản?"),
                          TextButton(onPressed: _navigateToSignup, child: const Text("Đăng ký ngay", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // LỚP 2: LỚP PHỦ LOADING
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
    // --- KẾT THÚC CẤU TRÚC ĐÚNG ---
  }

  // Hàm helper để tạo InputDecoration cho gọn
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey[600]),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
