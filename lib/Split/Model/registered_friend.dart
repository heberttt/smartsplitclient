import 'package:flutter/material.dart';
import 'package:smartsplitclient/Split/Model/friend.dart';

class RegisteredFriend extends Friend{
  String email;

  RegisteredFriend(this.email);

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