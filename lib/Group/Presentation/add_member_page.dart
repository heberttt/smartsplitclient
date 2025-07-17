import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:smartsplitclient/Group/Service/group_service.dart';

class AddMemberPage extends StatelessWidget {
  final Group group;

  const AddMemberPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final allFriends = context.watch<FriendState>().myFriends;

    final existingMemberIds = group.members.map((m) => m.id).toSet();
    final friends =
        allFriends.where((f) => !existingMemberIds.contains(f.id)).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Member',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                friends.isEmpty
                    ? const Center(child: Text("No friends available"))
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              friend.profilePictureLink,
                            ),
                          ),
                          title: Text(friend.username),
                          subtitle: Text(friend.email),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            final success = await GroupService().inviteToGroup(
                              group.id,
                              friend.id,
                            );

                            Navigator.pop(context);
                            Navigator.pop(context);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? '${friend.username} is added to the group'
                                        : 'Failed to add ${friend.username}',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
