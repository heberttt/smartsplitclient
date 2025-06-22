class ReceiptItem {
  String itemName;
  double price;
  int quantity;

  ReceiptItem({
    required this.itemName,
    this.price = 0,
    this.quantity = 1,
  });
}