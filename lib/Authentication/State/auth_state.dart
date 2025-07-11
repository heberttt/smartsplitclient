import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:provider/provider.dart';


class AuthState with ChangeNotifier {
  Account? currentUser;

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    currentUser = null;

    context.read<FriendState>().clear();
    context.read<GroupState>().clear();


    notifyListeners();
  }

  void updateUser(Account account) {
    currentUser = account;

    if (currentUser != null) {
      currentUser!.profilePictureLink =
          "${currentUser!.profilePictureLink}&t=${DateTime.now().millisecondsSinceEpoch}";
    }

    notifyListeners();
  }
}
