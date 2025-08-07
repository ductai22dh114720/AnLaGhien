import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/features/authentication/screen/splash_screen.dart';
import 'package:flutter_dapm/shared/provider/cart_provider.dart';
import 'package:flutter_dapm/shared/provider/wallet_provider.dart';
import 'package:flutter_dapm/shared/provider/user_provider.dart';

// KHÔNG cần async và GetStorage.init() nữa
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Thêm các provider khác ở đây nếu cần
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
