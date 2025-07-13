import 'package:flutter/material.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class NonGroupFriendBar extends StatelessWidget {
  const NonGroupFriendBar(
    this.friends,
    this.currentUser, {
    required this.onRemove,
    super.key,
  });

  final List<Friend> friends;
  final Account currentUser;
  final void Function(Friend) onRemove;

  Widget constructProfile(BuildContext context, Friend friend) {
    String displayName = () {
      String name = friend.getName();
      if (name.length > 10) return "${name.substring(0, 7)}...";
      return name;
    }();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: friend.getProfilePicture(10),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(displayName, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),
          if ((friend is RegisteredFriend && friend.id != currentUser.id) ||
              (friend is! RegisteredFriend))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    onRemove(friend);
                  },
                  child: const Icon(Icons.close, size: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles =
        friends.map((friend) => constructProfile(context, friend)).toList();

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            width: 100,
            height: 90,
            decoration: const BoxDecoration(color: Colors.white),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: profiles),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
