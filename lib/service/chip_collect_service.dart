import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/secrets/api_keys.dart';

class ChipCollectService {
  static const String baseUrl = "https://gate.chip-in.asia/api/v1/purchases/";
  static const String brandId = "ac6a3abd-8619-475b-a6a5-257cbc34c9de";

  final bool useSandbox;

  ChipCollectService({this.useSandbox = false});

  Future<Map<String, dynamic>> createPurchase({
    required String clientEmail,
    required String productName,
    required int price,
  }) async {
    final apiKey = useSandbox
        ? ApiKeys.chipTestKey 
        : ApiKeys.chipLiveKey; 

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
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
