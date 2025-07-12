import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:http/http.dart' as http;

class SplitService {
  Future<List<SplitBill>> getMySplitBills() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(BackendUrl.SPLIT_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);

      final data = jsonMap['data'] as List;
      return data.map((e) => SplitBill.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load split bills: ${response.statusCode}');
    }
  }
}
