// lib/features/dashboard/screen/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dapm/shared/widgets/product_card_widget.dart';


class SearchScreen extends StatefulWidget {
  final String searchQuery;
  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  late Future<List<MenuItemModel>> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = _productService.searchMenuItems(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(widget.searchQuery, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<MenuItemModel>>(
        future: _searchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi khi tải kết quả tìm kiếm."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No results found",
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
              ),
            );
          }

          final results = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Found ${results.length} results",
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    // Tái sử dụng widget card từ HomeScreen
                    // Bạn cần làm cho _buildProductCard có thể truy cập được từ bên ngoài
                    // Hoặc copy/paste nó vào đây
                    return ProductCardWidget(item: results[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}