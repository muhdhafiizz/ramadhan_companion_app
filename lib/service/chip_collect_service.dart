import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/secrets/api_keys.dart';

class ChipCollectService {
  static const String baseUrl = "https://gate.chip-in.asia/api/v1/purchases/";
  static const String brandId = "ac6a3abd-8619-475b-a6a5-257cbc34c9de";
  static const String apiKey =
      "q3pCV5rZLJ0g4x_hyNZydRU_uE5q-RSlQz626dmX9TRSa-5b6niGq7_FALPWdAz_7hccM_YTJYkrZO7-ZdSomQ==";

  final bool useDummy;

  ChipCollectService({this.useDummy = false});

  Future<Map<String, dynamic>> createPurchase({
    required String clientEmail,
    required String productName,
    required int price,
  }) async {
    if (useDummy) {
      // 🟣 Return fake data for testing
      await Future.delayed(
        const Duration(seconds: 1),
      ); // simulate network delay
      return {
        "code": 200,
        "status": "OK",
        "data": {
          "checkout_url": "https://sandbox.chip-in.asia/dummy-checkout",
          "purchase_id": "dummy12345",
          "client_email": clientEmail,
          "product": productName,
          "price": price,
        },
      };
    }

    // 🟢 Real API request
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer ${ApiKeys.chipPaymentGatewayKey}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "client": {"email": clientEmail},
        "purchase": {
          "currency": "MYR",
          "skip_capture": false,
          "products": [
            {"name": productName, "price": price},
          ],
        },
        "brand_id": brandId,
      }),
    );

    print("Chip API Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create purchase: ${response.body}");
    }
  }
}
