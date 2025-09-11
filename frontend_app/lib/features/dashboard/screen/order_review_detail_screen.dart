// lib/features/dashboard/screen/review_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/review_model.dart';
import 'package:flutter_dapm/shared/services/review_service.dart';
import 'package:intl/intl.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String orderId;
  const ReviewDetailScreen({super.key, required this.orderId});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  late Future<ReviewModel?> _reviewFuture;

  @override
  void initState() {
    super.initState();
    _reviewFuture = _reviewService.getReviewByOrderId(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Đánh giá đơn hàng'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          bottom: const TabBar(
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Đánh giá shop'),
              Tab(text: 'Đánh giá người mua'),
            ],
          ),
        ),
        body: FutureBuilder<ReviewModel?>(
          future: _reviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Không thể tải đánh giá.'));
            }

            final review = snapshot.data!;
            return TabBarView(
              children: [
                // Tab 1: Đánh giá shop
                _buildShopReviewTab(review),
                // Tab 2: Placeholder
                const Center(child: Text('Chức năng đang phát triển')),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShopReviewTab(ReviewModel review) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildReviewCard(review),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final firstItem = review.orderItems.isNotEmpty ? review.orderItems.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: review.customer.avatarUrl != null
                ? NetworkImage(review.customer.avatarUrl!)
                : null,
            child: review.customer.avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(review.customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStarRating(review.rating),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd-MM-yyyy HH:mm').format(review.createdAt.toLocal()),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ),
        if (review.comment != null && review.comment!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56.0, top: 8, bottom: 8),
            child: Text(review.comment!),
          ),
        if (firstItem != null)
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: Row(
              children: [
                if (firstItem.imageUrl != null)
                  Image.network(
                    firstItem.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(firstItem.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}