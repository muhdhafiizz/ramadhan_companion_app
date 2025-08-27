import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

/// A reusable zoom transition route that starts from a tap position
PageRouteBuilder<T> zoomPageRouteFromTap<T>({
  required Widget page,
  required Offset tapPosition,
}) {
  // Convert the global tap position into alignment (-1.0 to 1.0 range)
  final alignment = Alignment(
    (tapPosition.dx / WidgetsBinding.instance.window.physicalSize.width) * 2 - 1,
    (tapPosition.dy / WidgetsBinding.instance.window.physicalSize.height) * 2 - 1,
  );

  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return ScaleTransition(
        scale: curvedAnimation,
        alignment: alignment, // 👈 Start scaling from where tapped
        child: child,
      );
    },
  );
}
