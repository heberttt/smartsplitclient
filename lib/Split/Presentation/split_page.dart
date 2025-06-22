import 'package:flutter/material.dart';
import 'package:smartsplit/CustomWidget/friend_bar.dart';
import 'package:smartsplit/CustomWidget/receipt_item_bar.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/friend_split.dart';
import 'package:smartsplit/Split/Model/guest_friend.dart';
import 'package:smartsplit/Split/Model/receipt_item.dart';

class SplitPage extends StatefulWidget {
  const SplitPage(this.selectedFriends, {super.key});

  final List<Friend> selectedFriends;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  final TextEditingController _titleController = TextEditingController(
    text: "Untitled Split",
  );

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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
          body: Stack(
            children: [
              ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 0, 10),
                        child: Text("Title"),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 70,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _titleController,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 0, 10),
                        child: Text("Friend"),
                      ),
                      FriendBar(widget.selectedFriends),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Items"),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: Icon(Icons.add_a_photo, size: 25),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: Icon(Icons.add, size: 25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [ReceiptItemBar(ReceiptItem(itemName: "Instant noodle"), [FriendSplit(GuestFriend("ggg"), 1),FriendSplit(GuestFriend("ggg"), 1),FriendSplit(GuestFriend("ggg"), 1),FriendSplit(GuestFriend("ggg"), 1)]),ReceiptItemBar(ReceiptItem(itemName: "Instant noodle"), [FriendSplit(GuestFriend("ggg"), 1)]),ReceiptItemBar(ReceiptItem(itemName: "Instant noodle"), [FriendSplit(GuestFriend("ggg"), 1)]),ReceiptItemBar(ReceiptItem(itemName: "Instant noodle"), [FriendSplit(GuestFriend("ggg"), 1)]),ReceiptItemBar(ReceiptItem(itemName: "Instant noodle"), [FriendSplit(GuestFriend("ggg"), 1)])],
                      )
                    ],),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
