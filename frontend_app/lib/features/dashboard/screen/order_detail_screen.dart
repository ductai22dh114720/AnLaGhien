// lib/features/dashboard/screen/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  late Future<OrderModel?> _orderDetailFuture;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final dateFormatter = DateFormat('HH:mm - dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = _orderService.getOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết Đơn hàng"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<OrderModel?>(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Không thể tải chi tiết đơn hàng."));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Thông tin chung"),
                _buildInfoCard([
                  _buildInfoRow("Mã đơn hàng:", order.id),
                  _buildInfoRow("Ngày đặt:", dateFormatter.format(order.createdAt)),
                  _buildInfoRow("Trạng thái:", order.status, isStatus: true),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle("Các món đã đặt"),
                _buildItemsList(order.items),
                const Divider(height: 32),
                _buildSummarySection(order),
                const SizedBox(height: 24),
                _buildSectionTitle("Địa chỉ giao hàng"),
                _buildInfoCard([
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Colors.deepOrange),
                    title: Text(order.deliveryAddress, style: const TextStyle(height: 1.5)),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- CÁC WIDGET HELPER ----

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          isStatus
              ? _buildStatusChip(value)
              : Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<OrderItemModel> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl ?? 'https://via.placeholder.com/150',
                width: 50, height: 50, fit: BoxFit.cover,
              ),
            ),
            title: Text(item.name),
            subtitle: Text('Số lượng: ${item.quantity}'),
            trailing: Text(currencyFormatter.format(item.priceAtOrder)),
          );
        },
        separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
      ),
    );
  }

  Widget _buildSummarySection(OrderModel order) {
    return Column(
      children: [
        _buildInfoRow("Tổng tiền hàng:", currencyFormatter.format(order.totalAmount)),
        _buildInfoRow("Phí vận chuyển:", "Miễn phí"), // TODO: Thêm phí ship
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Thành tiền", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                currencyFormatter.format(order.totalAmount),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Copy hàm này từ OrderScreen
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