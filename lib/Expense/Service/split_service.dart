import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Split/Model/friend_split.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class SplitService {
  Future<bool> saveSplit(Receipt receipt) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);
    final payload = {
      "receipt": {
        "name": receipt.title,
        "additionalChargesPercent": receipt.additionalChargesPercent,
        "roundingAdjustment": receipt.roundingAdjustment,
        "now": DateTime.now().toIso8601String(),
        "splits": List.generate(receipt.receiptItems.length, (i) {
          final ReceiptItem item = receipt.receiptItems[i];
          final List<FriendSplit> splits = receipt.friendSplits[i];

          return {
            "itemName": item.itemName,
            "totalPrice": item.totalPrice,
            "quantity": item.quantity,
            "friendSplits":
                splits.map((fs) {
                  final friend = fs.friend;
                  return {
                    "friend": {
                      "id": friend is RegisteredFriend ? friend.id : null,
                      "username": friend is GuestFriend ? friend.getName() : null,
                    },
                    "quantity": fs.quantity,
                  };
                }).toList(),
          };
        }),
      },
    };


    final response = await http.post(
      Uri.parse(BackendUrl.SPLIT_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }

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
