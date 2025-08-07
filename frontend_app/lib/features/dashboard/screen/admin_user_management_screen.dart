// lib/features/dashboard/screen/admin_user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';
import 'package:flutter_dapm/shared/services/user_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getAllUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = _userService.getAllUsers();
    });
  }

  Future<void> _showChangeRoleDialog(UserModel user) async {
    String? selectedRole = user.role;
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Thay đổi quyền cho ${user.name}'),
          content: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            items: ['customer', 'admin', 'delivery'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Cần một StatefulWidget bên trong dialog để cập nhật,
              // cách đơn giản là dùng một StatefulBuilder.
              (dialogContext as Element).markNeedsBuild(); // Trick để rebuild dialog
              selectedRole = newValue;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Lưu'),
              onPressed: () async {
                if (selectedRole != null && selectedRole != user.role) {
                  bool success = await _userService.updateUserRole(user.id, selectedRole!);
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật quyền thành công!'), backgroundColor: Colors.green));
                    _refreshUsers(); // Tải lại danh sách
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại.'), backgroundColor: Colors.red));
                  }
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Người dùng"),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có người dùng nào."));
            }
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl ?? 'https://i.pravatar.cc/150'),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                  trailing: Chip(
                    label: Text(
                      user.role,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _getRoleColor(user.role),
                  ),
                  onTap: () => _showChangeRoleDialog(user),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'delivery':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}