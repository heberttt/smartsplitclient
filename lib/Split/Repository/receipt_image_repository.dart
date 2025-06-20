import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartsplit/Split/Model/receipt_image.dart';

class ReceiptImageRepository {

  Future<bool> uploadReceiptImage(ReceiptImage image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final mountainsRef = storageRef.child("${image.id}.jpg");
    try {
      await mountainsRef.putFile(image.imageFile);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}