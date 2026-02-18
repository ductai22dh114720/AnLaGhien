// lib/features/dashboard/screen/admin_menu_management_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/features/dashboard/screen/admin_add_edit_menu_item_screen.dart';

class AdminMenuManagementScreen extends StatefulWidget {
  const AdminMenuManagementScreen({super.key});

  @override
  State<AdminMenuManagementScreen> createState() => _AdminMenuManagementScreenState();
}

class _AdminMenuManagementScreenState extends State<AdminMenuManagementScreen> {
  final ProductService _productService = ProductService();
  late Future<List<MenuItemModel>> _menuItemsFuture;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _productService.getAllMenuItems();
  }

  Future<void> _refreshMenuItems() async {
    setState(() {
      _menuItemsFuture = _productService.getAllMenuItems();
    });
  }

  void _navigateToAddEditScreen([MenuItemModel? item]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminAddEditMenuItemScreen(menuItem: item),
      ),
    );
    if (result == true && mounted) {
      _refreshMenuItems();
    }
  }

  Future<void> _deleteMenuItem(String id) async {
    // Hiển thị dialog xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa món ăn này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _productService.deleteMenuItem(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa món ăn thành công!'), backgroundColor: Colors.green));
          _refreshMenuItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thất bại.'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Món ăn"),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMenuItems,
        child: FutureBuilder<List<MenuItemModel>>(
          future: _menuItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Chưa có món ăn nào."));
            }
            final menuItems = snapshot.data!;
            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.imageUrl ?? 'https://via.placeholder.com/150'),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(currencyFormatter.format(item.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToAddEditScreen(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMenuItem(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}