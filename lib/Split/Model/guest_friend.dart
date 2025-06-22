import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/friend.dart';

class GuestFriend implements Friend{
  String name;
  GuestFriend(this.name);
  
  @override
  String getName() {
    return name;
  }

  @override
  Image getProfilePicture(double width) {
    return Image(image: AssetImage("assets/user-profile.png"), width: width,);
  }

}