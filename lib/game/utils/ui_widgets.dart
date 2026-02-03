import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show document;

/// Game design dimensions
const double kGameWidth = 1000;
const double kGameHeight = 600;

/// Global fullscreen state manager
class FullscreenManager {
  static final FullscreenManager _instance = FullscreenManager._internal();
  factory FullscreenManager() => _instance;
  FullscreenManager._internal();

  final ValueNotifier<bool> isFullscreen = ValueNotifier<bool>(false);

  void toggleFullscreen() {
    if (kIsWeb) {
      _toggleWebFullscreen();
    } else {
      _toggleMobileFullscreen();
    }
  }

  void _toggleWebFullscreen() {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
      isFullscreen.value = false;
    } else {
      html.document.documentElement?.requestFullscreen();
      isFullscreen.value = true;
    }
  }

  void _toggleMobileFullscreen() {
    isFullscreen.value = !isFullscreen.value;

    if (isFullscreen.value) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}

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

        return Stack(
          children: [
            Center(
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
            ),
            // Fullscreen button
            Positioned(
              bottom: 20,
              right: 20,
              child: _FullscreenButton(),
            ),
          ],
        );
      },
    ),
  );
}

/// Fullscreen toggle button widget with global state and smooth appearance
class _FullscreenButton extends StatefulWidget {
  @override
  State<_FullscreenButton> createState() => _FullscreenButtonState();
}

class _FullscreenButtonState extends State<_FullscreenButton>
    with SingleTickerProviderStateMixin {
  final _fullscreenManager = FullscreenManager();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    // Start fade in after a tiny delay to make it smooth
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ValueListenableBuilder<bool>(
        valueListenable: _fullscreenManager.isFullscreen,
        builder: (context, isFullscreen, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _fullscreenManager.toggleFullscreen,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Creates a clickable image button with press feedback
/// [imagePath] - Path to the image asset
/// [onTap] - Callback when button is tapped
/// [height] - Height of the button (optional)
/// [width] - Width of the button (optional)
Widget buildClickableImageButton({
  required String imagePath,
  required VoidCallback onTap,
  double? height,
  double? width,
}) {
  return _ClickableImageButton(
    imagePath: imagePath,
    onTap: onTap,
    height: height,
    width: width,
  );
}

/// Clickable image button with press feedback
class _ClickableImageButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final double? height;
  final double? width;

  const _ClickableImageButton({
    required this.imagePath,
    required this.onTap,
    this.height,
    this.width,
  });

  @override
  State<_ClickableImageButton> createState() => _ClickableImageButtonState();
}

class _ClickableImageButtonState extends State<_ClickableImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _isPressed ? Colors.white.withOpacity(0.3) : Colors.transparent,
            BlendMode.srcATop,
          ),
          child: Image.asset(
            widget.imagePath,
            height: widget.height,
            width: widget.width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// Creates a positioned back button at top left
/// [onTap] - Optional custom onTap handler. If null, uses Navigator.pop(context)
Widget buildBackButton(BuildContext context, {VoidCallback? onTap}) {
  return Positioned(
    top: 20,
    left: 20,
    child: buildClickableImageButton(
      imagePath: 'assets/images/back button.png',
      onTap: onTap ?? () {
        Navigator.pop(context);
      },
      height: 70,
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
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    opaque: true,
    barrierDismissible: false,
  );
}

enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}
