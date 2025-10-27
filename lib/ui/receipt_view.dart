import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ramadhan_companion_app/widgets/custom_status_badge.dart';

class ReceiptView extends StatelessWidget {
  final Map<String, dynamic> receipt;

  const ReceiptView({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final client = receipt["client"] ?? {};
    final purchase = receipt["purchase"] ?? {};
    final payment = receipt["payment"] ?? {};

    final createdOn = receipt['created_on'] != null
        ? DateTime.fromMillisecondsSinceEpoch(receipt['created_on'] * 1000)
        : null;

    final paidOn = payment['paid_on'] != null
        ? DateTime.fromMillisecondsSinceEpoch(payment['paid_on'] * 1000)
        : null;

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 🧾 Receipt card with torn bottom
                      ClipPath(
                        clipper: TornPaperClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.receipt_long_rounded,
                                        size: 48,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "PAYMENT RECEIPT",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      StatusBadge(
                                        status: receipt['status'] ?? '',
                                      ),

                                      // Text(
                                      //   (receipt['status'] ?? 'Unknown')
                                      //       .toString()
                                      //       .toUpperCase(),
                                      //   style: TextStyle(
                                      //     color: Colors.green.shade700,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Amount
                                Center(
                                  child: Text(
                                    '${purchase['currency'] ?? 'MYR'} ${purchase['total'] != null ? (purchase['total'] / 100).toStringAsFixed(2) : '-'}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: Text(
                                    paidOn != null
                                        ? "Paid on ${dateFormat.format(paidOn)}"
                                        : "Pending payment",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                const Divider(thickness: 1),

                                _buildRow(
                                  "Payer Email",
                                  client['email'] ?? '-',
                                ),
                                _buildRow(
                                  "Transaction ID",
                                  "${receipt['id'] ?? '-'}",
                                ),
                                _buildRow(
                                  "Created On",
                                  createdOn != null
                                      ? dateFormat.format(createdOn)
                                      : '-',
                                ),
                                const Divider(thickness: 1),

                                const Text(
                                  "Products",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...(purchase['products'] as List? ?? []).map(
                                  (p) => _buildRow(
                                    p['name'],
                                    "x${p['quantity']} @ ${(p['price'] / 100).toStringAsFixed(2)} ${purchase['currency']}",
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    "Thank you for your contribution!",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // subtle torn edge shadow for realism
                      Positioned(
                        bottom: -2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          const Text(
            "Receipt",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🪚 Zigzag / Torn paper clipper
class TornPaperClipper extends CustomClipper<Path> {
  final double zigzagHeight;
  final double zigzagWidth;

  TornPaperClipper({this.zigzagHeight = 10, this.zigzagWidth = 14});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Top rounded
    path.moveTo(0, 0);
    path.lineTo(0, size.height - zigzagHeight);

    // Zigzag bottom
    double x = 0;
    bool isUp = true;

    while (x < size.width) {
      path.lineTo(
        x + zigzagWidth / 2,
        isUp ? size.height : size.height - zigzagHeight,
      );
      isUp = !isUp;
      x += zigzagWidth / 2;
    }

    path.lineTo(size.width, size.height - zigzagHeight);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
