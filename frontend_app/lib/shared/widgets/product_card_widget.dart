// lib/shared/widgets/product_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/authentication/screen/details_screen.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProductCardWidget extends StatelessWidget {
  final MenuItemModel item;

  const ProductCardWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // Logic điều hướng đến trang chi tiết
    void navigateToDetails() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            menuItemId: item.id,
            imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
            title: item.name,
            description: item.description ?? "Chưa có mô tả.",
            price: item.price,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: navigateToDetails,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Phần nền của card
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          // Phần thông tin (tên, giá)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currencyFormatter.format(item.price),
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFFFA4A0C)),
                  ),
                ],
              ),
            ),
          ),
          // Phần ảnh
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent, // Nền trong suốt
                backgroundImage: NetworkImage(item.imageUrl ?? ''),
                onBackgroundImageError: (e, s) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}