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

  Map<Friend, Map<ReceiptItem, int>> splits = {};

  // Widget _constructSplit(){

  // }

  void _generateSplits(Receipt receipt){
    // List<Friend> friends = [];
    // Map<Friend, List<Map<ReceiptItem, int>>> splits = {};

    // for (FriendSplit fs in receipt.friendSplits){
    //   if (!friends.contains(fs.friend)){
    //     friends.add(fs.friend);
    //   }
    // }

    // for (Friend f in friends){
      
    // }




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

                // _constructSplit()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
