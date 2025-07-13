import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartsplitclient/CustomWidget/friend_bar.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Presentation/non_group_split_page.dart';

class ChooseFriendPage extends StatefulWidget {
  const ChooseFriendPage({super.key});

  @override
  State<ChooseFriendPage> createState() => _ChooseFriendPageState();
}

class _ChooseFriendPageState extends State<ChooseFriendPage> {
  final List<Friend> _selectedFriends = [GuestFriend('You')];

  Widget _getTransparentButton(IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
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

  Future<void> showTextInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter guest name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Type something..."),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFriends.add(GuestFriend(controller.text));
                  });
                  Navigator.pop(context, controller.text);
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Theme.of(context).primaryColor,
            leading: _getTransparentButton(Icons.arrow_back, () {
              Navigator.pop(context);
            }),
          ),
          body: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 0, 19),
                    child: Text(
                      "Choose friends",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Friends"),
                  ),
                  FriendBar(_selectedFriends),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.9,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showTextInputDialog(context);
                            },
                            icon: Icon(
                              Icons.add,
                              size: 15,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Add guests',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.fontSize,
                                fontWeight:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.fontWeight,
                                fontStyle:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.fontStyle,
                                letterSpacing: 0.0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              splashFactory: InkRipple.splashFactory,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        // child: _getFriendSelections(),  add invite friends later // use ListView.builder for lazy building
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (_, _, _) => SplitPage(_selectedFriends),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
