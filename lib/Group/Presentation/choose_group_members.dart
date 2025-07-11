import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/CustomWidget/member_bar.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/Service/group_service.dart';
import 'package:smartsplitclient/Group/State/group_state.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class ChooseGroupMemberPage extends StatefulWidget {
  const ChooseGroupMemberPage({super.key});

  @override
  State<ChooseGroupMemberPage> createState() => _ChooseGroupMemberPageState();
}

class _ChooseGroupMemberPageState extends State<ChooseGroupMemberPage> {
  final TextEditingController _groupNameController = TextEditingController(
    text: "Untitled Group",
  );

  final GroupService _groupService = GroupService();

  final List<RegisteredFriend> _selectedFriends = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Widget _buildFriendListItem(
    RegisteredFriend registeredFriend,
    bool isSelected,
  ) {
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
            child: registeredFriend.getProfilePicture(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registeredFriend.username,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  registeredFriend.email,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          isSelected
              ? const Icon(Icons.check, color: Colors.grey)
              : IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  setState(() {
                    _selectedFriends.add(registeredFriend);
                  });
                },
              ),
        ],
      ),
    );
  }

  Widget _getFriendSelections(FriendState friendState) {
    if (friendState.isLoadingFriends && friendState.myFriends.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredFriends =
        friendState.myFriends.where((friend) {
          final username = friend.username.toLowerCase();
          final email = friend.email.toLowerCase();
          return username.contains(_searchQuery) ||
              email.contains(_searchQuery);
        }).toList();

    return ListView.builder(
      itemCount: filteredFriends.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        final isSelected = _selectedFriends.any((f) => f.id == friend.id);

        return _buildFriendListItem(friend, isSelected);
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                const Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthState>().currentUser!;
    _selectedFriends.add(
      RegisteredFriend(
        authUser.id,
        authUser.email,
        authUser.username,
        authUser.profilePictureLink,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendState>().getMyFriends();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  // Future<void> showTextInputDialog(BuildContext context) async {
  //   TextEditingController controller = TextEditingController();

  //   return showDialog<void>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Enter guest name'),
  //           content: TextField(
  //             controller: controller,
  //             decoration: InputDecoration(hintText: "Type something..."),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 setState(() {
  //                   _selectedFriends.add(GuestFriend(controller.text));
  //                 });
  //                 Navigator.pop(context, controller.text);
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ), // for spacing below button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Group name"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _groupNameController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(10, 30, 0, 19),
                          child: Text(
                            "Choose members",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Friends"),
                        ),
                        MemberBar(
                          _selectedFriends,
                          context.read<AuthState>().currentUser!,
                          onRemove: (friend) {
                            setState(() {
                              _selectedFriends.removeWhere(
                                (f) => f.id == friend.id,
                              );
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
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _getFriendSelections(friendState),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        showLoadingDialog(context);

                        final isSuccess = await _groupService.createGroup(
                          _groupNameController.text,
                          _selectedFriends
                              .where(
                                (f) =>
                                    f.id !=
                                    context.read<AuthState>().currentUser!.id,
                              )
                              .map((f) => f.id)
                              .toList(),
                        );

                        if (isSuccess) {
                          await context.read<GroupState>().getMyGroups();
                        }

                        Navigator.pop(context);
                        Navigator.pop(context);
                      } catch (e) {
                        Navigator.pop(context);
                        showWarningDialog(e.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Group',
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
