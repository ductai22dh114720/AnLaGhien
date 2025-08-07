// lib/features/dashboard/screen/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/admin_user_management_screen.dart';
// Sửa lại import
import 'package:flutter_dapm/features/dashboard/screen/admin_menu_management_screen.dart';
// THÊM IMPORT MỚI
import 'package:flutter_dapm/features/dashboard/screen/admin_order_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Thêm logic đăng xuất
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _buildDashboardCard(
            context,
            icon: Icons.people_alt_outlined,
            label: "Quản lý Người dùng",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminUserManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.restaurant_menu_outlined,
            label: "Quản lý Món ăn",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminMenuManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.receipt_long_outlined,
            label: "Quản lý Đơn hàng",
            onTap: () {
              // SỬA LẠI: Điều hướng đến màn hình mới
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminOrderManagementScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            icon: Icons.bar_chart_outlined, // SỬA LẠI: Dùng icon khác
            label: "Thống kê", // SỬA LẠI: Dùng label khác
            onTap: () {
              // TODO: Điều hướng đến trang thống kê
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}