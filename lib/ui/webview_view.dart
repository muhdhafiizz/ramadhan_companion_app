import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ramadhan_companion_app/helper/distance_calculation.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              _buildAppBar(context, title),
              SizedBox(height: 10),
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(formatUrl(url))),
                ),
              ),
            ],
          ),
        ),
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
          child: Icon(Icons.arrow_back),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ],
    ),
  );
}
