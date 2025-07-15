import 'package:flutter/material.dart';

// Enum để định nghĩa các loại hiệu ứng
enum PageTransitionType { fade, scale, slide }

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final PageTransitionType type;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.type = PageTransitionType.fade, // Mặc định là Fade
    this.duration = const Duration(milliseconds: 400), // Thời gian chuyển cảnh
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           switch (type) {
             case PageTransitionType.scale:
               // Hiệu ứng Phóng to kết hợp Mờ dần
               return ScaleTransition(
                 scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                   CurvedAnimation(
                     parent: animation,
                     curve: Curves.fastOutSlowIn,
                   ),
                 ),
                 child: FadeTransition(opacity: animation, child: child),
               );

             case PageTransitionType.slide:
               // Hiệu ứng Trượt từ phải sang trái
               const begin = Offset(1.0, 0.0);
               const end = Offset.zero;
               const curve = Curves.easeInOut;
               var tween = Tween(
                 begin: begin,
                 end: end,
               ).chain(CurveTween(curve: curve));
               return SlideTransition(
                 position: animation.drive(tween),
                 child: child,
               );

             case PageTransitionType.fade:
               // Hiệu ứng Mờ dần
               return FadeTransition(opacity: animation, child: child);
           }
         },
       );
}
