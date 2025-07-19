import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartsplitclient/Split/Model/receipt_image.dart';

class ReceiptImageRepository {

  Future<bool> uploadReceiptImage(ReceiptImage image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final mountainsRef = storageRef.child("receipts/${image.id}.jpg");
    try {
      await mountainsRef.putFile(image.imageFile);
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getImageDownloadURL(String imageId) async{
    final storageRef = FirebaseStorage.instance.ref();
    final mountainsRef = storageRef.child("receipts/$imageId.jpg");
    try {
      String downloadUrl = await mountainsRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    } 
  }

}