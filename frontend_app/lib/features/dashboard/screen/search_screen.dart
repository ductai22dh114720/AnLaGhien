// lib/features/dashboard/screen/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dapm/shared/models/menu_item_model.dart';
import 'package:flutter_dapm/shared/services/product_service.dart';
import 'package:flutter_dapm/shared/widgets/product_card_widget.dart';
import 'package:google_fonts/google_fonts.dart';

// Các trạng thái của màn hình tìm kiếm
enum SearchState { initial, suggestions, loading, results }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  SearchState _currentState = SearchState.initial;
  List<String> _suggestions = [];
  List<MenuItemModel> _results = [];
  String _lastSubmittedQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nội dung ô tìm kiếm thay đổi
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isNotEmpty) {
        final newSuggestions = await _productService.getSearchSuggestions(query);
        if (mounted) {
          setState(() {
            _suggestions = newSuggestions;
            _currentState = SearchState.suggestions;
          });
        }
      } else {
        setState(() {
          _currentState = SearchState.initial;
        });
      }
    });
  }

  // Hàm xử lý khi người dùng nhấn Tìm kiếm
  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _lastSubmittedQuery = query.trim();
      _currentState = SearchState.loading;
    });

    _productService.searchMenuItems(_lastSubmittedQuery).then((results) {
      if (mounted) {
        setState(() {
          _results = results;
          _currentState = SearchState.results;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // Thanh tìm kiếm tùy chỉnh
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động focus khi mở màn hình
          onChanged: _onSearchChanged,
          onSubmitted: _submitSearch,
          decoration: InputDecoration(
            hintText: "Tìm kiếm món ăn...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          ),
        ),
        // Nút tìm kiếm
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.deepOrange),
              onPressed: () => _submitSearch(_searchController.text),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case SearchState.initial:
        return _buildInitialView();
      case SearchState.suggestions:
        return _buildSuggestionsView();
      case SearchState.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchState.results:
        return _buildResultsView();
    }
  }

  // Giao diện ban đầu (Ảnh 1)
  Widget _buildInitialView() {
    // TODO: Lấy lịch sử tìm kiếm từ local storage
    List<String> searchHistory = ['Bún'];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (searchHistory.isNotEmpty)
          _buildSectionTitle("Lịch sử tìm kiếm", showClear: true),
        Wrap(
          spacing: 8.0,
          children: searchHistory.map((term) => Chip(label: Text(term))).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Gợi ý tìm kiếm", showClear: false),
        // TODO: Hiển thị GridView gợi ý các món ăn nổi bật
      ],
    );
  }

  // Giao diện gợi ý real-time (Ảnh 2)
  Widget _buildSuggestionsView() {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(_suggestions[index]),
          onTap: () {
            _searchController.text = _suggestions[index];
            _submitSearch(_suggestions[index]);
          },
        );
      },
    );
  }

  // Giao diện kết quả cuối cùng (Ảnh 3)
  Widget _buildResultsView() {
    if (_results.isEmpty) {
      return Center(child: Text("Không tìm thấy kết quả cho '$_lastSubmittedQuery'"));
    }
    // Tái sử dụng giao diện từ thiết kế cũ của bạn
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            "Found ${_results.length} results",
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 30, crossAxisSpacing: 20, childAspectRatio: 0.65,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return ProductCardWidget(item: _results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool showClear = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (showClear) TextButton(onPressed: () {}, child: const Text("Xóa")),
      ],
    );
  }
}