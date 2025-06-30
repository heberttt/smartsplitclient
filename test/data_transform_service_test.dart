import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';
import 'package:test/test.dart';

void main() {
  test('Receipt should be initialized successfully', () {
    final Map<String, dynamic> jsonMap = {
      "success": true,
      "statusCode": 200,
      "errorMessage": null,
      "data": {
        "title": "\"Tax Invoice\"",
        "items": [
          "ZIN BGR CMB EE",
          "PEPSI REGEE",
          "1LTD SETEHSEE",
        ],
        "prices": [11.15, 12.75, 25.0],
        "quantity": [2, 1, 1],
        "additionalChargesPercent": 0,
        "roundingAdjustment": 0.0,
      },
    };

    final Map<String, dynamic> receiptData = jsonMap['data'];
    List<ReceiptItem> receiptItems = [];

    for (int i = 0; i < receiptData['items'].length; i++) {
      receiptItems.add(
        ReceiptItem(
          itemName: receiptData['items'][i],
          totalPrice:
              ((receiptData['prices'][i] * 100).floor() *
                  receiptData['quantity'][i]),
          quantity: receiptData['quantity'][i],
        ),
      );
    }

    Receipt receipt = Receipt(
      title: receiptData['title'],
      receiptItems: receiptItems,
      additionalChargesPercent: receiptData['additionalChargesPercent'],
      roundingAdjustment: (receiptData['roundingAdjustment'] * 100).floor(),
    );
  });
}
