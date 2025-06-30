import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartsplitclient/Authentication/Presentation/sign_up_page.dart';
import 'dart:developer';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  String _loginButtonText = "Login";

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();


      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In failed: $e');
      return null;
    }
  }

  Future<void> _loginWithGoogle() async {
    UserCredential? userCredential = await signInWithGoogle();

    if (userCredential != null) {
      showSuccessDialog(
        context,
        "Signed in successful. ${userCredential.user?.email}",
      );

      final String? result = await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(result!).forEach((RegExpMatch match) =>   print(match.group(0)));
    } else {
      showWarningDialog(context, "Sign in failed.");
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showWarningDialog(context, "Please fill up your account information");
    }

    setState(() {
      _loginButtonText = "Logging in....";
    });

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      User? user = credential.user;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        showWarningDialog(
          context,
          'Email not verified. Please check your inbox.',
        );
      }

      if (user != null && user.emailVerified) {
        showSuccessDialog(context, "Login successful");

        final String? result = await FirebaseAuth.instance.currentUser?.getIdToken(true);

        

        final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(result!).forEach((RegExpMatch match) =>   print(match.group(0)));


        //add navigator to homepage
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showWarningDialog(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showWarningDialog(context, 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-credential') {
        showWarningDialog(context, 'Wrong password provided.');
      } else {
        showWarningDialog(
          context,
          'FirebaseAuthException: ${e.code} - ${e.message}',
        );
      }
    } catch (e) {
      showWarningDialog(context, 'Unknown error: $e');
    }

    setState(() {
      _loginButtonText = "Login";
    });
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success', style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Color.fromRGBO(240, 231, 216, 1),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Image.asset('assets/logo.png', height: 150),
                  const SizedBox(height: 40),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await _login();
                      },
                      child: Text(_loginButtonText),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Or Connect With
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or connect with'),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign-In Button
                  GestureDetector(
                    onTap: () async {
                      await _loginWithGoogle();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/google-logo.png',
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () async {
                          final String? result = await Navigator.of(
                            context,
                          ).push(
                            PageRouteBuilder(
                              pageBuilder: (_, _, _) => SignUpPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );

                          if (result == null) {
                            return;
                          }
                          if (result ==
                              "Please verify your account in your email inbox") {
                            showSuccessDialog(context, result);
                          }
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
