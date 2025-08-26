import 'package:flutter/material.dart';

class CustomPillSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    
    final animationController = AnimationController(
      vsync: scaffold,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    animationController.forward();

    scaffold.showSnackBar(
      SnackBar(
        content: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        duration: duration + const Duration(milliseconds: 550),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.only(bottom: 20),
        width: 250, 
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(duration, () {
        if (animationController.status != AnimationStatus.dismissed) {
          animationController.reverse().then((_) {
            scaffold.hideCurrentSnackBar();
          });
        }
      });
    });
  }
}