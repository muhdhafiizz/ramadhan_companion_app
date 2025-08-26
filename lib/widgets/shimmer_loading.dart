import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  final double? width;
  final double height;
  final bool isCircle;

  const ShimmerLoadingWidget({
    super.key,
    this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(4),
        ),
      ),
    );
  }
}
