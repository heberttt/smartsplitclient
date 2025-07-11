import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Converter/account_converter.dart';
import 'package:smartsplitclient/Authentication/Presentation/login_page.dart';
import 'package:smartsplitclient/Authentication/Service/account_service.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:smartsplitclient/Home/Presentation/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user != null) {
          return FutureBuilder(
            future: _initializeUser(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text("Failed to sign in: ${snapshot.error}")),
                );
              }

              return const HomePage();
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<void> _initializeUser(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await AccountService().login();

    if (response == null || response.statusCode != 200) {
      throw Exception("Login failed: ${response?.body}");
    }

    final account = AccountConverter().convertFromResponse(response);

    context.read<AuthState>().updateUser(account);
    await context.read<FriendState>().getMyFriends();
    await context.read<GroupState>().getMyGroups();
  }
}