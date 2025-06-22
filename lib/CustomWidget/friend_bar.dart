import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/guest_friend.dart';

class FriendBar extends StatefulWidget {
  const FriendBar(this.friends, {super.key});

  final List<Friend> friends;

  @override
  State<FriendBar> createState() => _FriendBarState();
}

class _FriendBarState extends State<FriendBar> {
  final Friend guest = GuestFriend("Hebert");

  Widget constructProfile(Friend friend) {
    String displayName = () {
      String name = friend.getName();
      if (name.length > 10) return "${name.substring(0, 7)}...";
      return name;
    }();

    return Padding(
      padding: EdgeInsetsGeometry.fromSTEB(10, 0, 10, 0),
      child: Column(
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
            padding: EdgeInsetsGeometry.fromLTRB(0, 2, 0, 0),
            child: Text(displayName, style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> allProfiles = () {
      List<Widget> profiles = [];

      for (Friend friend in widget.friends) {
        profiles.add(constructProfile(friend));
      }

      return profiles;
    }();

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(color: Colors.white),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,10,0,0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: allProfiles,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
