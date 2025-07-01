import 'package:firebase_auth/firebase_auth.dart';
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
}