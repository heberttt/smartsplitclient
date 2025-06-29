import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartsplit/Authentication/Presentation/login_page.dart';
import 'package:smartsplit/Split/Model/receipt.dart';
import 'package:smartsplit/Split/Presentation/choose_friend_page.dart';
import 'package:smartsplit/Split/Presentation/ocr_loading_screen.dart';
import 'package:smartsplit/Split/Presentation/split_result_page.dart';
import 'package:smartsplit/Theme/light_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  debugPrintGestureArenaDiagnostics = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    theme: LightTheme().theme,
    home: SafeArea(
      child: ExperimentRoom(),
    ),
  ));
}

class ExperimentRoom extends StatelessWidget {
  const ExperimentRoom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
              }, child: Text(
                "test"
              )),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChooseFriendPage()),
                );
              }, child: Text(
                "split"
              ),),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OcrLoadingScreen(File(""))),
                );
              }, child: Text(
                "split"
              ),),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SplitResultPage(Receipt())),
                );
              }, child: Text(
                "split page result"
              ),),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }, child: Text(
                "login page"
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
