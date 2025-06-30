import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:smartsplitclient/Split/Model/receipt_item.dart';

class ManualAddItemPage extends StatefulWidget {
  const ManualAddItemPage({super.key});

  @override
  State<ManualAddItemPage> createState() => _ManualAddItemPageState();
}

class _ManualAddItemPageState extends State<ManualAddItemPage> {
  int _currentValue = 1;

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  Widget _getTransparentButton(
    IconData icon,
    VoidCallback callback,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Theme.of(context).primaryColor,
            leading: _getTransparentButton(Icons.arrow_back, () {
              Navigator.pop(context);
            }, context),
            actions: [
              _getTransparentButton(Icons.close, () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }, context),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Item name"),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter item name',
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Price"),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter price (e.g., 12.50)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Quantity"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NumberPicker(
                      value: _currentValue,
                      minValue: 1,
                      maxValue: 100,
                      onChanged:
                          (value) => setState(() => _currentValue = value),
                      axis: Axis.horizontal,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Add Item",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final name = nameController.text;
                      final price = double.tryParse(priceController.text);
                      final quantity = _currentValue;

                      if (name.isEmpty || price == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter valid values.'),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(
                        context,
                        ReceiptItem(
                          itemName: name,
                          totalPrice: ((price * 100).floor()).toInt(),
                          quantity: quantity,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
