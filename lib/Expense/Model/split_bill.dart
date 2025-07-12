import 'package:smartsplitclient/Expense/Model/friend_payment.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/friend_split.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class SplitBill {
  final String creatorId;
  final Receipt receipt;
  final List<FriendPayment> members;

  SplitBill({
    required this.creatorId,
    required this.receipt,
    required this.members,
  });

  factory SplitBill.fromJson(Map<String, dynamic> json) {
    final receiptJson = json['receipt'];
    final creatorId = json['creatorId'];
    final membersJson = json['members'];

    String title = receiptJson['name'] ?? "Untitled Split";
    int additionalCharges = receiptJson['additionalChargesPercent'] ?? 0;
    int rounding = receiptJson['roundingAdjustment'] ?? 0;
    DateTime now = DateTime.parse(receiptJson['now']);

    List<ReceiptItem> items = [];
    List<List<FriendSplit>> allFriendSplits = [];

    for (var item in receiptJson['splits']) {
      items.add(
        ReceiptItem(
          itemName: item['itemName'],
          totalPrice: item['totalPrice'],
          quantity: item['quantity'],
        ),
      );

      List<FriendSplit> splits = [];
      for (var fs in item['friendSplits']) {
        var f = fs['friend'];
        Friend friend;

        if (f['id'] != null) {
          friend = RegisteredFriend(f['id'], "", "", "");
        } else {
          friend = GuestFriend(f['username']);
        }

        splits.add(FriendSplit(friend, fs['quantity']));
      }

      allFriendSplits.add(splits);
    }

    Receipt receipt = Receipt(
      title: title,
      receiptItems: items,
      friendSplits: allFriendSplits,
      additionalChargesPercent: additionalCharges,
      roundingAdjustment: rounding,
    )..now = now;

    List<FriendPayment> members = [];
    for (var m in membersJson) {
      final f = m['friend'];
      Friend friend;

      if (f['id'] != null) {
        friend = RegisteredFriend(f['id'], "", "", "");
      } else {
        friend = GuestFriend(f['username']);
      }

      members.add(
        FriendPayment(
          friend: friend,
          totalDebt: m['totalDebt'],
          hasPaid: m['hasPaid'],
          paymentImageLink: m['paymentImageLink'],
          paidAt: m['paidAt'] != null ? DateTime.parse(m['paidAt']) : null,
        ),
      );
    }

    return SplitBill(creatorId: creatorId, receipt: receipt, members: members);
  }
}
