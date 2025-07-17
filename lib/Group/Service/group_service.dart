import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class GroupService {
  Future<List<Group>> getMyGroups() async {
  final user = FirebaseAuth.instance.currentUser;
  final idToken = await user?.getIdToken(true);

  final response = await http.get(
    Uri.parse(BackendUrl.GROUP_SERVICE),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'];

    return data.map((json) => parseGroupFromJson(json)).toList();
  } else {
    print("Failed to fetch groups. Status code: ${response.statusCode}");
    return [];
  }
}

  Group parseGroupFromJson(Map<String, dynamic> json) {
    List<dynamic> membersJson = json['members'];
    List<RegisteredFriend> members =
        membersJson.map((member) {
          return RegisteredFriend(
            member['id'],
            member['email'],
            member['username'],
            member['profilePictureLink'],
          );
        }).toList();

    return Group(json['id'], json['name'], members);
  }

  Future<bool> inviteToGroup(int groupId, String friendId) async{
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse("${BackendUrl.GROUP_SERVICE}/members"),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
         "groupId" : groupId,
         "friendId" : friendId
      })
    );

    return response.statusCode == 200;
  }


  Future<bool> leaveGroup(int groupId) async{
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.delete(
      Uri.parse("${BackendUrl.GROUP_SERVICE}/members"),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
         "groupId" : groupId,
      })
    );

    return response.statusCode == 200;
  }


  Future<bool> createGroup(String name, List<String> membersId)  async{
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse(BackendUrl.GROUP_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
         "name" : name,
         "otherMembersId" : membersId
      })
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create group: ${response.body}');
    }
  }
}
