import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Constants/backend_url.dart';

class OcrService {
   Future<Map<String, dynamic>?> extractData(String address) async {
    
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);
    final url = Uri.parse(BackendUrl.OCR_SERVICE_URL);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'image_link' : address})
    );

    print(response.statusCode.toString() + "${response.body}");

    if (response.statusCode == 200){
      return jsonDecode(response.body);
    }

    return null;
  }
}