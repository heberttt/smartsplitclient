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
    // TODO: implement getName
    throw UnimplementedError();
  }
  
  @override
  Widget getProfilePicture(double width) {
    // TODO: implement getProfilePicture
    throw UnimplementedError();
  }

  
}