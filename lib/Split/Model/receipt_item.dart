class ReceiptItem {
  String itemName;
  int totalPrice;
  int quantity;

  ReceiptItem({
    required this.itemName,
    this.totalPrice = 0,
    this.quantity = 1,
  });

  @override
String toString() {
  return 'ReceiptItem(itemName: $itemName, totalPrice: $totalPrice, quantity: $quantity)';
}
}