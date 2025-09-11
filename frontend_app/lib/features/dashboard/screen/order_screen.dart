import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/cancel_order_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_detail_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_leave_review_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_review_detail_screen.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
import 'package:intl/intl.dart';

// --- ĐỊNH NGHĨA MÀU SẮC THEO THIẾT KẾ ---
const Color kYellowBackgroundColor = Color(0xFFF9A825); // Màu vàng nền
const Color kPrimaryOrangeColor = Color(0xFFF56844); // Màu cam chính
const Color kLightOrangeColor = Color(0xFFFFF0ED); // Màu cam nhạt cho button
const Color kTextColor = Color(0xFF333333); // Màu chữ chính

class OrderScreen extends StatefulWidget {
  final int initialTabIndex;

  const OrderScreen({super.key, this.initialTabIndex = 0});

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
      'label': 'Chờ xác nhận',
      'statuses': ['pending'],
    },
    {
      'label': 'Chờ lấy hàng',
      'statuses': ['confirmed']
    },
    {
      'label': 'Chờ giao hàng',
      'statuses': ['out_for_delivery'],
    },
    {
      'label': 'Đã giao',
      'statuses': ['delivered']
    },
    {
      'label': 'Đã hủy',
      'statuses': ['cancelled'],
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
    // Bọc Row bằng SingleChildScrollView để cho phép cuộn ngang
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Thêm physics để cuộn mượt hơn và ẩn thanh cuộn
      physics: const BouncingScrollPhysics(),
      child: Row(
        // Không dùng spaceAround nữa, để các nút nằm cạnh nhau
        children: List.generate(_tabs.length, (index) {
          bool isSelected = _selectedTabIndex == index;
          // Thêm Padding để tạo khoảng cách giữa các nút
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                // Giảm padding một chút để tiết kiệm không gian
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            ),
          );
        }),
      ),
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
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryOrangeColor),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi tải dữ liệu."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Lọc các đơn hàng có trạng thái nằm trong danh sách statuses được truyền vào
        final filteredOrders =
            snapshot.data!
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
          separatorBuilder:
              (context, index) => const Divider(
                height: 1,
                color: Color(0xFFF0F0F0),
                indent: 20,
                endIndent: 20,
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
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormatter = DateFormat('dd MMM, hh:mm a');
    final totalItems = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: order.id),
          ),
        );
        if (result == true) {
          _refreshOrders();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.items.first.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kTextColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormatter.format(order.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kPrimaryOrangeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormatter.format(order.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text('$totalItems items', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStatusLine(order),
                  const SizedBox(height: 12),
                  _buildActionButtons(order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM NÀY ĐÃ ĐƯỢC CẬP NHẬT ĐỂ DÙNG LOGIC CỦA BẠN ---
  Widget _buildStatusLine(OrderModel order) {
    // Chỉ hiển thị dòng trạng thái cho tab Completed và Cancelled
    if (order.status != 'delivered' && order.status != 'cancelled') {
      return const SizedBox.shrink();
    }
    IconData icon;
    switch (order.status) {
      case 'delivered':
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.info;
    }


    // Lấy text và màu từ các hàm helper bạn đã cung cấp
    final String text = _getStatusText(order.status);
    final Color color = _getStatusColor(order.status);

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }


  // --- WIDGET HELPER MỚI: HIỂN THỊ CÁC NÚT HÀNH ĐỘNG ---
  Widget _buildActionButtons(OrderModel order) {
    // --- GIAO DIỆN CHO TAB "COMPLETED" ---
    if (widget.statuses.contains('delivered')) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // NẾU ĐƠN HÀNG ĐÃ ĐƯỢC ĐÁNH GIÁ
                if (order.isReviewed) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ReviewDetailScreen(orderId: order.id),
                  ));
                }
                // NẾU CHƯA ĐÁNH GIÁ
                else {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LeaveReviewScreen(order: order),
                    ),
                  );
                  // Nếu LeaveReviewScreen trả về true (đã review thành công)
                  // thì tải lại danh sách đơn hàng để cập nhật isReviewed
                  if (result == true) {
                    _refreshOrders();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryOrangeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              // THAY ĐỔI TÊN NÚT DỰA TRÊN isReviewed
              child: Text(order.isReviewed ? 'Xem đánh giá' : 'Leave a review'),
            ),
          ),
          const SizedBox(width:10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                /* TODO: Logic đặt lại đơn hàng */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kLightOrangeColor,
                foregroundColor: kPrimaryOrangeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Order Again'),
            ),
          ),
        ],
      );
    }
    // --- GIAO DIỆN CHO TAB "CANCELLED" ---
    if (widget.statuses.contains('cancelled')) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                /* TODO: Logic đặt lại đơn hàng */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kLightOrangeColor,
                foregroundColor: kPrimaryOrangeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Order Again'),
            ),
          ),
        ],
      );
    }

    // --- GIAO DIỆN MẶC ĐỊNH CHO TAB "ACTIVE" ---
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // Chỉ cho phép hủy khi đơn hàng đang 'pending'
            onPressed:
                (order.status == 'pending')
                    ? () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => CancelOrderScreen(orderId: order.id),
                        ),
                      );
                      if (result == true) {
                        _refreshOrders();
                      }
                    }
                    : null, // Vô hiệu hóa nút nếu không phải 'pending'
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
            onPressed: () {
              /* TODO: Logic theo dõi tài xế */
            },
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
    );
  }
}

// --- CÁC HÀM HELPER CHO MÀU SẮC VÀ TEXT ---
String _getStatusText(String status) {
  switch (status) {
    case 'pending':
      return 'Chờ xác nhận';
    case 'confirmed':
      return 'Chờ lấy hàng';
    case 'out_for_delivery':
      return 'Đang giao';
    case 'delivered':
      return 'Đã giao';
    case 'cancelled':
      return 'Đã hủy';
    default:
      return status;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange.shade700;
    case 'delivered':
      return Colors.green.shade700;
    case 'cancelled':
      return Colors.red.shade700;
    default:
      return Colors.blue.shade700;
  }
}
