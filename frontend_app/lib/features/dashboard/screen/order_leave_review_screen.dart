import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/order_model.dart';
import 'package:flutter_dapm/shared/services/review_service.dart';
// --- ĐỊNH NGHĨA MÀU SẮC THEO THIẾT KẾ ---
const Color kYellowBackgroundColor = Color(0xFFFDE084);
const Color kPrimaryOrangeColor = Color(0xFFF56844);
const Color kLightOrangeColor = Color(0xFFFFF0ED);
const Color kTextColor = Color(0xFF333333);

class LeaveReviewScreen extends StatefulWidget {
  // Nhận toàn bộ object OrderModel để có thể truy cập mọi thông tin cần thiết
  final OrderModel order;

  const LeaveReviewScreen({super.key, required this.order});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  // Biến state để lưu trữ số sao người dùng chọn
  int _rating = 0;
  // Controller cho ô nhập text
  final _commentController = TextEditingController();
  bool _isLoading = false;
  final ReviewService _reviewService = ReviewService();

  void _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final comment = _commentController.text;

    final success = await _reviewService.postReview(
        orderId: widget.order.id,
        rating: _rating,
        comment: comment
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
      );
      // Trả về 'true' để báo cho màn hình trước biết là đã review thành công
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thất bại. Vui lòng thử lại.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Lấy thông tin sản phẩm đầu tiên để hiển thị
    final firstItem = widget.order.items.first;

    return Scaffold(
      backgroundColor: kYellowBackgroundColor,
      // Dùng lại BottomNavBar để giao diện nhất quán
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildDishImage(firstItem.imageUrl),
                      const SizedBox(height: 16),
                      Text(
                        firstItem.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "We'd love to know what you\nthink of your dish.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      _buildStarRating(),
                      const SizedBox(height: 32),
                      const Text(
                        "Leave us your comment!",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      _buildCommentTextField(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
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
            "Leave a Review",
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

  Widget _buildDishImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        imageUrl ?? 'https://via.placeholder.com/150',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Icon(
            Icons.image_not_supported, size: 150, color: Colors.grey
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: kPrimaryOrangeColor,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildCommentTextField() {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Write Review...",
        fillColor: const Color(0xFFFFF8E1), // Màu vàng nhạt
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kLightOrangeColor,
              foregroundColor: kPrimaryOrangeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryOrangeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

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
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}