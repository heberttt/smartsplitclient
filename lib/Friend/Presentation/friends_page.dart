import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Friend/Model/friend_request.dart';
import 'package:smartsplitclient/Friend/Service/friend_service.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedTab = 0;
  final TextEditingController _emailController = TextEditingController();
  final FriendService _friendService = FriendService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest(String email) async {
    try {
      final bool success = await _friendService.sendFriendRequest(email);

      if (success) {
        showSuccessDialog("Friend request sent to $email");
      } else {
        showSuccessDialog("Friend request failed");
      }
    } catch (e) {
      showWarningDialog("Friend request failed. Error: ${e.toString()}");
    }
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

  Widget _constructFriend(RegisteredFriend registeredFriend) {
    final friendState = Provider.of<FriendState>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text(
                          'Are you sure you want to delete ${registeredFriend.username}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final success = await friendState.removeFriend(
                                registeredFriend.id,
                              );
                              if (!success) {
                                showWarningDialog("Remove friend failed");
                              } else {
                                showSuccessDialog(
                                  "${registeredFriend.username} is removed",
                                );
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  // const PopupMenuItem<String>(
                  //   value: 'edit',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.edit, size: 18),
                  //       SizedBox(width: 8),
                  //       Text('Edit'),
                  //     ],
                  //   ),
                  // ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _constructFriendRequest(FriendRequest request) {
    final friendState = Provider.of<FriendState>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            foregroundImage: NetworkImage(request.profilePictureLink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.username, style: const TextStyle(fontSize: 16)),
                Text(
                  request.email,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Accept Friend Request'),
                          content: Text(
                            'Accept friend request from ${request.username}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                final bool success = await friendState
                                    .acceptFriendRequest(request.requestId);

                                if (success) {
                                  showSuccessDialog(
                                    "${request.username} is added as friend",
                                  );

                                  friendState.getMyFriendRequests();
                                  friendState.getMyFriends();
                                } else {
                                  showWarningDialog("Failed to add as friend");
                                }
                              },
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Reject Friend Request'),
                          content: Text(
                            'Reject friend request from ${request.username}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                print('Rejected ${request.username}');
                                final bool success = await friendState
                                    .rejectFriendRequest(request.requestId);

                                if (success) {
                                  showSuccessDialog(
                                    "${request.username}'s friend request is rejected",
                                  );

                                  friendState.getMyFriendRequests();
                                  friendState.getMyFriends();
                                } else {
                                  showWarningDialog(
                                    "Failed to reject friend request",
                                  );
                                }
                              },
                              child: const Text(
                                'Reject',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendState = Provider.of<FriendState>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            centerTitle: true,
            title: const Text("Friends", style: TextStyle(color: Colors.black)),
          ),
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ToggleButtons(
                        constraints: const BoxConstraints(minWidth: 100),
                        borderRadius: BorderRadius.circular(8),
                        isSelected: [
                          _selectedTab == 0,
                          _selectedTab == 1,
                          _selectedTab == 2,
                        ],
                        fillColor: Theme.of(context).focusColor,
                        onPressed:
                            (index) => setState(() => _selectedTab = index),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              "My friends",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              "Friend request",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              "Send request",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedTab == 2)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Enter friend's email",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final email = _emailController.text.trim();
                              if (email.isNotEmpty) {
                                print("Sending friend request to $email");

                                await _sendRequest(email);

                                _emailController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid email'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send),
                            label: const Text("Send Friend Request"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_selectedTab == 0 && friendState.isLoadingFriends) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (_selectedTab == 1 &&
                          friendState.isLoadingFriendRequests) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          if (_selectedTab == 0) {
                            await friendState.getMyFriends();
                          } else {
                            await friendState.getMyFriendRequests();
                          }
                        },
                        child: Builder(
                          builder: (context) {
                            final isEmpty =
                                _selectedTab == 0
                                    ? friendState.myFriends.isEmpty
                                    : friendState.myFriendRequests.isEmpty;

                            if (isEmpty) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 80.0),
                                    child: Center(
                                      child: Text(
                                        _selectedTab == 0
                                            ? "You have no friends yet."
                                            : "No incoming friend requests.",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  _selectedTab == 0
                                      ? friendState.myFriends.length
                                      : friendState.myFriendRequests.length,
                              itemBuilder: (context, index) {
                                if (_selectedTab == 0) {
                                  return _constructFriend(
                                    friendState.myFriends[index],
                                  );
                                } else {
                                  return _constructFriendRequest(
                                    friendState.myFriendRequests[index],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
