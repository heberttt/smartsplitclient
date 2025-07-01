import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Converter/account_converter.dart';
import 'package:smartsplitclient/Authentication/Presentation/sign_up_page.dart';


import 'package:smartsplitclient/Authentication/Service/account_service.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Home/Presentation/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AccountService accountService = AccountService();
  final AccountConverter accountConverter = AccountConverter();

  String _loginButtonText = "Login";

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      showWarningDialog("Google Sign-In failed");
      print('Google Sign-In failed: $e');
      return null;
    }
  }

  Future<void> _loginWithGoogle() async {
    UserCredential? userCredential = await signInWithGoogle();

    if (userCredential != null) {

        final response = await accountService.login();

        if (response == null) {
          showWarningDialog("Server is unavailable. Please try again later...");
          context.read<AuthState>().logout();
          return;
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          //welcome back & newcomers
          context.read<AuthState>().currentUser = accountConverter.convertFromResponse(response);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (response.statusCode == 401) {
          showWarningDialog("Unauthorized");

          context.read<AuthState>().logout();
          return;
        } else {
          showWarningDialog("Server Error. Status code: ${response.statusCode}");

          context.read<AuthState>().logout();
          return;
        }
      // showSuccessDialog("Signed in successful. ${userCredential.user?.email}");

      // final String? result = await FirebaseAuth.instance.currentUser
      //     ?.getIdToken(true);

      // final RegExp pattern = RegExp(
      //   '.{1,800}',
      // ); // 800 is the size of each chunk
      // pattern
      //     .allMatches(result!)
      //     .forEach((RegExpMatch match) => print(match.group(0)));
    } else {
      showWarningDialog("Sign in failed.");
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showWarningDialog("Please fill up your account information");
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
        await GoogleSignIn().signOut();
        showWarningDialog('Email not verified. Please check your inbox.');
      }

      if (user != null && user.emailVerified) {
        final response = await accountService.login();

        if (response == null) {
          showWarningDialog("Server is unavailable. Please try again later...");
          context.read<AuthState>().logout();

          return;
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          //welcome back & newcomers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (response.statusCode == 401) {
          showWarningDialog("Unauthorized");

          context.read<AuthState>().logout();
          return;
        } else {
          showWarningDialog("Server Error");

          context.read<AuthState>().logout();
          return;
        }

        showSuccessDialog("Login successful");
        //final String? result = await FirebaseAuth.instance.currentUser?.getIdToken(true);

        // final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
        // pattern.allMatches(result!).forEach((RegExpMatch match) =>   print(match.group(0)));

        //add navigator to homepage
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showWarningDialog('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showWarningDialog('Wrong password provided for that user.');
      } else if (e.code == 'invalid-credential') {
        showWarningDialog('Wrong password provided.');
      } else {
        showWarningDialog('FirebaseAuthException: ${e.code} - ${e.message}');
      }
    } catch (e) {
      showWarningDialog('Unknown error: $e');
    }

    setState(() {
      _loginButtonText = "Login";
    });
  }

  void showSuccessDialog(String message) {
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

  void showWarningDialog(String message) {
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
                            showSuccessDialog(result);
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
