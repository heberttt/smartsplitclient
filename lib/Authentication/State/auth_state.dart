import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';

class AuthState with ChangeNotifier{
  Account? currentUser;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    currentUser = null;

    notifyListeners();
  }

  
}