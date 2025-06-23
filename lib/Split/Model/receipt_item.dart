class ReceiptItem {
  String itemName;
  double totalPrice;
  int quantity;

  ReceiptItem({
    required this.itemName,
    this.totalPrice = 0,
    this.quantity = 1,
  });
}