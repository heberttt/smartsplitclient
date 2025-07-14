import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Expense/Model/friend_payment.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Friend/Service/friend_service.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/friend_split.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class SplitService {
  final FriendService _friendService = FriendService();

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
                      "username":
                          friend is GuestFriend ? friend.getName() : null,
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

  Future<SplitBill> enrichSplitBill(
    SplitBill bill,
    Account? currentUser,
    Map<String, RegisteredFriend> friendMap,
  ) async {
    Friend enrichFriend(Friend friend) {
      if (friend is RegisteredFriend) {
        if (currentUser != null && friend.id == currentUser.id) {
          return RegisteredFriend(
            currentUser.id,
            currentUser.email,
            currentUser.username,
            currentUser.profilePictureLink,
          );
        }

        final fetched = friendMap[friend.id];
        if (fetched != null) {
          return fetched;
        }
      }

      return friend;
    }

    for (int i = 0; i < bill.receipt.friendSplits.length; i++) {
      for (int j = 0; j < bill.receipt.friendSplits[i].length; j++) {
        final original = bill.receipt.friendSplits[i][j];
        bill.receipt.friendSplits[i][j] = FriendSplit(
          enrichFriend(original.friend),
          original.quantity,
        );
      }
    }

    for (int i = 0; i < bill.members.length; i++) {
      final original = bill.members[i];
      bill.members[i] = FriendPayment(
        friend: enrichFriend(original.friend),
        totalDebt: original.totalDebt,
        hasPaid: original.hasPaid,
        paymentImageLink: original.paymentImageLink,
        paidAt: original.paidAt,
      );
    }

    return bill;
  }

  Future<List<SplitBill>> getMySplitBills(Account? currentUser) async {
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
      final bills = data.map((e) => SplitBill.fromJson(e)).toList();

      final Set<String> accountIds = {};

      for (var bill in bills) {
        for (var member in bill.members) {
          if (member.friend is RegisteredFriend) {
            accountIds.add((member.friend as RegisteredFriend).id);
          }
        }
        for (var splits in bill.receipt.friendSplits) {
          for (var split in splits) {
            if (split.friend is RegisteredFriend) {
              accountIds.add((split.friend as RegisteredFriend).id);
            }
          }
        }
      }

      final fetchedFriends = await _friendService.getAccounts(
        accountIds.toList(),
      );
      final friendMap = {for (var f in fetchedFriends) f.id: f};

      final enriched = await Future.wait(
        bills.map((b) => enrichSplitBill(b, currentUser, friendMap)),
      );

      return enriched;
    } else {
      throw Exception('Failed to load split bills: ${response.statusCode}');
    }
  }

  Future<List<SplitBill>> getMyDebts(Account? currentUser) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(BackendUrl.DEBT_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final data = jsonMap['data'] as List;
      final bills = data.map((e) => SplitBill.fromJson(e)).toList();

      final Set<String> accountIds = {};
      for (var bill in bills) {
        for (var member in bill.members) {
          if (member.friend is RegisteredFriend) {
            accountIds.add((member.friend as RegisteredFriend).id);
          }
        }
        for (var splits in bill.receipt.friendSplits) {
          for (var split in splits) {
            if (split.friend is RegisteredFriend) {
              accountIds.add((split.friend as RegisteredFriend).id);
            }
          }
        }
      }

      final fetchedFriends = await _friendService.getAccounts(
        accountIds.toList(),
      );
      final friendMap = {for (var f in fetchedFriends) f.id: f};

      final enriched = await Future.wait(
        bills.map((b) => enrichSplitBill(b, currentUser, friendMap)),
      );

      return enriched;
    } else {
      throw Exception('Failed to load debts: ${response.statusCode}');
    }
  }

  Future<SplitBill?> getDebtByBillId(
    String billId,
    Account? currentUser,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(BackendUrl.DEBT_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final data = jsonMap['data'] as List;

      for (var billJson in data) {
        if (billJson['id'].toString() == billId) {
          final bill = SplitBill.fromJson(billJson);

          final Set<String> accountIds = {};
          for (var member in bill.members) {
            if (member.friend is RegisteredFriend) {
              accountIds.add((member.friend as RegisteredFriend).id);
            }
          }
          for (var splits in bill.receipt.friendSplits) {
            for (var split in splits) {
              if (split.friend is RegisteredFriend) {
                accountIds.add((split.friend as RegisteredFriend).id);
              }
            }
          }

          final fetchedFriends = await _friendService.getAccounts(
            accountIds.toList(),
          );
          final friendMap = {for (var f in fetchedFriends) f.id: f};

          return await enrichSplitBill(bill, currentUser, friendMap);
        }
      }

      return null;
    } else {
      throw Exception('Failed to load debt bills: ${response.statusCode}');
    }
  }
}
