import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return Colors.green;
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
        style: TextStyle(color: _getColor(), fontWeight: FontWeight.bold),
      ),
    );
  }
}
