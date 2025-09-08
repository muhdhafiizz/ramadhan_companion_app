import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return Colors.green;
      case 'pending to pay':
      case 'waiting':
        return Colors.blue;
      case 'paid':
      case 'completed':
        return AppColors.violet.withOpacity(1);
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return "Approved";
      case 'pending to pay':
      case 'waiting':
        return 'Procced to pay';
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'rejected':
      case 'failed':
        return "Rejected";
      case 'pending':
      default:
        return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        border: Border.all(color: _getColor()),
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
