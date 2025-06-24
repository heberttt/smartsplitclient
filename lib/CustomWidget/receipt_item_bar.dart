import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/friend_split.dart';
import 'package:smartsplit/Split/Model/receipt_item.dart';

class ReceiptItemBar extends StatefulWidget {
  const ReceiptItemBar(this.item, this.splits, this.selectedFriend,{super.key});

  final ReceiptItem item;

  final Friend? selectedFriend;

  final List<FriendSplit> splits;

  @override
  State<ReceiptItemBar> createState() => _ReceiptItemBarState();
}

class _ReceiptItemBarState extends State<ReceiptItemBar> {
  bool selected = false;
  int selectedAmount = 0;

  final double profilePaddingDistance = 17;

 @override
  void initState() {
    super.initState();
    
  }

  int _getAmountLeft(List<FriendSplit> splits, int totalItems){
    int totalQuantityPicked = 0;
    for (FriendSplit split in splits){
      totalQuantityPicked += split.quantity;
    }
    return totalItems - totalQuantityPicked;
  }


  Future<int?> _popUpValue(int maxValue, BuildContext context) async {
  final controller = TextEditingController();
  InputDecoration decoration = InputDecoration(hintText: '0 - $maxValue');

  return await showDialog<int>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Enter quantity'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: decoration,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final input = int.tryParse(controller.text);
                if (input != null && input >= 0 && input <= maxValue) {
                  Navigator.of(context).pop(input);
                } else {
                  setState(() {
                    controller.text = "";
                    decoration = InputDecoration(
                      hintText: "Please enter a number between 0 and $maxValue",
                      hintStyle: TextStyle(color: Colors.red,
                        fontSize: 10
                      ),
                    );
                  });
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _constructProfile(Friend friend, int index) {
    return Padding(
      padding: EdgeInsets.only(left: (profilePaddingDistance * index)),
      child: Container(
        width: 30,
        height: 30,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: friend.getProfilePicture(10),
      ),
    );
  }

  Widget _getAllProfile() {
    List<Widget> profiles = [];
    for (int i = 0; i < widget.splits.length; i++) {
      if (widget.splits[i].quantity > 0){
        profiles.add(_constructProfile(widget.splits[i].friend, i));
      }
    }
    return Stack(children: profiles);
  }

  @override
  Widget build(BuildContext context) {
    for (FriendSplit friendSplit in widget.splits){
      if (friendSplit.friend == widget.selectedFriend){
        setState(() {
          selectedAmount = friendSplit.quantity;
        });
        break;
      }
      if(friendSplit == widget.splits.last){
        selectedAmount = 0;
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 3,
          ),
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.item.itemName),
                Checkbox(
                  value: selected,
                  onChanged: (bool? value) {
                    setState(() {
                      
                        for (FriendSplit friendSplit in widget.splits){
                          if (friendSplit.friend == widget.selectedFriend){
                            if (selected){
                              friendSplit.quantity = 0;
                            }else{
                              friendSplit.quantity = 1;
                            }
                          }
                        }

                      selected = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Items left: ${_getAmountLeft(widget.splits, widget.item.quantity)}",
                  style: TextStyle(fontSize: 10),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      int? value = await _popUpValue(_getAmountLeft(widget.splits, widget.item.quantity), context);
                      
                      if (value != null){
                        for (FriendSplit friendSplit in widget.splits){
                          if (friendSplit.friend == widget.selectedFriend){
                            setState(() {
                              friendSplit.quantity = value;
                              if (!selected || value > 0){
                                selected = true;
                              }
                            });
                          }
                        }
                      }
                    },
                    child: Text(
                      "Selected Qty: x$selectedAmount",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getAllProfile(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text("Total Price: RM${widget.item.totalPrice}"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
