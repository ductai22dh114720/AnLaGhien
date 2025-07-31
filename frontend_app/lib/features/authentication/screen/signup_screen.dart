import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_dapm/features/dashboard/screen/dashboard_screen.dart';
import 'package:flutter_dapm/shared/constants/api_config.dart';
import 'package:flutter_dapm/shared/models/address_model.dart';
import 'package:flutter_dapm/shared/services/address_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ------------------- 1. KHAI BÁO BIẾN ------------------- //

  // Keys & Services
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();

  // Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();

  // Trạng thái Form
  String? _selectedGender;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Trạng thái Địa chỉ
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];
  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;
  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  // ------------------- 2. VÒNG ĐỜI WIDGET ------------------- //

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  // ------------------- 3. CÁC HÀM XỬ LÝ LOGIC ------------------- //

  // --- Logic Địa chỉ ---
  void _loadProvinces() async {
    _provinces = await _addressService.getProvinces();
    if (mounted) {
      setState(() => _isLoadingProvinces = false);
    }
  }

  void _onProvinceChanged(Province? province) async {
    if (province == null || province == _selectedProvince) return;

    // Hiển thị loading và reset các giá trị phụ thuộc
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _selectedWard = null;
      _districts = [];
      _wards = [];
      _isLoadingDistricts = true; // Bật loading
      _isLoadingWards = false; // Tắt loading (nếu có)
    });

    // Lấy dữ liệu mới
    final loadedDistricts = await _addressService.getDistricts(province.id);

    // Cập nhật UI với dữ liệu mới
    if (mounted) {
      setState(() {
        _districts = loadedDistricts;
        _isLoadingDistricts = false; // Tắt loading
      });
    }
  }

  void _onDistrictChanged(District? district) async {
    if (district == null || district == _selectedDistrict) return;

    // Hiển thị loading và reset giá trị phụ thuộc
    setState(() {
      _selectedDistrict = district;
      _selectedWard = null;
      _wards = [];
      _isLoadingWards = true; // Bật loading
    });

    // Lấy dữ liệu mới
    final loadedWards = await _addressService.getWards(district.id);

    // Cập nhật UI với dữ liệu mới
    if (mounted) {
      setState(() {
        _wards = loadedWards;
        _isLoadingWards = false; // Tắt loading
      });
    }
  }

  // --- Logic Form ---
  Future<void> _handleSignup() async {
    // 1. Validate form
    if (_formKey.currentState?.validate() != true) {
      // THÊM VÀO ĐÂY: Hiển thị thông báo nếu form không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các thông tin đã nhập.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Dừng lại
    }
    final String fullAddress =
        "${_streetController.text}, ${_selectedWard?.name}, ${_selectedDistrict?.name}, ${_selectedProvince?.name}";
    final Map<String, dynamic> userData = {
      "name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "phone": _phoneController.text,
      "address": fullAddress,
      "dob": _dobController.text,
      "gender": _selectedGender,
    };
    try {
      final dio = Dio();
      const String apiUrl = '${ApiConfig.baseUrl}/auth/signup';
      final response = await dio.post(apiUrl, data: userData);

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
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
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint("Đăng ký Google đã bị hủy.");
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint("Không lấy được ID Token từ Google.");
        return;
      }
      final dio = Dio();
      const String apiUrl = '${ApiConfig.baseUrl}/auth/google';
      final response = await dio.post(apiUrl, data: {'idToken': idToken});

      if (response.statusCode == 200 && mounted) {
        // TODO: Lưu token: response.data['token']
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (error) {
      debugPrint("Lỗi đăng ký Google: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký bằng Google thất bại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Họ và tên',
                    icon: Icons.person_outline,
                    validator:
                        (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      'Ngày tháng năm sinh',
                      Icons.calendar_today_outlined,
                    ),
                    onTap: () => _selectDate(context),
                    validator:
                        (v) => v!.isEmpty ? 'Vui lòng chọn ngày sinh' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: _inputDecoration(
                      'Giới tính',
                      Icons.wc_outlined,
                    ),
                    items:
                        ['Nam', 'Nữ', 'Khác']
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                    validator:
                        (v) => v == null ? 'Vui lòng chọn giới tính' : null,
                  ),
                  const SizedBox(height: 16),

                  // --- PHẦN ĐỊA CHỈ ---
                  _buildProvinceDropdown(),
                  const SizedBox(height: 16),

                  if (_selectedProvince != null) ...[
                    _buildDistrictDropdown(),
                    const SizedBox(height: 16),
                  ],

                  if (_selectedDistrict != null) ...[
                    _buildWardDropdown(),
                    const SizedBox(height: 16),
                  ],

                  if (_selectedWard != null) ...[
                    _buildTextFormField(
                      controller: _streetController,
                      labelText: 'Số nhà, tên đường',
                      icon: Icons.home_work_outlined,
                      validator:
                          (v) =>
                              v!.isEmpty
                                  ? 'Vui lòng nhập chi tiết địa chỉ'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- CÁC TRƯỜNG CÒN LẠI ---
                  _buildTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@._-]'),
                      ),
                    ],
                    validator: (v) {
                      if (v!.isEmpty) return 'Vui lòng nhập email';
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v))
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v!.isEmpty) return 'Vui lòng nhập số điện thoại';
                      if (v.length < 10) return 'Số điện thoại không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp(r'[\u0300-\u036f]'),
                      ),
                    ],
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
                    validator: (v) {
                      if (v!.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (v.length < 6)
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscured,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                        RegExp(r'[\u0300-\u036f]'),
                      ),
                    ],
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
                    validator: (v) {
                      if (v!.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                      if (v != _passwordController.text)
                        return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),
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

  Widget _buildProvinceDropdown() {
    return _isLoadingProvinces
        ? _buildLoadingIndicator(Icons.location_city)
        : DropdownButtonFormField<Province>(
          value: _selectedProvince,
          hint: const Text('Chọn Tỉnh/Thành phố'),
          isExpanded: true,
          decoration: _inputDecoration('Tỉnh/Thành phố', Icons.location_city),
          items:
              _provinces
                  .map(
                    (province) => DropdownMenuItem(
                      value: province,
                      child: Text(province.name),
                    ),
                  )
                  .toList(),
          onChanged: _onProvinceChanged,
          validator:
              (value) => value == null ? 'Vui lòng chọn Tỉnh/Thành phố' : null,
        );
  }

  Widget _buildDistrictDropdown() {
    return _isLoadingDistricts
        ? _buildLoadingIndicator(Icons.map_outlined)
        : DropdownButtonFormField<District>(
          key: ValueKey(_selectedProvince),
          value: _selectedDistrict,
          hint: const Text('Chọn Quận/Huyện'),
          isExpanded: true,
          decoration: _inputDecoration('Quận/Huyện', Icons.map_outlined),
          items:
              _districts
                  .map(
                    (district) => DropdownMenuItem(
                      value: district,
                      child: Text(district.name),
                    ),
                  )
                  .toList(),
          onChanged: _onDistrictChanged,
          validator:
              (value) => value == null ? 'Vui lòng chọn Quận/Huyện' : null,
        );
  }

  Widget _buildWardDropdown() {
    return _isLoadingWards
        ? _buildLoadingIndicator(Icons.location_on_outlined)
        : DropdownButtonFormField<Ward>(
          key: ValueKey(_selectedDistrict),
          value: _selectedWard,
          hint: const Text('Chọn Phường/Xã'),
          isExpanded: true,
          decoration: _inputDecoration('Phường/Xã', Icons.location_on_outlined),
          items:
              _wards
                  .map(
                    (ward) =>
                        DropdownMenuItem(value: ward, child: Text(ward.name)),
                  )
                  .toList(),
          onChanged: (ward) => setState(() => _selectedWard = ward),
          validator:
              (value) => value == null ? 'Vui lòng chọn Phường/Xã' : null,
        );
  }

  Widget _buildLoadingIndicator(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Text('Đang tải...', style: TextStyle(color: Colors.grey.shade600)),
        ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(labelText, icon),
      validator: validator,
      inputFormatters: inputFormatters,
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
