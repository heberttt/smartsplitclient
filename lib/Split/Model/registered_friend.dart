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


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisteredFriend &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory RegisteredFriend.fromJson(Map<String, dynamic> json) {
    return RegisteredFriend(
      json['id'],
      json['email'],
      json['username'],
      json['profilePictureLink'],
    );
  }
}