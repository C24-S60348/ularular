import 'package:flutter/material.dart';

/// Game design dimensions
const double kGameWidth = 1000;
const double kGameHeight = 600;

/// Wraps a page with responsive scaling and black padding
/// [child] - The page widget to wrap
Widget buildResponsiveGamePage({required Widget child}) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Calculate scale to fit the game in the screen
        final scaleX = screenWidth / kGameWidth;
        final scaleY = screenHeight / kGameHeight;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        // Calculate the actual size after scaling
        final scaledWidth = kGameWidth * scale;
        final scaledHeight = kGameHeight * scale;

        return Center(
          child: SizedBox(
            width: scaledWidth,
            height: scaledHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: kGameWidth,
                height: kGameHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    ),
  );
}

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
/// Automatically wraps the page with responsive scaling
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
  
  // Wrap the page with responsive scaling
  final wrappedPage = buildResponsiveGamePage(child: page);
  
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => wrappedPage,
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
