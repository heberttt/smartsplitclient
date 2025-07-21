import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsplitclient/Constants/backend_url.dart';
import 'package:smartsplitclient/Friend/Model/friend_request.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:http/http.dart' as http;

class FriendService {
  Future<bool> sendFriendRequest(String email) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse("${BackendUrl.FRIEND_REQUEST_SERVICE}/email"),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"targetEmail": email}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      String errMessage = '${jsonDecode(response.body)['errorMessage']}';

      if (errMessage.startsWith("java.lang.Exception: ")){
        errMessage = errMessage.replaceFirst('java.lang.Exception:', ''.trim());
      }
      
      throw Exception('Failed to send friend request: $errMessage');
    }
  }

  Future<bool> acceptFriendRequest(int requestId) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse("${BackendUrl.FRIEND_SERVICE}/addFriend"),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"targetId": requestId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to accept friend request: ${response.statusCode}',
      );
    }
  }

  Future<bool> rejectFriendRequest(int requestId) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.delete(
      Uri.parse(BackendUrl.FRIEND_REQUEST_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"friendRequestID": requestId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to reject friend request: ${response.statusCode}',
      );
    }
  }

  Future<List<FriendRequest>> getMyFriendRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(BackendUrl.FRIEND_REQUEST_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return data.entries.map((entry) {
        final user = entry.value;
        return FriendRequest(
          user['id'],
          user['email'],
          user['username'],
          user['profilePictureLink'],
          int.parse(entry.key),
        );
      }).toList();
    } else {
      throw Exception('Failed to load friend requests: ${response.statusCode}');
    }
  }

  Future<bool> removeFriend(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.delete(
      Uri.parse(BackendUrl.FRIEND_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"friendId": id}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to remove friend. Status code: ${response.statusCode}");
      print("${response.body}");
      return false;
    }
  }

  Future<List<RegisteredFriend>> getMyFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse(BackendUrl.FRIEND_SERVICE),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded['data'];

      return data.map((json) => _fromJson(json)).toList();
    } else {
      print("Failed to fetch friends. Status code: ${response.statusCode}");
      return [];
    }
  }

  RegisteredFriend _fromJson(Map<String, dynamic> json) {
    print("${json['username']} $json['email']");
    return RegisteredFriend(
      json['id'],
      json['email'],
      json['username'],
      json['profilePictureLink'],
    );
  }

  Future<RegisteredFriend> getAccount(String accountId) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.get(
      Uri.parse("${BackendUrl.ACCOUNT_SERVICE_URL}?id=$accountId"),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'];

      return RegisteredFriend.fromJson(data);
    } else {
      throw Exception('Failed to fetch friend: ${response.statusCode}');
    }
  }

  Future<List<RegisteredFriend>> getAccounts(List<String> accountIds) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);

    final response = await http.post(
      Uri.parse(BackendUrl.ACCOUNT_SERVICE_URL),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"accountIds": accountIds}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      final List<dynamic> data = json['data'];
      return data.map((item) => RegisteredFriend.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch accounts: ${response.statusCode}');
    }
  }
}
