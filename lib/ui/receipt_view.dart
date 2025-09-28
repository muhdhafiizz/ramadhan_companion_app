import 'package:flutter/material.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAppBar(context),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    /// Status & Amount
                    Align(
                      alignment: Alignment.bottomRight,
                      child: StatusBadge(status: receipt['status'] ?? ''),
                    ),
                    Text(
                      '${purchase['currency'] ?? 'MYR'} ${purchase['total'] != null ? (purchase['total'] / 100).toStringAsFixed(2) : '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text("${paidOn ?? '-'}"),
                    const SizedBox(height: 20),

                    /// Key-Value Info
                    ReceiptRow(
                      label: "Transaction ID",
                      value: "${receipt['id']}",
                      bold: true,
                    ),
                    ReceiptRow(
                      label: "Created On",
                      value: createdOn?.toString() ?? '-',
                    ),
                    ReceiptRow(
                      label: "Issued",
                      value: "${receipt['issued'] ?? '-'}",
                    ),

                    const Divider(),

                    ReceiptRow(
                      label: "Your Email",
                      value: client['email'] ?? '-',
                    ),

                    const Divider(),

                    /// Product(s)
                    const Text("Products:"),
                    ...(purchase['products'] as List? ?? []).map(
                      (p) => ReceiptRow(
                        label: p['name'],
                        value:
                            "x${p['quantity']} @ ${p['price']} ${purchase['currency']}",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back),
      ),
      SizedBox(width: 10),
      Text(
        "Receipt",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

class ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const ReceiptRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
