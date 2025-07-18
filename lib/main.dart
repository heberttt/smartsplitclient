import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:smartsplitclient/Split/State/split_state.dart';
import 'package:smartsplitclient/Theme/light_theme.dart';
import 'package:smartsplitclient/auth_gate.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  debugPrintGestureArenaDiagnostics = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => SplitState()),
        ChangeNotifierProvider(create: (context) => FriendState()..getMyFriends()),
        ChangeNotifierProvider(create: (context) => GroupState()..getMyGroups()),
      ],
      child: MaterialApp(
        theme: LightTheme().theme,
        home: SafeArea(
          child: const AuthGate(),
        ),
      ),
    ),
  );
}