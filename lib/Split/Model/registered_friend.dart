import 'package:flutter/material.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';

class RegisteredFriend extends Friend{
  String id;

  String email;

  String username;

  String profilePictureLink;

  RegisteredFriend(this.id, this.email, this.username, this.profilePictureLink);

  @override
  String getName() {
    return username;
  }
  
  @override
  Widget getProfilePicture(double width) {
    return Image.network(
    profilePictureLink,
    width: width,
    fit: BoxFit.cover,
  );
  }

}