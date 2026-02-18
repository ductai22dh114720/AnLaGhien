import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/services/order_service.dart';
// --- ĐỊNH NGHĨA MÀU SẮC THEO THIẾT KẾ ---
// Bạn có thể import các hằng số màu từ file order_screen.dart nếu chúng được định nghĩa ở file riêng
const Color kYellowBackgroundColor = Color(0xFFFDE084);
const Color kPrimaryOrangeColor = Color(0xFFF56844);
const Color kLightOrangeColor = Color(0xFFFFF0ED);
const Color kTextColor = Color(0xFF333333);

//==================================================================
// MÀN HÌNH 1: CHỌN LÝ DO HỦY ĐƠN
//==================================================================
class CancelOrderScreen extends StatefulWidget {
  final String orderId;

  const CancelOrderScreen({super.key, required this.orderId});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  final List<String> _cancellationReasons = [
    "Waiting for too long",
    "Unable to contact driver",
    "Driver is not moving",
    "My reason is not listed",
    "Changed my mind",
  ];

  void _submitCancellation() async {
    String finalReason;

    // Kiểm tra xem người dùng có chọn lý do không
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason.')),
      );
      return;
    }

    // Nếu người dùng chọn "My reason is not listed" thì lấy text từ ô input
    // Nếu không thì lấy lý do đã chọn
    if (_selectedReason == "My reason is not listed") {
      finalReason = _otherReasonController.text.trim();
      if (finalReason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your reason in the text box.')),
        );
        return;
      }
    } else {
      finalReason = _selectedReason!;
    }

    setState(() => _isLoading = true);

    // GỌI HÀM cancelOrder TỪ SERVICE
    final success = await _orderService.cancelOrder(widget.orderId, finalReason);
    setState(() => _isLoading = false);

    if (success && mounted) {
      // Thay thế màn hình hiện tại bằng màn hình thành công
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CancellationSuccessScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kYellowBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Please select the reason for cancellation:",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ..._cancellationReasons.map((reason) => _buildReasonRadioTile(reason)),
                      const SizedBox(height: 20),
                      const Text(
                        "Others",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildOtherReasonTextField(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Text(
            "Cancel Order",
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

  Widget _buildReasonRadioTile(String reason) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(reason, style: const TextStyle(fontSize: 16)),
          trailing: Radio<String>(
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            activeColor: kPrimaryOrangeColor,
          ),
          onTap: () {
            setState(() {
              _selectedReason = reason;
            });
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildOtherReasonTextField() {
    return TextField(
      controller: _otherReasonController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Others reason...",
        fillColor: const Color(0xFFFFF8E1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitCancellation,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryOrangeColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          "Submit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


//==================================================================
// MÀN HÌNH 2: THÔNG BÁO HỦY THÀNH CÔNG
//==================================================================
class CancellationSuccessScreen extends StatefulWidget {
  const CancellationSuccessScreen({super.key});

  @override
  State<CancellationSuccessScreen> createState() => _CancellationSuccessScreenState();
}

class _CancellationSuccessScreenState extends State<CancellationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động quay về màn hình trước đó sau 2 giây
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Trả về 'true' để báo cho OrderScreen biết rằng việc hủy đã thành công
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kYellowBackgroundColor,
      // Dùng lại BottomNavBar để giao diện nhất quán
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _buildSuccessIcon(),
              const SizedBox(height: 32),
              const Text(
                "¡Order Cancelled!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your order has been successfully cancelled",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              const Text(
                "If you have any question reach directly to our customer support",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kPrimaryOrangeColor, width: 4),
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryOrangeColor,
            ),
          ),
        ),
      ),
    );
  }

  // Widget xây dựng Bottom Navigation Bar (để demo cho giống ảnh)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimaryOrangeColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25)
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Đặt mục "orders" (đĩa thức ăn) là mục được chọn
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent, // Nền trong suốt để lấy màu của Container
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.room_service_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), label: ''),
        ],
      ),
    );
  }
}