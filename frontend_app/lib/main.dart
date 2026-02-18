import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/features/authentication/screen/splash_screen.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';
import 'package:flutter_dapm/shared/provider/user_provider.dart';

// SỬA LỖI TẠI ĐÂY
Future<void> main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. (TÙY CHỌN) Nếu bạn có bất kỳ quá trình khởi tạo nào cần thời gian (như GetStorage, Firebase, v.v.)
  // hãy thực hiện chúng ở đây. Ví dụ:
  // await GetStorage.init();
  // await Firebase.initializeApp();

  // 3. Chạy ứng dụng
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
