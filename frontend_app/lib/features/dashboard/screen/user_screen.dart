import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dapm/shared/models/address_suggestion_model.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/services/address_service.dart';
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
  final _addressService = AddressService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;

  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(10.7769, 106.7009);
  List<Marker> _markers = [];

  List<AddressSuggestion> _placeSuggestions = [];
  Timer? _debounce;
  bool _isSearchingAddress = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');

    final initialAddress = widget.user.address;
    // Sửa lại kiểm tra null cho an toàn và clean
    if (initialAddress != null && initialAddress.isNotEmpty) {
      _geocodeAddress(initialAddress);
    } else {
      _updateMapMarker(_currentPosition);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- LOGIC FUNCTIONS ---

  void _onAddressChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      if (input.isNotEmpty) {
        // Kiểm tra `mounted` trước khi setState
        if (!mounted) return;
        setState(() => _isSearchingAddress = true);

        final suggestions = await _addressService.getAutocompleteSuggestions(input);

        if (!mounted) return;
        setState(() {
          _placeSuggestions = suggestions;
          _isSearchingAddress = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _placeSuggestions = []);
      }
    });
  }

  Future<void> _geocodeAddress(String address) async {
    final coordinates = await _addressService.getCoordinatesFromAddress(address);
    if (coordinates != null) {
      _goToPosition(coordinates);
    }
  }

  void _goToPosition(LatLng position) {
    setState(() {
      _currentPosition = position;
    });
    _mapController.move(position, 16.0);
    _updateMapMarker(position);
  }

  void _updateMapMarker(LatLng position) {
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

  Future<void> _handleUpdateProfile() async {
    // Sửa lại kiểm tra validate cho clean
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
    };

    final success = await _userService.updateUserProfile(updatedData);

    // Sửa lại để tuân thủ `use_build_context_synchronously`
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
      );
      setState(() => _isEditing = false);
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return; // Nếu người dùng không chọn ảnh

    setState(() => _isLoading = true);
    final File imageFile = File(image.path);
    final updatedUser = await _userService.uploadAvatar(imageFile);

    // Sửa lại để tuân thủ `use_build_context_synchronously`
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (updatedUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh thành công!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh thất bại.'), backgroundColor: Colors.red),
      );
    }
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
                          // SỬA LẠI: Gán hàm vào onTap
                          onTap: _pickAndUploadImage,
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
                _buildUserInfoField(label: "Họ và tên", icon: Icons.person, controller: _nameController, isEditing: _isEditing),
                const SizedBox(height: 20),
                _buildUserInfoField(label: "Email", icon: Icons.email, controller: _emailController, isEditing: false),
                const SizedBox(height: 20),
                _buildUserInfoField(label: "Số điện thoại", icon: Icons.phone, controller: _phoneController, isEditing: _isEditing),
                const SizedBox(height: 20),
                _buildUserInfoField(
                  label: "Địa chỉ",
                  icon: Icons.location_on,
                  controller: _addressController,
                  isEditing: _isEditing,
                  maxLines: 3,
                  onChanged: _isEditing ? _onAddressChanged : null,
                ),
                if (_isSearchingAddress)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Center(child: CircularProgressIndicator()))
                else if (_placeSuggestions.isNotEmpty)
                  _buildSuggestionsList(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: 16.0,
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

  Widget _buildSuggestionsList() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // SỬA LẠI: theo gợi ý mới nhất
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 4,
          )
        ],
      ),
      child: ListView.builder(
        itemCount: _placeSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _placeSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_pin, color: Colors.grey),
            title: Text(suggestion.displayName),
            onTap: () {
              setState(() {
                _addressController.text = suggestion.displayName;
                _placeSuggestions = [];
                _geocodeAddress(suggestion.displayName);
              });
              FocusScope.of(context).unfocus();
            },
          );
        },
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      maxLines: maxLines,
      onChanged: onChanged,
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