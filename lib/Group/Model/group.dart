import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class Group{
  int id;
  String name;

  List<RegisteredFriend> members;

  Group(this.id, this.name, this.members);
}