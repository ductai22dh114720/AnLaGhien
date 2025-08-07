import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  Future<void> _refreshOrders() async {
    // Gán lại future, điều này sẽ trigger FutureBuilder build lại
    setState(() {
      _ordersFuture = _orderService.getOrderHistory();
    });
  }
  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử Đơn hàng"),
        actions: [
          // Thêm nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
          }

          // Trạng thái không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Bạn chưa có đơn hàng nào.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          // Trạng thái có dữ liệu, hiển thị danh sách
          final orders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshOrders, // Gọi hàm refresh khi kéo xuống
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget helper để build một card cho mỗi đơn hàng
  Widget _buildOrderCard(OrderModel order) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormatter = DateFormat('HH:mm - dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trên cùng: Ngày và Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày đặt: ${dateFormatter.format(order.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const Divider(height: 24),
            // Tóm tắt sản phẩm
            Text(
              'Gồm: ${order.items.map((item) => item.name).join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Dòng dưới cùng: Tổng tiền và Nút
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền: ${currencyFormatter.format(order.totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Chuyển đến trang chi tiết đơn hàng
                  },
                  child: const Text('Xem chi tiết'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để hiển thị chip trạng thái với màu sắc tương ứng
  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Đã giao';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.blue;
        text = status;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}