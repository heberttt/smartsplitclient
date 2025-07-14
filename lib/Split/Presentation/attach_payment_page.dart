import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Expense/Service/split_service.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Model/payment_image.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:smartsplitclient/Split/Service/payment_service.dart';

class AttachPaymentPage extends StatefulWidget {
  const AttachPaymentPage(this.splitBill, this.friend, {super.key});
  final SplitBill splitBill;

  final Friend friend;

  @override
  State<AttachPaymentPage> createState() => _AttachPaymentPageState();
}

class _AttachPaymentPageState extends State<AttachPaymentPage> {
  File? _imageFile;
  final PaymentService _paymentService = PaymentService();
  final SplitService _splitService = SplitService();
  bool _isUploading = false;

  bool _hasPaid = false;
  String? _paymentImageUrl;

  @override
  void initState() {
    super.initState();

    final friendPayment = widget.splitBill.members.firstWhere((m) {
      if (m.friend is RegisteredFriend && widget.friend is RegisteredFriend) {
        return (m.friend as RegisteredFriend).id ==
            (widget.friend as RegisteredFriend).id;
      } else if (m.friend is GuestFriend && widget.friend is GuestFriend) {
        return (m.friend as GuestFriend).name ==
            (widget.friend as GuestFriend).name;
      }
      return false;
    }, orElse: () => throw Exception("Current user not found in bill members"));

    _hasPaid = friendPayment.hasPaid;
    _paymentImageUrl = friendPayment.paymentImageLink;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _approvePayment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Payment"),
            content: const Text(
              "Are you sure you want to submit this payment proof?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirm"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final currentUser = context.read<AuthState>().currentUser;
    final success = await _paymentService.approvePayment(
      widget.splitBill.id.toString(),
      PaymentImage(widget.splitBill.id.toString(), currentUser!.id, _imageFile),
    );

    Navigator.pop(context);

    if (success) {
      final updatedBill = await _splitService.getDebtByBillId(
        widget.splitBill.id.toString(),
        context.read<AuthState>().currentUser,
      );

      if (updatedBill == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit payment')),
        );
        return;
      }

      Navigator.pop(context, updatedBill);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment submitted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit payment')));
    }
  }

  Widget _buildImageDisplay() {
    if (_hasPaid && _paymentImageUrl != null) {
      return Image.network(_paymentImageUrl!, fit: BoxFit.contain);
    } else if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.contain);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8.0),
          Text(
            'No payment proof attached',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      );
    }
  }

  // Widget _buildPaymentOptionChip(String platform) {
  //   Widget content;

  //   if (platform.toLowerCase() == 'mae') {
  //     content = Image.asset('assets/mae-logo.png', height: 24);
  //   } else if (platform.toLowerCase() == 'tng') {
  //     content = Image.asset('assets/tng-logo.png', height: 24);
  //   } else {
  //     content = Text(
  //       platform,
  //       style: const TextStyle(
  //         color: Colors.black,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     );
  //   }

  //   return GestureDetector(
  //     onTap: () async {
  //       print("$platform");
  //       if (platform == 'MAE') {
  //         await openAppByPackage("com.maybank2u.life");
  //       } else if (platform == 'TNG') {
  //         await openAppByPackage("com.tngdigital.ewallet");
  //       }
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20.0),
  //         border: Border.all(color: Colors.grey[400]!),
  //       ),
  //       child: content,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final myDebt = widget.splitBill.members
        .where((m) {
          if (m.friend is RegisteredFriend &&
              widget.friend is RegisteredFriend) {
            return (m.friend as RegisteredFriend).id ==
                (widget.friend as RegisteredFriend).id;
          } else if (m.friend is GuestFriend && widget.friend is GuestFriend) {
            return (m.friend as GuestFriend).name ==
                (widget.friend as GuestFriend).name;
          }
          return false;
        })
        .fold<int>(0, (sum, m) => sum + m.totalDebt);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Attach Payment",
          style: TextStyle(color: Colors.white),
        ),
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back, size: 35, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(child: _buildImageDisplay()),
              ),
            ),
            const SizedBox(height: 20),
            // _hasPaid
            //     ? SizedBox(height: 0)
            //     : Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         const Text(
            //           'Go to',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //         Row(
            //           children: [
            //             _buildPaymentOptionChip('TNG'),
            //             const SizedBox(width: 10),
            //             _buildPaymentOptionChip('MAE'),
            //           ],
            //         ),
            //       ],
            //     ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'RM${(myDebt / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            !_hasPaid
                ? ElevatedButton(
                  onPressed: (_hasPaid || _isUploading) ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Choose Image",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
                : SizedBox(height: 0),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (_hasPaid || _isUploading) ? null : _approvePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child:
                  _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        _hasPaid
                            ? "Payment already submitted"
                            : "I have paid the bill",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
