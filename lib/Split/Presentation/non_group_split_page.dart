import 'package:flutter/material.dart';
import 'package:smartsplitclient/CustomWidget/receipt_item_bar.dart';
import 'package:smartsplitclient/CustomWidget/selectable_friend_bar.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/friend_split.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';
import 'package:smartsplitclient/Split/Presentation/manual_add_item_page.dart';
import 'package:smartsplitclient/Split/Presentation/ocr_camera_page.dart';
import 'package:smartsplitclient/Split/Presentation/non_group_split_result_page.dart';

class SplitPage extends StatefulWidget {
  const SplitPage(this.selectedFriends, {this.group, super.key});

  final Group? group;
  final List<Friend> selectedFriends;

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  final TextEditingController _titleController = TextEditingController(
    text: "Untitled Split",
  );

  Receipt receipt = Receipt();

  Friend? selectedFriend;

  List<List<FriendSplit>> friendSplits = [];

  List<ReceiptItemBar> _receiptItemBars = [];

  Future<int?> _popUpExtraChargesValue(BuildContext context) async {
    final controller = TextEditingController();
    InputDecoration decoration = InputDecoration(hintText: 'Enter tax %');

    return await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text('Enter Tax'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: decoration,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final input = int.tryParse(controller.text);
                      if (input != null && input >= 0) {
                        Navigator.of(context).pop(input);
                      } else {
                        setState(() {
                          controller.text = "";
                          decoration = InputDecoration(
                            hintText: "Tax must be more than 0%",
                            hintStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
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

  Future<double?> _popUpRoundingAdjustmentsValue(BuildContext context) async {
    final controller = TextEditingController();
    InputDecoration decoration = InputDecoration(hintText: '0.10');

    return await showDialog<double>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text('Enter rounding adjustment'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: decoration,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      final input = double.tryParse(controller.text);
                      if (input != null && input >= 0) {
                        Navigator.of(context).pop(input);
                      } else {
                        setState(() {
                          controller.text = "";
                          decoration = InputDecoration(
                            hintText: "Rounding adjustment must be >= 0",
                            hintStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
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

  Future<void> _addWithCamera() async {
    final Receipt? result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => OcrCameraPage()));

    if (result != null) {
      receipt.title = result.title;
      _titleController.text = receipt.title;
      receipt.additionalChargesPercent = result.additionalChargesPercent;
      receipt.roundingAdjustment = result.roundingAdjustment;
      for (ReceiptItem receiptItem in result.receiptItems) {
        _addReceiptItemBar(receiptItem);
      }
    }
  }

  Future<void> _addNewItem() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ManualAddItemPage()));

    if (result != null) {
      _addReceiptItemBar(result);
    }
  }

  void _addReceiptItemBar(ReceiptItem item) {
    List<FriendSplit> friendSplit = [];
    for (Friend f in widget.selectedFriends) {
      friendSplit.add(FriendSplit(f, 0));
    }

    receipt.receiptItems.add(item);
    friendSplits.add(friendSplit);
    setState(() {
      _receiptItemBars.add(
        ReceiptItemBar(
          item,
          friendSplit,
          selectedFriend,
          () => _removeReceiptItemBar(item),
        ),
      );
    });
  }

  void _removeReceiptItemBar(ReceiptItem item) {
    for (int i = 0; i < receipt.receiptItems.length; i++) {
      if (item == receipt.receiptItems[i]) {
        receipt.receiptItems.removeAt(i);
        friendSplits.removeAt(i);
      }
    }
  }

  void _constructReceiptItemBars() {
    List<ReceiptItemBar> itemBars = [];
    for (int i = 0; i < receipt.receiptItems.length; i++) {
      itemBars.add(
        ReceiptItemBar(
          receipt.receiptItems[i],
          friendSplits[i],
          selectedFriend,
          () => _removeReceiptItemBar(receipt.receiptItems[i]),
        ),
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

  void _showBackConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Discard changes?"),
          content: const Text(
            "Are you sure you want to go back? Your current progress will be lost.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showBackCloseConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Discard changes?"),
          content: const Text(
            "Are you sure you want to go back? Your current progress will be lost.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
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
              _showBackConfirmationDialog(context);
            }),
            actions: [
              _getTransparentButton(Icons.close, () {
                _showBackCloseConfirmationDialog(context);
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
                      Column(children: _receiptItemBars),
                      Container(
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tax & Extra Charges"),
                                  GestureDetector(
                                    onTap: () async {
                                      final int? percent =
                                          await _popUpExtraChargesValue(
                                            context,
                                          );

                                      if (percent != null) {
                                        setState(() {
                                          receipt.additionalChargesPercent =
                                            percent;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "${receipt.additionalChargesPercent}%",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Rounding adjustments"),
                                  GestureDetector(
                                    onTap: () async {
                                      final double? roundingAdjustment =
                                          await _popUpRoundingAdjustmentsValue(
                                            context,
                                          );

                                      if (roundingAdjustment != null) {
                                        receipt.roundingAdjustment =
                                            (roundingAdjustment * 100).round();
                                      }
                                    },
                                    child: Text(
                                      "RM ${receipt.roundingAdjustment / 100}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 70),
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
                        if (receipt.receiptItems.isEmpty) {
                          showWarningDialog("Please enter at least 1 item");
                          return;
                        }

                        receipt.title = _titleController.text;
                        receipt.friendSplits = friendSplits;

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => SplitResultPage(group: widget.group, receipt),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
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
