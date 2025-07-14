import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/CustomWidget/non_group_friend_bar.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:smartsplitclient/Split/Presentation/non_group_split_page.dart';

class NonGroupChooseFriendPage extends StatefulWidget {
  const NonGroupChooseFriendPage({super.key});

  @override
  State<NonGroupChooseFriendPage> createState() =>
      _NonGroupChooseFriendPageState();
}

class _NonGroupChooseFriendPageState extends State<NonGroupChooseFriendPage> {
  final List<Friend> _selectedFriends = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Widget _getTransparentButton(IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
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
    String? errorText;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter guest name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type something...",
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      setState(() {
                        errorText = "Name cannot be empty";
                      });
                      return;
                    }

                    if (_selectedFriends.any(
                      (f) =>
                          f is GuestFriend && f.name == controller.text.trim(),
                    )) {
                      setState(() {
                        errorText = "Guest with this name already exists";
                      });
                      return;
                    }

                    setState(() {
                      _selectedFriends.add(GuestFriend(controller.text.trim()));
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<FriendState>().getMyFriends();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    final currentUser = context.read<AuthState>().currentUser!;
    _selectedFriends.add(
      RegisteredFriend(
        currentUser.id,
        currentUser.email,
        currentUser.username,
        currentUser.profilePictureLink,
      ),
    );
  }

  Widget _buildFriendListItem(RegisteredFriend friend, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: friend.getProfilePicture(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(friend.username, style: const TextStyle(fontSize: 16)),
          ),
          isSelected
              ? const Icon(Icons.check, color: Colors.grey)
              : IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  setState(() {
                    _selectedFriends.add(friend);
                  });
                },
              ),
        ],
      ),
    );
  }

  Widget _getFriendSelections(FriendState friendState) {
    final filtered =
        friendState.myFriends.where((f) {
          return f.username.toLowerCase().contains(_searchQuery) ||
              f.email.toLowerCase().contains(_searchQuery);
        }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final friend = filtered[index];
        final isSelected = _selectedFriends.any(
          (f) => f is RegisteredFriend && f.id == friend.id,
        );
        return _buildFriendListItem(friend, isSelected);
      },
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
              Consumer<FriendState>(
                builder: (context, friendState, _) {
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 30, 0, 19),
                        child: Text(
                          "Choose friends",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Selected Friends"),
                      ),
                      NonGroupFriendBar(
                        _selectedFriends,
                        context.read<AuthState>().currentUser!,
                        onRemove: (friend) {
                          setState(() {
                            _selectedFriends.removeWhere((f) => f == friend);
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
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
                                onPressed: () => showTextInputDialog(context),
                                icon: const Icon(
                                  Icons.add,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add guest',
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Friend List"),
                      ),
                      _getFriendSelections(friendState),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => SplitPage(_selectedFriends),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
