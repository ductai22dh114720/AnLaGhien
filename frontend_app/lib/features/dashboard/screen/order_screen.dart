import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  // Tham số để nhận tab ban đầu cần hiển thị
  final int initialIndex;

  const OrderScreen({super.key, this.initialIndex = 0}); // Mặc định là tab 0

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

// Sử dụng TickerProviderStateMixin để quản lý animation của TabController
class _OrderScreenState extends State<OrderScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Định nghĩa các tab và trạng thái tương ứng trong database
  final List<Map<String, String>> _tabs = [
    {'label': 'Chờ xác nhận', 'status': 'pending'},
    {'label': 'Chờ lấy hàng', 'status': 'confirmed'},
    {'label': 'Đang giao', 'status': 'out_for_delivery'},
    {'label': 'Đã giao', 'status': 'delivered'},
    {'label': 'Đã hủy', 'status': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với độ dài và index ban đầu
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex, // Sử dụng index được truyền vào
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        // bottom được dùng để đặt TabBar ngay dưới AppBar
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Cho phép cuộn ngang nếu các tab quá dài
          tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Tạo một widget OrderList cho mỗi tab, truyền vào trạng thái cần lọc
        children: _tabs.map((tab) {
          return OrderList(status: tab['status']!);
        }).toList(),
      ),
    );
  }
}

// ---- Widget con để hiển thị danh sách đơn hàng theo trạng thái ----

class OrderList extends StatefulWidget {
  final String status; // Trạng thái cần lọc (e.g., 'pending', 'confirmed')

  const OrderList({super.key, required this.status});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with AutomaticKeepAliveClientMixin {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.getOrderHistory();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _loadOrders();
    });
  }

  // Giữ lại trạng thái của tab khi người dùng cuộn qua lại
  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<OrderModel>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi tải dữ liệu."));
        }
        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        final filteredOrders = snapshot.data!
            .where((order) => order.status == widget.status)
            .toList();

        if (filteredOrders.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0), // Tăng padding
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(
                  filteredOrders[index]); // Gọi hàm build card đã nâng cấp
            },
          ),
        );
      },
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Không có đơn hàng nào trong mục này",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final currencyFormatter = NumberFormat.currency(
        locale: 'vi_VN', symbol: 'đ');
    final totalItems = order.items.fold<int>(
        0, (sum, item) => sum + item.quantity);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => OrderDetailScreen(orderId: order.id)),
          );
          if (result == true) {
            _refreshOrders();
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng 1: Tên nhà hàng và Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 20,
                          color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        order.restaurantName, // Hiển thị tên nhà hàng
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    _getStatusText(order.status).toUpperCase(),
                    // Hiển thị trạng thái
                    style: TextStyle(color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Dòng 2: Tóm tắt sản phẩm (hiển thị 1 sản phẩm)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.items.first.imageUrl ??
                        'https://via.placeholder.com/150',
                    width: 60, height: 60, fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  order.items.first.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: totalItems > 1 ? Text(
                    'và ${totalItems - 1} sản phẩm khác...') : const Text(''),
              ),
              const SizedBox(height: 12),
              // Dòng 3: Tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$totalItems sản phẩm: ', style: const TextStyle(
                      fontSize: 15, color: Colors.black54)),
                  Text(
                    currencyFormatter.format(order.totalAmount),
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dòng 4: Nút hành động
              if (order.status == 'delivered' || order.status == 'cancelled')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        /* TODO: Logic mua lại */
                      },
                      child: const Text('Mua lại'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- CÁC HÀM HELPER CHO MÀU SẮC VÀ TEXT ---
String _getStatusText(String status) {
  switch (status) {
    case 'pending': return 'Chờ xác nhận';
    case 'confirmed': return 'Chờ lấy hàng';
    case 'out_for_delivery': return 'Đang giao';
    case 'delivered': return 'Đã giao';
    case 'cancelled': return 'Đã hủy';
    default: return status;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending': return Colors.orange.shade700;
    case 'delivered': return Colors.green.shade700;
    case 'cancelled': return Colors.red.shade700;
    default: return Colors.blue.shade700;
  }
}
