import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/helper/distance_calculation.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/provider/webview_provider.dart';
import 'payment_results_view.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;
  final String? notificationDocId;
  final String? sadaqahId;

  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
    this.notificationDocId,
    this.sadaqahId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentWebViewProvider(),
      child: Consumer<PaymentWebViewProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, title),
                  const SizedBox(height: 10),
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(formatUrl(url)),
                      ),
                      onLoadStop: (controller, uri) async {
                        if (uri == null) return;
                        final currentUrl = uri.toString();
                        print("Redirected to: $currentUrl");

                        if (currentUrl.contains("/success/")) {
                          provider.setStatus("success");

                          if (notificationDocId != null) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(notificationDocId)
                                  .update({'paid': true});
                            } catch (e) {
                              debugPrint(
                                'Failed to update Firestore paid flag: $e',
                              );
                            }
                          }

                          final sadaqahProvider = context
                              .read<SadaqahProvider>();
                          await sadaqahProvider.paySadaqah(
                            sadaqahId!,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentResultsView(isSuccess: true),
                            ),
                          );
                        } else if (currentUrl.contains("/failure/")) {
                          provider.setStatus("failure");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentResultsView(isSuccess: false),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ],
    ),
  );
}
