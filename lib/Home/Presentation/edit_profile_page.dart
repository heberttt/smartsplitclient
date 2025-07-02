import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Converter/account_converter.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Authentication/Service/account_service.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  final AccountService _accountService = AccountService();
  final AccountConverter _accountConverter = AccountConverter();

  bool _isPressedChangeUsername = false;
  bool _isPressedChangePassword = false;

  bool isLinkedWithGoogle = false;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showWarningDialog("No user signed in");
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: context.read<AuthState>().currentUser!.email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      showWarningDialog("Old password is incorrect");
      print(e);
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        showSuccessDialog("Password has been successfully changed");
        print("Password updated successfully");
      } else {
        showWarningDialog("No user is currently signed in");
        print("No user is currently signed in.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showWarningDialog(
          "User must re-authenticate before changing the password.",
        );
        print("User must re-authenticate before changing the password.");
      } else {
        showWarningDialog("Error: ${e.message}");
        print("Error: ${e.message}");
      }
    } catch (e) {
      showWarningDialog("Unexpected error: $e");
      print("Unexpected error: $e");
    }
  }

  bool isGoogleConnected(User user) {
    return user.providerData.any((info) => info.providerId == 'google.com');
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

  Widget _getTransparentButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Icon(
          icon,
          size: 35,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
    );
  }

  Future<void> _connectGoogle() async {
    await GoogleSignIn().signOut();

    final googleUser = await GoogleSignIn().signIn();

    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google connected')));
        setState(() {
          isLinkedWithGoogle = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Already linked or error: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _usernameController.text = context.read<AuthState>().currentUser!.username;

    if (user != null && isGoogleConnected(user)) {
      isLinkedWithGoogle = true;
    } else {
      isLinkedWithGoogle = false;
    }
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

  void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Flexible(child: Text(message ?? "Loading...")),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).primaryColor,
          leading: _getTransparentButton(Icons.arrow_back),
          title: Text(
            "Edit Profile",
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );

                    if (image == null) {
                      showWarningDialog("No image selected");
                      return;
                    }

                    showLoadingDialog(context);

                    File file = File(image.path);

                    String? profilePictureLink = await _accountService
                        .uploadProfilePictureToFirebase(file);

                    if (profilePictureLink == null ||
                        profilePictureLink.isEmpty) {
                      Navigator.of(context).pop();
                      showWarningDialog("Uploading failed");
                      return;
                    }

                    final response = await _accountService.changeProfilePicture(
                      profilePictureLink,
                    );

                    if (response == null) {
                      showWarningDialog("Server can't be reached");
                      Navigator.of(context).pop();
                      return;
                    }

                    if (response.statusCode == 200) {
                      Account account = _accountConverter.convertFromResponse(
                        response,
                      );

                      context.read<AuthState>().updateUser(account);
                      Navigator.of(context).pop();
                      showSuccessDialog("Profile picture updated");
                    } else {
                      Navigator.of(context).pop();
                      showWarningDialog("Server error");
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              context
                                      .watch<AuthState>()
                                      .currentUser
                                      ?.profilePictureLink ??
                                  '',
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed:
                      _isPressedChangeUsername
                          ? null
                          : () async {
                            setState(() {
                              _isPressedChangeUsername = true;
                            });

                            final response = await _accountService
                                .changeUsername(_usernameController.text);

                            if (response == null) {
                              showWarningDialog("Server can't be reached");

                              setState(() {
                                _isPressedChangeUsername = false;
                              });

                              return;
                            }

                            if (response.statusCode == 200) {
                              Account account = _accountConverter
                                  .convertFromResponse(response);

                              context.read<AuthState>().updateUser(account);

                              showSuccessDialog(
                                "Username updated to ${account.username}",
                              );
                            } else if (response.statusCode == 400) {
                              showWarningDialog(
                                "Invalid username format. Please change your username",
                              );
                            } else {
                              showWarningDialog("Server error");
                            }

                            setState(() {
                              _isPressedChangeUsername = false;
                            });
                          },
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isPressedChangeUsername
                        ? 'Changing username...'
                        : 'Change Username',
                  ),
                ),
                const SizedBox(height: 32),

                isLinkedWithGoogle
                    ? SizedBox()
                    : TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                const SizedBox(height: 16),
                isLinkedWithGoogle
                    ? SizedBox()
                    : TextField(
                      obscureText: true,
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                const SizedBox(height: 16),
                isLinkedWithGoogle
                    ? SizedBox()
                    : TextField(
                      obscureText: true,
                      controller: _confirmNewPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                const SizedBox(height: 16),

                isLinkedWithGoogle
                    ? SizedBox()
                    : ElevatedButton.icon(
                      onPressed:
                          _isPressedChangePassword
                              ? null
                              : () async {
                                setState(() {
                                  _isPressedChangePassword = true;
                                });

                                if (_newPasswordController.text !=
                                    _confirmNewPasswordController.text) {
                                  showWarningDialog(
                                    "Old and new password are different",
                                  );
                                  setState(() {
                                    _isPressedChangePassword = false;
                                  });
                                  return;
                                }

                                if (_oldPasswordController.text.isEmpty ||
                                    _newPasswordController.text.isEmpty ||
                                    _confirmNewPasswordController
                                        .text
                                        .isEmpty) {
                                  showWarningDialog(
                                    "Please fill in the password details",
                                  );
                                  setState(() {
                                    _isPressedChangePassword = false;
                                  });
                                  return;
                                }

                                await changePassword(
                                  _oldPasswordController.text,
                                  _newPasswordController.text,
                                );

                                setState(() {
                                  _isPressedChangePassword = false;
                                });
                              },
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Change Password'),
                    ),
                const SizedBox(height: 32),

                // Connect to Google
                ElevatedButton.icon(
                  onPressed:
                      isLinkedWithGoogle
                          ? null
                          : () async {
                            await _connectGoogle();
                          },
                  icon: const Icon(Icons.link),
                  label: Text(
                    isLinkedWithGoogle
                        ? 'Connected To Google'
                        : 'Connect To Google Account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
