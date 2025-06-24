import 'package:flutter/material.dart';
import 'package:smartsplit/CustomWidget/receipt_item_bar.dart';
import 'package:smartsplit/CustomWidget/selectable_friend_bar.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/friend_split.dart';
import 'package:smartsplit/Split/Model/receipt_item.dart';
import 'package:smartsplit/Split/Presentation/manual_add_item_page.dart';
import 'package:smartsplit/Split/Presentation/ocr_camera_page.dart';

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

  Friend? selectedFriend;

  List<List<FriendSplit>> friendSplits = [];

  List<ReceiptItem> receiptItems = [];

  List<ReceiptItemBar> _receiptItemBars = [];

  Future<void> _addWithCamera() async {
    final List<ReceiptItem>? result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => OcrCameraPage())
    );

    if (result != null && result.isNotEmpty){
      for (ReceiptItem receiptItem in result){
        _addReceiptItemBar(receiptItem);
      }
    }
  }

  Future<void> _addNewItem() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ManualAddItemPage()),
    );

    if (result != null){
      _addReceiptItemBar(result);
    }
  }

  void _addReceiptItemBar(ReceiptItem item) {
    List<FriendSplit> friendSplit = [];
    for (Friend f in widget.selectedFriends) {
      friendSplit.add(FriendSplit(f, 0));
    }

    receiptItems.add(item);
    friendSplits.add(friendSplit);
    setState(() {
      _receiptItemBars.add(ReceiptItemBar(item, friendSplit, selectedFriend));
    });
  }

  void _constructReceiptItemBars() {
    List<ReceiptItemBar> itemBars = [];
    for (int i = 0; i < receiptItems.length; i++) {
      itemBars.add(
        ReceiptItemBar(receiptItems[i], friendSplits[i], selectedFriend),
      );
    }
    setState(() {
      _receiptItemBars = itemBars;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedFriend =
        widget.selectedFriends.isNotEmpty ? widget.selectedFriends.first : null;
  }

  void _changeSelectedFriend(Friend friend) {
    setState(() {
      selectedFriend = friend;
    });
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
    _constructReceiptItemBars();
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
                      SelectableFriendBar(
                        widget.selectedFriends,
                        selectedFriend,
                        _changeSelectedFriend,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 30, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Items"),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _addWithCamera,
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
                                    onTap: _addNewItem,
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
                        children: _receiptItemBars,
                        // children: () {
                        //   List<FriendSplit> friendSplitsMock = [
                        //     FriendSplit(widget.selectedFriends.first, 1),
                        //     FriendSplit(widget.selectedFriends[1], 2),
                        //   ];
                        //   return receiptItemsMock = [
                        //     ReceiptItemBar(
                        //       ReceiptItem(
                        //         itemName: "burger",
                        //         quantity: 3,
                        //         totalPrice: 20,
                        //       ),
                        //       friendSplitsMock,
                        //       selectedFriend,
                        //     ),
                        //   ];
                        // }(),
                      ),
                    ],
                  ),
                  SizedBox(height: 70,)
                ],
              ),

              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Split',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
