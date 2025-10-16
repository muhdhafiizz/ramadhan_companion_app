import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'online':
      case 'success':
        return Colors.green;
      case 'pending to pay':
      case 'waiting':
      case 'offline':
        return Colors.blue;
      case 'paid':
      case 'completed':
        return AppColors.violet.withOpacity(1);
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'expired':
        return Colors.pink;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return "✓ Approved";
      case 'pending to pay':
      case 'waiting':
        return 'Proceed to pay';
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'rejected':
      case 'failed':
        return "Rejected";
      case 'expired':
        return "Expired";
      case 'online':
        return "• Online";
      case 'offline':
        return "Offline";
      default:
        return "Pending";
    }
  }

  bool _hasBorder() {
    final s = status.toLowerCase();
    return s == 'online' || s == 'offline';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        border: _hasBorder()
            ? Border.all(color: _getColor(), width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: _getColor(),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
