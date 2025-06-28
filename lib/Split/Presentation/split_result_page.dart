import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/friend_split.dart';
import 'package:smartsplit/Split/Model/receipt.dart';
import 'package:intl/intl.dart';
import 'package:smartsplit/Split/Model/receipt_item.dart';

class SplitResultPage extends StatefulWidget {
  const SplitResultPage(this.receipt, {super.key});

  final Receipt receipt;

  @override
  State<SplitResultPage> createState() => _SplitResultPageState();
}

class _SplitResultPageState extends State<SplitResultPage> {
  Map<Friend, List<Map<ReceiptItem, int>>> splits = {};
  List<Friend> splitKeys = [];
  int overallTotal = 0;

  @override
  void initState() {
    super.initState();
    _generateSplits(widget.receipt);
    splitKeys = splits.keys.toList();
  }

  List<Widget> _getAllSplits(List<Friend> friend){
    List<Widget> splitPerPerson = [];

    for (Friend f in friend) {
      splitPerPerson.add(_constructSplit(f));
    }

    return splitPerPerson;

  }

  Widget _constructSplit(Friend f) {
    int total = 0;

    List<Map<ReceiptItem, int>> receiptItemMapList = splits[f]!;
    List<Map<String, String>> purchasedItemsDataMap = [];
    for (Map<ReceiptItem, int> receiptItemMap in receiptItemMapList) {
      List<ReceiptItem> receiptItemMapKeys = receiptItemMap.keys.toList();
      for (var receiptItemMapKey in receiptItemMapKeys) {
        if (receiptItemMap[receiptItemMapKey]! > 0){
          purchasedItemsDataMap.add({
          'itemName': receiptItemMapKey.itemName,
          'quantity': receiptItemMap[receiptItemMapKey].toString(),
          'totalPrice':
              ((receiptItemMapKey.totalPrice / receiptItemMapKey.quantity) * receiptItemMap[receiptItemMapKey]! / 100)
                  .toString(),
        });
        }
        total +=
            (receiptItemMap[receiptItemMapKey]! *
            receiptItemMapKey.totalPrice /
            receiptItemMapKey.quantity).floor();
      }
    }

    int tax = total;

    total = total + (total * widget.receipt.additionalChargesPercent / 100).floor();

    tax = total - tax;

    overallTotal += total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 15, 15, 15),
                    child: Container(
                      width: 80,
                      height: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: f.getProfilePicture(10),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${f.getName()}'s total"),
                          Text("RM ${(total / 100)}", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            for (Map<String, String> itemMap in purchasedItemsDataMap)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 15
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: Text(itemMap["itemName"]!)),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "x${itemMap["quantity"]!}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "RM${(itemMap["totalPrice"]!)}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 15),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text("Extra charges")),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${widget.receipt.additionalChargesPercent}%",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "RM${tax / 100}",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  void _generateSplits(Receipt receipt) {
    List<Friend> friends = [];

    for (List<FriendSplit> friendSplitsPerItem in receipt.friendSplits) {
      for (FriendSplit friendSplit in friendSplitsPerItem) {
        if (!friends.contains(friendSplit.friend)) {
          friends.add(friendSplit.friend);
        }
      }
    }

    for (Friend f in friends) {
      List<Map<ReceiptItem, int>> splitPerFriend = [];
      for (int i = 0; i < receipt.receiptItems.length; i++) {
        for (int j = 0; j < receipt.friendSplits[i].length; j++) {
          if (receipt.friendSplits[i][j].friend == f) {
            splitPerFriend.add({
              receipt.receiptItems[i]: receipt.friendSplits[i][j].quantity,
            });
            break;
          }
        }
        splits.addAll({f: splitPerFriend});
      }
    }
  }

  Widget _getTransparentButton(IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Icon(
          icon,
          size: 35,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    overallTotal = 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).primaryColor,
          leading: _getTransparentButton(Icons.arrow_back, () {
            Navigator.pop(context);
          }),
          actions: [
            _getTransparentButton(Icons.close, () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.receipt.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(widget.receipt.now),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Column(
                  children: _getAllSplits(splitKeys),
                ),
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Overall total",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                        
                      ),
                      Text("RM ${(overallTotal + widget.receipt.roundingAdjustment) / 100}")
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rounding adjustment",
                      style: TextStyle(
                        fontSize: 12
                      ),
                        
                      ),
                      Text((widget.receipt.roundingAdjustment > 0 ? "+" : "") + widget.receipt.roundingAdjustment.toStringAsFixed(2))
                    ],
                  ),
                )
                ,SizedBox(height: 80,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
