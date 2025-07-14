import 'dart:io';

class PaymentImage {
  late String billId;
  late String userId;
  late File? imageFile;
  
  PaymentImage(this.billId, this.userId, this.imageFile);
}