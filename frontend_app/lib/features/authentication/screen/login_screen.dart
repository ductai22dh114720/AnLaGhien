import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/signup_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/dashboard_screen.dart';
import 'package:flutter_dapm/shared/utils/custom_page_route.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // SỬ DỤNG CÁCH KHỞI TẠO CŨ
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // SỬ DỤNG PHƯƠNG THỨC signIn() TRÊN INSTANCE
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng đã hủy
        debugPrint("Đăng nhập Google đã bị hủy.");
        return;
      }

      // Lấy ID Token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("Không lấy được ID Token từ Google.");
        return;
      }

      // Gửi ID Token lên backend
      final dio = Dio();
      // QUAN TRỌNG: Thay 'localhost' bằng IP của máy tính bạn
      const String apiUrl =
          'http://10.21.6.153:5000/api/auth/google'; // Ví dụ IP

      final response = await dio.post(apiUrl, data: {'idToken': idToken});

      if (response.statusCode == 200) {
        final jwtToken = response.data['token'];
        debugPrint("Đăng nhập backend thành công. JWT Token: $jwtToken");

        // TODO: Lưu jwtToken vào flutter_secure_storage

        // Điều hướng đến trang chủ
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (error) {
      debugPrint("Đã có lỗi xảy ra khi đăng nhập bằng Google: $error");
      // TODO: Hiển thị thông báo lỗi cho người dùng
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() == true) {
      // Logic đăng nhập thành công
      debugPrint("Email: ${_emailController.text}");
      debugPrint("Password: ${_passwordController.text}");
      // Sau khi đăng nhập thành công, chuyển đến màn hình chính
      Navigator.of(context).pushReplacement(
        // THAY THẾ Ở ĐÂY
        CustomPageRoute(
          child: const DashboardScreen(),
          type: PageTransitionType.scale,
        ),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      // THAY THẾ Ở ĐÂY
      // Dùng hiệu ứng slide cho việc chuyển tới/lui giữa Login và Signup
      CustomPageRoute(
        child: const SignupScreen(),
        type: PageTransitionType.slide,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. HEADER & LOGO ---
                  Image.asset(
                    'assets/logo_splash.png', // Sử dụng lại logo của bạn
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chào mừng trở lại!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để tiếp tục khám phá',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  // --- 2. FORM NHẬP LIỆU ---
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

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
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Link "Quên mật khẩu"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Điều hướng đến trang Quên mật khẩu
                      },
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. NÚT ĐĂNG NHẬP ---
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.deepOrange.withOpacity(0.4),
                    ),
                    child: const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- 4. CÁC LỰA CHỌN KHÁC ---
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'HOẶC ĐĂNG NHẬP VỚI',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nút Đăng nhập với Google
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset('assets/google_logo.png', height: 24),
                    label: const Text(
                      'Google',
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
                  const SizedBox(height: 40),

                  // --- 5. FOOTER: LINK ĐĂNG KÝ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton(
                        onPressed: _navigateToSignup,
                        child: const Text(
                          "Đăng ký ngay",
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
