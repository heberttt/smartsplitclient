import 'dart:convert';

import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Split/Model/receipt_item.dart';

class DataTransformService {
  Future<Receipt?> transformData(List<String> recTexts) async {
    final url = Uri.parse(BackendUrl.DATA_TRANSFORM_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type' : 'application/json'},
      body: jsonEncode({
        'rec_texts' : recTexts
      })
    );

    if (response.statusCode == 200){
      print(response.body);

      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> receiptData = data['data'];

      List<ReceiptItem> receiptItems = [];

      for (int i = 0; i < receiptData['items'].length; i++){
        receiptItems.add(ReceiptItem(itemName: receiptData['items'][i], totalPrice: ((receiptData['prices'][i] * 100).floor() * receiptData['quantity'][i]), quantity: receiptData['quantity'][i]));
      }

      Receipt receipt = Receipt(title: receiptData['title'], receiptItems: receiptItems, additionalChargesPercent: receiptData['additionalChargesPercent'] , roundingAdjustment: (receiptData['roundingAdjustment'] * 100).floor());
      
      return receipt;
    }else{
      return null;
    }
  }
}