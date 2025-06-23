import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/friend.dart';
import 'package:smartsplit/Split/Model/guest_friend.dart';

class SelectableFriendBar extends StatefulWidget {
  const SelectableFriendBar(this.friends, this.selectedFriend, this.changeSelectedFriendCallback, {super.key});

  final Friend? selectedFriend;

  final Function(Friend) changeSelectedFriendCallback;

  final List<Friend> friends;

  @override
  State<SelectableFriendBar> createState() => _SelectableFriendBarState();
}

class _SelectableFriendBarState extends State<SelectableFriendBar> {
  final Friend guest = GuestFriend("Hebert");


  Widget constructProfile(Friend friend, bool isSelected) {
    String displayName = () {
      String name = friend.getName();
      if (name.length > 10) return "${name.substring(0, 7)}...";
      return name;
    }();


    return Padding(
      padding: EdgeInsetsGeometry.fromSTEB(10, 0, 10, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.changeSelectedFriendCallback(friend),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: isSelected ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2
                    ) : null
                  ),
                  child: friend.getProfilePicture(10),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(0, 2, 0, 0),
                  child: Text(displayName, style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    widget.friends.remove(friend);
                  });
                },
                child: Icon(Icons.close, size: 10,),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> allProfiles = () {
      List<Widget> profiles = [];

      for (Friend friend in widget.friends) {
        profiles.add(constructProfile(friend, widget.selectedFriend == friend));
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
