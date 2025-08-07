// lib/features/dashboard/screen/admin_order_management_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
// Import màn hình chi tiết đơn hàng (chúng ta sẽ tái sử dụng nó)
import 'package:flutter_dapm/features/dashboard/screen/order_detail_screen.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final dateFormatter = DateFormat('HH:mm - dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getAllOrders(); // Gọi hàm lấy TẤT CẢ đơn hàng
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _orderService.getAllOrders();
    });
  }

  Future<void> _showUpdateStatusDialog(OrderModel order) async {
    String selectedStatus = order.status; // Trạng thái hiện tại
    final List<String> allStatus = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'];

    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cập nhật trạng thái'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: allStatus.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) {
              if (value != null) {
                selectedStatus = value;
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selectedStatus),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );

    if (newStatus != null && newStatus != order.status) {
      final success = await _orderService.updateOrderStatus(order.id, newStatus);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật trạng thái thành công!'), backgroundColor: Colors.green));
          _refreshOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại.'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Đơn hàng"),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Không có đơn hàng nào."));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ExpansionTile( // Dùng ExpansionTile để xem nhanh sản phẩm
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(order.status),
                      child: Icon(_getStatusIcon(order.status), color: Colors.white),
                    ),
                    title: Text('Mã đơn: ...${order.id.substring(order.id.length - 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(dateFormatter.format(order.createdAt)),
                    trailing: Text(
                      currencyFormatter.format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    children: [
                      // Nội dung mở rộng
                      ...order.items.map((item) => ListTile(
                        title: Text('${item.name} (x${item.quantity})'),
                        dense: true,
                      )).toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: order.id)),
                                );
                              },
                              child: const Text('Xem chi tiết'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _showUpdateStatusDialog(order),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                              child: const Text('Đổi trạng thái'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getRoleColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'out_for_delivery': return Colors.cyan;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_top_rounded;
      case 'confirmed': return Icons.check_circle_outline_rounded;
      case 'preparing': return Icons.soup_kitchen_outlined;
      case 'out_for_delivery': return Icons.delivery_dining_outlined;
      case 'delivered': return Icons.task_alt_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.help_outline_rounded;
    }
  }
}