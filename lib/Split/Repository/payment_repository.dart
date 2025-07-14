import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartsplitclient/Split/Model/payment_image.dart';

class PaymentRepository {
  Future<String?> uploadPaymentImage(PaymentImage image) async {
    try {
      String filePath = "payment/${image.billId}/${image.userId}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      
      await storageRef.putFile(image.imageFile!);

      final downloadUrl = await storageRef.getDownloadURL();
      print("Image uploaded. Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }
}