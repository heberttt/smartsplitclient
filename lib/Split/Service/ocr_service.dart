import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartsplit/Constants/backend_url.dart';

class OcrService {
   Future<Map<String, dynamic>?> extractData(String address) async {
    final url = Uri.parse(BackendUrl.OCR_SERVICE_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type' : 'application/json'},
      body: jsonEncode({'image_link' : address})
    );

    print(response.statusCode.toString() + "${response.body}");

    if (response.statusCode == 200){ //re check returned status code
      return jsonDecode(response.body);
    }

    return null;
  }
}