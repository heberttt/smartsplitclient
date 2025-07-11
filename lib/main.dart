import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartsplitclient/Authentication/Presentation/login_page.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Friend/Presentation/friends_page.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/Presentation/group_page.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:smartsplitclient/Home/Presentation/homepage.dart';
import 'package:smartsplitclient/Split/Model/receipt.dart';
import 'package:smartsplitclient/Split/Presentation/choose_friend_page.dart';
import 'package:smartsplitclient/Split/Presentation/ocr_loading_screen.dart';
import 'package:smartsplitclient/Split/Presentation/split_result_page.dart';
import 'package:smartsplitclient/Theme/light_theme.dart';
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
        ChangeNotifierProvider(
          create: (context) => FriendState()..getMyFriends(),
        ),
        ChangeNotifierProvider(
          create: (context) => GroupState()..getMyGroups(),
        )
      ],
      child: MaterialApp(
        theme: LightTheme().theme,
        home: const SafeArea(child: ExperimentRoom()),
      ),
    ),
  );
}

class ExperimentRoom extends StatelessWidget {
  const ExperimentRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {}, child: Text("test")),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChooseFriendPage(),
                    ),
                  );
                },
                child: Text("split"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OcrLoadingScreen(File("")),
                    ),
                  );
                },
                child: Text("split"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SplitResultPage(Receipt()),
                    ),
                  );
                },
                child: Text("split page result"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text("login page"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: Text("homepage"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FriendsPage()),
                  );
                },
                child: Text("friends"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GroupPage()),
                  );
                },
                child: Text("groups"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
