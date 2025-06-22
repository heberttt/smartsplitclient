import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartsplit/Split/Presentation/choose_friend_page.dart';
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
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
