import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Presentation/login_page.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Home/Presentation/edit_profile_page.dart';
import 'package:smartsplitclient/main.dart';

class AccountOptionPage extends StatefulWidget {
  const AccountOptionPage({super.key});

  @override
  State<AccountOptionPage> createState() => _AccountOptionPageState();
}

class _AccountOptionPageState extends State<AccountOptionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
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
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                context.read<AuthState>().currentUser == null ? "Guest" : context.watch<AuthState>().currentUser!.username,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            _buildButton(
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            // _buildButton(
            //   icon: Icons.receipt_long,
            //   label: 'Billing History',
            //   onTap: () {
            //     // Navigate to billing screen
            //   },
            // ),
            // _buildButton(
            //   icon: Icons.settings,
            //   label: 'App Settings',
            //   onTap: () {
            //     // Navigator.of(context).push(
            //     //   PageRouteBuilder(
            //     //     pageBuilder: (_, _, _) => ExperimentRoom(),
            //     //     transitionDuration: Duration.zero,
            //     //     reverseTransitionDuration: Duration.zero,
            //     //   ),
            //     // );
            //   },
            // ),
            const Divider(height: 40),
            _buildButton(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () async {
                context.read<AuthState>().logout(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(label, style: TextStyle(color: color ?? Colors.black)),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
