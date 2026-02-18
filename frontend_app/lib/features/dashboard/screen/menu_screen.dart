// lib/features/dashboard/screen/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dapm/shared/provider/user_provider.dart';
import 'package:flutter_dapm/shared/models/user_model.dart';

class MenuScreen extends StatelessWidget {
  final Function(int) onMenuItemTap;
  final int currentTabIndex;
  final VoidCallback onSignOut;

  const MenuScreen({
    super.key,
    required this.onMenuItemTap,
    required this.currentTabIndex,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE8581D);
    final UserModel? user = Provider.of<UserProvider>(context, listen: false).user;

    // Giảm padding ngang để các mục không bị quá sát lề
    const double horizontalPadding = 30.0;

    const Map<String, int> menuIndexMap = {
      'My Orders': 2,
      'My Profile': 3,
    };

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column( // Sử dụng Column làm gốc
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN HEADER ---
            Padding(
              // Điều chỉnh padding cho phù hợp
              padding: const EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 40),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null ? const Icon(Icons.person, size: 30) : null,
                  ),
                  const SizedBox(width: 16),
                  // Bọc trong Expanded để tránh tràn lề nếu tên/email quá dài
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- DANH SÁCH MENU ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      text: 'My Orders',
                      icon: Icons.shopping_bag_outlined,
                      isSelected: currentTabIndex == menuIndexMap['My Orders'],
                      onTap: () => onMenuItemTap(menuIndexMap['My Orders']!),
                    ),
                    _buildMenuItem(
                      text: 'My Profile',
                      icon: Icons.person_outline,
                      isSelected: currentTabIndex == menuIndexMap['My Profile'],
                      onTap: () => onMenuItemTap(menuIndexMap['My Profile']!),
                    ),
                    _buildMenuItem(text: 'Delivery Address', icon: Icons.location_on_outlined, isSelected: false, onTap: () {}),
                    _buildMenuItem(text: 'Payment Methods', icon: Icons.payment_outlined, isSelected: false, onTap: () {}),
                    _buildMenuItem(text: 'Contact Us', icon: Icons.call_outlined, isSelected: false, onTap: () {}),
                    _buildMenuItem(text: 'Help & FAQs', icon: Icons.help_outline, isSelected: false, onTap: () {}),
                    _buildMenuItem(text: 'Settings', icon: Icons.settings_outlined, isSelected: false, onTap: () {}),
                    const Spacer(),
                    const Divider(color: Colors.white54, thickness: 0.5),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      text: 'Log Out',
                      icon: Icons.logout,
                      isSignOut: true,
                      isSelected: false,
                      onTap: onSignOut,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm _buildMenuItem nằm trong class MenuScreen
  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}