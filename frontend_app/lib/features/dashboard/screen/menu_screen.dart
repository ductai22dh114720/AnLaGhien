// lib/features/dashboard/screen/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const Color primaryColor = Color(0xFFFA4A0C);

    const Map<String, int> menuIndexMap = {
      'Profile': 3,
      'Orders': 2,
      'Voucher': -1, // -1 cho các mục không có tab tương ứng
      'Privacy policy': -1,
      'Security': -1,
    };

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuItem(
                text: 'Profile', icon: Icons.person_outline,
                isSelected: currentTabIndex == menuIndexMap['Profile'],
                onTap: () => onMenuItemTap(menuIndexMap['Profile']!),
              ),
              _buildMenuItem(
                text: 'Orders', icon: Icons.shopping_cart_outlined,
                isSelected: currentTabIndex == menuIndexMap['Orders'],
                onTap: () => onMenuItemTap(menuIndexMap['Orders']!),
              ),
              _buildMenuItem(
                text: 'Voucher', icon: Icons.local_offer_outlined,
                isSelected: false, onTap: () {},
              ),
              const SizedBox(height: 50),
              const Divider(color: Colors.white54, thickness: 0.5),
              const SizedBox(height: 20),
              _buildMenuItem(
                text: 'Privacy policy', icon: Icons.receipt_long_outlined,
                isSelected: false, onTap: () {},
              ),
              _buildMenuItem(
                text: 'Security', icon: Icons.security_outlined,
                isSelected: false, onTap: () {},
              ),
              const Spacer(),
              _buildMenuItem(
                text: 'Sign-out', icon: Icons.arrow_forward,
                isSignOut: true, isSelected: false, onTap: onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Stack(
          clipBehavior: Clip.none, // Cho phép widget con tràn ra ngoài
          children: [
            // Hiệu ứng gạch chân (before)
            if (isSelected)
              Positioned(
                left: -25,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                  ),
                ),
              ),

            // Nội dung của mục menu
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 20),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: isSelected || isSignOut ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}