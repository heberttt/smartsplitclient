import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Split/Model/payment_image.dart';
import 'package:smartsplitclient/Split/Repository/payment_repository.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final PaymentRepository paymentRepository = PaymentRepository();

  Future<bool> approvePayment(String billId, PaymentImage paymentImage) async {
    String? downloadUrl;
    if (paymentImage.imageFile != null) {
      downloadUrl = await paymentRepository.uploadPaymentImage(
        paymentImage,
      );

      if (downloadUrl == null) {
        return false;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);
    final url = Uri.parse(BackendUrl.DEBT_SERVICE);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "billId": paymentImage.billId,
        "paymentLink": downloadUrl,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
