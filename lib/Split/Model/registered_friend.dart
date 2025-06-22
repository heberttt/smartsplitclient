import 'package:flutter/material.dart';
import 'package:smartsplit/Split/Model/Friend.dart';

class RegisteredFriend extends Friend{
  String email;

  RegisteredFriend(this.email);

  @override
  String getName() {
    // TODO: implement getName
    throw UnimplementedError();
  }
  
  @override
  Image getProfilePicture(double width) {
    // TODO: implement getProfilePicture
    throw UnimplementedError();
  }

  
}