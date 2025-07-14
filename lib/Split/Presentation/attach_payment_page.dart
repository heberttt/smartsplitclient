import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Expense/Service/split_service.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/payment_image.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:smartsplitclient/Split/Service/payment_service.dart';

class AttachPaymentPage extends StatefulWidget {
  const AttachPaymentPage(this.splitBill, {super.key});
  final SplitBill splitBill;

  @override
  State<AttachPaymentPage> createState() => _AttachPaymentPageState();
}

class _AttachPaymentPageState extends State<AttachPaymentPage> {
  File? _imageFile;
  final PaymentService _paymentService = PaymentService();
  final SplitService _splitService = SplitService();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _approvePayment() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Payment"),
      content: const Text("Are you sure you want to submit this payment proof?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
      ],
    ),
  );

  if (confirm != true) return;

  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final currentUser = context.read<AuthState>().currentUser;
  final success = await _paymentService.approvePayment(
    widget.splitBill.id.toString(),
    PaymentImage(
      widget.splitBill.id.toString(),
      currentUser!.id,
      _imageFile,
    ),
  );

  Navigator.pop(context);
  if (success) {
    final updatedBill = await _splitService.getDebtByBillId(
      widget.splitBill.id.toString(),
      context.read<FriendState>().myFriends,
      context.read<AuthState>().currentUser,
    );

    if (updatedBill == null){
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to submit payment')),
    );
  }
}



  Widget _buildPaymentOptionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthState>().currentUser?.id;
    final myDebt = widget.splitBill.members
        .where((m) => m.friend is RegisteredFriend && (m.friend as RegisteredFriend).id == currentUserId)
        .fold<int>(0, (sum, m) => sum + m.totalDebt);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Attach Payment", style: TextStyle(color: Colors.white)),
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
                child: Center(
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 8.0),
                            Text(
                              'No payment proof attached',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        )
                      : Image.file(_imageFile!, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Go to', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    _buildPaymentOptionChip('TNG'),
                    const SizedBox(width: 10),
                    _buildPaymentOptionChip('MAE'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('RM${(myDebt / 100).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isUploading ? null : _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("Choose Image", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isUploading ? null : _approvePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("I have paid the bill", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
