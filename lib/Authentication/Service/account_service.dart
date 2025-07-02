import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:http/http.dart' as http;

class AccountService{
  Future<http.Response?> login() async{
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse('${BackendUrl.ACCOUNT_SERVICE_URL}/login'),
      headers: {
        'Authorization' : 'Bearer $idToken',
        'Content-Type' : 'application/json'
      },
    );

    return response;
  }

  Future<http.Response?> changeUsername(String username) async{
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.put(
      Uri.parse("${BackendUrl.ACCOUNT_SERVICE_URL}/username"),
      headers: {
        'Authorization' : 'Bearer $idToken',
        'Content-Type' : 'application/json'
      },
      body: jsonEncode({
        'username' : username
      })
    );

    return response;
  }

  Future<String?> uploadProfilePictureToFirebase(File image) async{
    try {
      String filePath = "profiles/${FirebaseAuth.instance.currentUser!.uid}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      
      await storageRef.putFile(image);

      final downloadUrl = await storageRef.getDownloadURL();
      print("Image uploaded. Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<http.Response?> changeProfilePicture(String profilePictureLink) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.put(
      Uri.parse("${BackendUrl.ACCOUNT_SERVICE_URL}/profilePictureLink"),
      headers: {
        'Authorization' : 'Bearer $idToken',
        'Content-Type' : 'application/json'
      },
      body: jsonEncode({
        'profilePictureLink' : profilePictureLink
      })
    );

    return response;
  }


}