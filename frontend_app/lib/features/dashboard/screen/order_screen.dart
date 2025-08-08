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
  late List<GlobalKey<_OrderListState>> _tabKeys;

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
    _tabKeys = List.generate(_tabs.length, (_) => GlobalKey<_OrderListState>());
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
  // Hàm để gọi refresh của tab hiện tại
  void _handleRefresh() {
    // Lấy key của tab đang được chọn
    final currentTabKey = _tabKeys[_tabController.index];
    // Gọi hàm _refreshOrders của State tương ứng
    currentTabKey.currentState?._refreshOrders();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- THAY THẾ TOÀN BỘ APPBAR BẰNG ĐOẠN NÀY ---
      appBar: AppBar(
        title: const Text("Đơn hàng của tôi"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0, // Bỏ bóng đổ dưới AppBar cho phẳng hơn
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh, // Gọi hàm refresh của tab hiện tại
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),

          // --- CÁC THAY ĐỔI CHÍNH NẰM Ở ĐÂY ---
          indicatorColor: Colors.white, // Màu của đường gạch chân tab đang chọn
          indicatorWeight: 3.0, // Độ dày của đường gạch chân
          labelColor: Colors.white, // Màu chữ của tab đang chọn
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Màu chữ của tab không được chọn (hơi mờ đi)
          labelStyle: const TextStyle(
            fontSize: 15, // Tăng kích thước chữ một chút
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500, // Chữ không in đậm cho tab chưa chọn
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Gán key cho mỗi instance của OrderList
        children: List.generate(_tabs.length, (index) {
          return OrderList(
            key: _tabKeys[index], // Gán key tương ứng
            status: _tabs[index]['status']!,
          );
        }),
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

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(filteredOrders[index]);
          },
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

  // --- HÀM _buildOrderCard ĐÃ ĐƯỢC NÂNG CẤP ---
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
                        order.restaurantName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    _getStatusText(order.status).toUpperCase(),
                    style: TextStyle(color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Dòng 2: Tóm tắt sản phẩm (chỉ hiển thị 1 sản phẩm đầu tiên)
              if (order.items.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.items.first.imageUrl ??
                          'https://via.placeholder.com/150',
                      width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.image_not_supported_outlined),
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
                    style: const TextStyle(fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dòng 4: Nút hành động theo ngữ cảnh
              if (order.status == 'delivered' || order.status == 'cancelled')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == 'delivered')
                      ElevatedButton(
                        onPressed: () {
                          /* TODO: Logic đánh giá */
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Đánh giá'),
                      ),
                    if (order.status == 'cancelled')
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
