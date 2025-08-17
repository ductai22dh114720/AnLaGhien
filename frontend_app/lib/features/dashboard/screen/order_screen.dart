import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_detail_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/cancel_order_screen.dart';

// --- ĐỊNH NGHĨA MÀU SẮC THEO THIẾT KẾ ---
const Color kYellowBackgroundColor = Color(0xFFF9A825); // Màu vàng nền
const Color kPrimaryOrangeColor = Color(0xFFF56844); // Màu cam chính
const Color kLightOrangeColor = Color(0xFFFFF0ED); // Màu cam nhạt cho button
const Color kTextColor = Color(0xFF333333); // Màu chữ chính

class OrderScreen extends StatefulWidget {
  final int initialTabIndex;
  const OrderScreen({super.key,this.initialTabIndex = 0});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // --- THAY THẾ TAB CONTROLLER BẰNG STATE ĐƠN GIẢN ---
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Lấy giá trị index được truyền vào để đặt tab ban đầu
    _selectedTabIndex = widget.initialTabIndex;
  }

  // Định nghĩa các tab mới và ánh xạ các trạng thái từ database
  final List<Map<String, dynamic>> _tabs = [
    {
      'label': 'Active',
      // 'Active' bao gồm các đơn hàng đang chờ, đã xác nhận và đang giao
      'statuses': ['pending', 'confirmed', 'out_for_delivery']
    },
    {
      'label': 'Completed',
      'statuses': ['delivered']
    },
    {
      'label': 'Cancelled',
      'statuses': ['cancelled']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kYellowBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER TÙY CHỈNH ---
            _buildCustomHeader(),

            // --- VÙNG NỘI DUNG CHÍNH ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: [
                    // --- CÁC NÚT TAB TRẠNG THÁI ---
                    _buildStatusTabs(),
                    const SizedBox(height: 20),
                    // --- DANH SÁCH ĐƠN HÀNG ---
                    Expanded(
                      child: OrderList(
                        // Truyền vào danh sách các trạng thái tương ứng với tab đang chọn
                        statuses: _tabs[_selectedTabIndex]['statuses'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng Header
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nút back
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Tiêu đề
          const Text(
            "My Orders",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng các nút tab
  Widget _buildStatusTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_tabs.length, (index) {
        bool isSelected = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryOrangeColor : kLightOrangeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _tabs[index]['label'],
              style: TextStyle(
                color: isSelected ? Colors.white : kPrimaryOrangeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---- Widget con để hiển thị danh sách đơn hàng ----
// Nó sẽ nhận một LIST các trạng thái thay vì một trạng thái duy nhất
class OrderList extends StatefulWidget {
  final List<String> statuses;

  const OrderList({super.key, required this.statuses});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Khi widget được cập nhật (vd: đổi tab), ta cần load lại data
  @override
  void didUpdateWidget(covariant OrderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statuses != oldWidget.statuses) {
      _loadOrders();
    }
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderService.getOrderHistory();
    });
  }

  Future<void> _refreshOrders() async {
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryOrangeColor,));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi tải dữ liệu."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Lọc các đơn hàng có trạng thái nằm trong danh sách statuses được truyền vào
        final filteredOrders = snapshot.data!
            .where((order) => widget.statuses.contains(order.status))
            .toList();

        if (filteredOrders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            // --- SỬ DỤNG GIAO DIỆN THẺ MỚI ---
            return _buildNewOrderCard(filteredOrders[index]);
          },
          separatorBuilder: (context, index) => const Divider(height: 24, color: Colors.transparent),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No orders in this category",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- HÀM XÂY DỰNG THẺ ĐƠN HÀNG MỚI THEO THIẾT KẾ ---
  Widget _buildNewOrderCard(OrderModel order) {
    // Định dạng tiền tệ theo $ như trong thiết kế
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    // Định dạng ngày tháng
    final dateFormatter = DateFormat('dd MMM, hh:mm a');

    final totalItems = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order.id)),
        );
        if (result == true) {
          _refreshOrders();
        }
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HÌNH ẢNH SẢN PHẨM ---
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  order.items.first.imageUrl ?? 'https://via.placeholder.com/150',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                  const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              // --- THÔNG TIN ĐƠN HÀNG VÀ NÚT ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tên sản phẩm chính
                        Text(
                          order.items.first.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kTextColor,
                          ),
                        ),
                        // Giá tiền
                        Text(
                          currencyFormatter.format(order.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kPrimaryOrangeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ngày đặt hàng
                        Text(
                          dateFormatter.format(order.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        // Số lượng items
                        Text(
                          '$totalItems items',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // --- CÁC NÚT HÀNH ĐỘNG ---
                    // Chỉ hiển thị cho các đơn hàng "Active"
                    if (widget.statuses.contains('pending') || widget.statuses.contains('confirmed') || widget.statuses.contains('out_for_delivery'))
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Điều hướng đến màn hình hủy và chờ kết quả trả về
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CancelOrderScreen(orderId: order.id),
                                  ),
                                );

                                // Nếu kết quả trả về là 'true' (hủy thành công),
                                // thì làm mới lại danh sách đơn hàng.
                                if (result == true) {
                                  _refreshOrders();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryOrangeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel Order'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () { /* TODO: Logic theo dõi tài xế */ },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kLightOrangeColor,
                                foregroundColor: kPrimaryOrangeColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Track Driver'),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
        ],
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
