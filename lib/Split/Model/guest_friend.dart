import 'package:avatar_plus/avatar_plus.dart';
import 'package:flutter/material.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';

class GuestFriend implements Friend{
  String name;
  GuestFriend(this.name);
  
  @override
  String getName() {
    return name;
  }

  @override
  Widget getProfilePicture(double width) {
    return AvatarPlus(
          name,
          width: width,
        );
  }

}