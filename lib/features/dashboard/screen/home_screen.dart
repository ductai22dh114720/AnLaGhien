// ignore: unused_import
import 'dart:async'; // Cần cho Timer
import 'package:flutter/material.dart';
import 'package:flutter_dapm/features/dashboard/screen/infor_screen.dart';
import 'package:flutter_dapm/features/dashboard/screen/order_screen.dart';
import 'package:flutter_dapm/shared/theme/app_styles.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

// Dữ liệu mẫu cho slider
final List<Map<String, String>> popularProducts = [
  {
    'image': 'assets/burger_gagion.jpg',
    'title': 'Burger Gà Giòn',
    'price': '25.000đ',
  },
  {
    'image': 'assets/burger_2gagion.jpg',
    'title': 'Burger 2 Gà Giòn',
    'price': '30.000đ',
  },
  {
    'image': 'assets/burger_2gagion.jpg',
    'title': 'Burger Đặc Biệt',
    'price': '35.000đ',
  },
  {
    'image': 'assets/burger_2gagion.jpg',
    'title': 'Burger Bò Phô Mai',
    'price': '40.000đ',
  },
];

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool burger = false;
  bool pizza = false;
  bool burrito = false;
  bool drink = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CẢI TIẾN 2: THAY ĐỔI MÀU NỀN TRANG
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('TRANG CHỦ'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.deepOrange[200],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepOrange),
                child: Center(
                  child: Text(
                    'L O G O',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Trang Chủ'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Trang Cá Nhân'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => Infor()));
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Trang Đặt Hàng'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => Order()));
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh Mục', style: WidgetSupport.HeadlineTextFeildStyle()),
              SizedBox(height: 20.0),
              _buildCategorySelector(),
              SizedBox(height: 30.0),

              // CẢI TIẾN 1: THAY THẾ BẰNG CAROUSEL SLIDER
              Text('Phổ biến', style: WidgetSupport.HeadlineTextFeildStyle()),
              SizedBox(height: 10.0),
              CarouselSlider.builder(
                itemCount: popularProducts.length,
                itemBuilder: (context, index, realIndex) {
                  final product = popularProducts[index];
                  return _buildHorizontalProductCard(
                    product['image']!,
                    product['title']!,
                    product['price']!,
                  );
                },
                options: CarouselOptions(
                  height: 220, // Chiều cao của slider
                  autoPlay: true, // Tự động chạy
                  enlargeCenterPage: true, // Phóng to item ở giữa
                  viewportFraction: 0.55, // Hiển thị một phần của item kế tiếp
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                ),
              ),
              SizedBox(height: 30.0),

              Text(
                'Gợi ý cho bạn',
                style: WidgetSupport.HeadlineTextFeildStyle(),
              ),
              SizedBox(height: 10.0),
              _buildVerticalProductCard(
                'assets/burger_2gagion.jpg',
                'Combo Burger Gà + Khoai',
                'Tiết kiệm hơn',
                '55.000đ',
              ),
              SizedBox(height: 15.0),
              _buildVerticalProductCard(
                'assets/burger_2gagion.jpg',
                'Combo Gia Đình',
                '2 Burger + 2 Nước',
                '99.000đ',
              ),
              SizedBox(height: 15.0),
              _buildVerticalProductCard(
                'assets/burger_2gagion.jpg',
                'Burger Tôm Hùm',
                'Hương vị cao cấp',
                '150.000đ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho các thẻ sản phẩm cuộn dọc (không thay đổi)
  Widget _buildVerticalProductCard(
    String imagePath,
    String title,
    String subtitle,
    String price,
  ) {
    return Material(
      color: Colors.white, // Đảm bảo thẻ luôn màu trắng
      elevation: 3.0, // Giảm độ nổi một chút cho tinh tế
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                imagePath,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Text(title, style: WidgetSupport.boldTextFeildStyle()),
                  SizedBox(height: 5.0),
                  Text(subtitle, style: WidgetSupport.LightTextFeildStyle()),
                  SizedBox(height: 10.0),
                  Text(price, style: WidgetSupport.boldTextFeildStyle()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho các thẻ sản phẩm cuộn ngang (trong slider)
  Widget _buildHorizontalProductCard(
    String imagePath,
    String title,
    String price,
  ) {
    return Container(
      // Bỏ margin ở đây vì CarouselSlider đã có khoảng cách
      child: Material(
        color: Colors.white, // Đảm bảo thẻ luôn màu trắng
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Sử dụng Expanded để ảnh lấp đầy không gian
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(title, style: WidgetSupport.boldTextFeildStyle()),
              SizedBox(height: 5.0),
              Text(price, style: WidgetSupport.boldTextFeildStyle()),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho việc chọn danh mục (không thay đổi)
  Widget _buildCategorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryIcon(
          () => setState(() {
            burger = true;
            pizza = false;
            drink = false;
            burrito = false;
          }),
          'assets/burger.png',
          burger,
        ),
        _buildCategoryIcon(
          () => setState(() {
            burger = false;
            pizza = false;
            drink = false;
            burrito = true;
          }),
          'assets/burrito.png',
          burrito,
        ),
        _buildCategoryIcon(
          () => setState(() {
            burger = false;
            pizza = true;
            drink = false;
            burrito = false;
          }),
          'assets/pizza.png',
          pizza,
        ),
        _buildCategoryIcon(
          () => setState(() {
            burger = false;
            pizza = false;
            drink = true;
            burrito = false;
          }),
          'assets/drink.png',
          drink,
        ),
      ],
    );
  }

  // Widget con cho một icon danh mục
  Widget _buildCategoryIcon(
    VoidCallback onTap,
    String imagePath,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 50,
            width: 50,
            fit: BoxFit.contain,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
