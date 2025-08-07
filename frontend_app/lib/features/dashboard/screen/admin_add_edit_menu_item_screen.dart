import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';

class AdminAddEditMenuItemScreen extends StatefulWidget {
  final MenuItemModel? menuItem;

  const AdminAddEditMenuItemScreen({super.key, this.menuItem});

  @override
  State<AdminAddEditMenuItemScreen> createState() => _AdminAddEditMenuItemScreenState();
}

class _AdminAddEditMenuItemScreenState extends State<AdminAddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  // Controllers cho các trường
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late TextEditingController _restaurantIdController;
  late TextEditingController _categoryController;
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get _isEditing => widget.menuItem != null;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu cũ (nếu có)
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _priceController = TextEditingController(text: widget.menuItem?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.menuItem?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.menuItem?.imageUrl ?? '');
    _restaurantIdController = TextEditingController(text: widget.menuItem?.restaurantId ?? '');
    _categoryController = TextEditingController(text: widget.menuItem?.category ?? '');
    _isAvailable = widget.menuItem?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _restaurantIdController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'description': _descController.text,
      'imageUrl': _imageUrlController.text,
      'restaurant': _restaurantIdController.text, // Backend cần ID này
      'category': _categoryController.text,
      'isAvailable': _isAvailable,
    };

    bool success = false;
    if (_isEditing) {
      final result = await _productService.updateMenuItem(widget.menuItem!.id, data);
      success = result != null;
    } else {
      final result = await _productService.createMenuItem(data);
      success = result != null;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEditing ? 'Cập nhật' : 'Thêm'} thành công!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true); // Trả về true để báo thành công
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isEditing ? 'Cập nhật' : 'Thêm'} thất bại.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa Món ăn' : 'Thêm Món ăn'),
        backgroundColor: Colors.indigo,
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.only(right: 16.0), child: Center(child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveMenuItem),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFormField(controller: _nameController, label: 'Tên món ăn'),
              _buildTextFormField(
                  controller: _priceController,
                  label: 'Giá',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]
              ),
              _buildTextFormField(controller: _descController, label: 'Mô tả', maxLines: 3),
              _buildTextFormField(controller: _imageUrlController, label: 'URL Hình ảnh'),
              _buildTextFormField(controller: _restaurantIdController, label: 'ID Nhà hàng'),
              _buildTextFormField(controller: _categoryController, label: 'Danh mục (e.g., Burger)'),
              SwitchListTile(
                title: const Text('Có sẵn để bán?'),
                value: _isAvailable,
                onChanged: (bool value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
                activeColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng không để trống trường này';
          }
          return null;
        },
      ),
    );
  }
}