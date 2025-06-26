import 'package:smartsplit/Split/Model/friend_split.dart';
import 'package:smartsplit/Split/Model/receipt_item.dart';

class Receipt {
  String title = "Untitled Split";
  List<ReceiptItem> receiptItems;
  List<FriendSplit> friendSplits;
  double additionalChargesPercent;
  double roundingAdjustment;
  DateTime now = DateTime.now();

  Receipt({
    String? title,
    List<ReceiptItem>? receiptItems,
    List<FriendSplit>? friendSplits,
    this.additionalChargesPercent = 0,
    this.roundingAdjustment = 0,
  })  : title = title ?? "Untitled Split",
        receiptItems = receiptItems ?? [],
        friendSplits = friendSplits ?? [];

  @override
String toString() {
  return 'Receipt{\n'
      '  title: $title,\n'
      '  receiptItems: $receiptItems,\n'
      '  friendSplits: $friendSplits,\n'
      '  additionalChargesPercent: $additionalChargesPercent,\n'
      '  roundingAdjustment: $roundingAdjustment\n'
      '}';
}


}