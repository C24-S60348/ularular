import 'package:flutter/material.dart';

/// Creates a positioned back button at top left
/// [onTap] - Optional custom onTap handler. If null, uses Navigator.pop(context)
Widget buildBackButton(BuildContext context, {VoidCallback? onTap}) {
  return Positioned(
    top: 20,
    left: 20,
    child: GestureDetector(
      onTap: onTap ?? () {
        Navigator.pop(context);
      },
      child: Image.asset(
        'assets/images/back button.png',
        height: 70,
        fit: BoxFit.contain,
      ),
    ),
  );
}

/// Creates a slide transition route to navigate to a new page
/// [page] - The page widget to navigate to
/// [direction] - The slide direction (default: left to right)
Route createSlideRoute(Widget page, {SlideDirection direction = SlideDirection.leftToRight}) {
  Offset beginOffset;
  
  switch (direction) {
    case SlideDirection.leftToRight:
      beginOffset = const Offset(1.0, 0.0);  // New page starts from right
      break;
    case SlideDirection.rightToLeft:
      beginOffset = const Offset(-1.0, 0.0); // New page starts from left
      break;
    case SlideDirection.topToBottom:
      beginOffset = const Offset(0.0, -1.0); // New page starts from top
      break;
    case SlideDirection.bottomToTop:
      beginOffset = const Offset(0.0, 1.0);  // New page starts from bottom
      break;
  }
  
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;
      
      var slideTween = Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
  );
}

enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}
