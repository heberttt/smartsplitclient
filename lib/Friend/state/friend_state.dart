import 'package:flutter/widgets.dart';
import 'package:smartsplitclient/Friend/Model/friend_request.dart';
import 'package:smartsplitclient/Friend/Service/friend_service.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

class FriendState with ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<RegisteredFriend> myFriends = [];
  List<FriendRequest> myFriendRequests = [];

  bool isLoadingFriends = false;
  bool isLoadingFriendRequests = false;

  Future<bool> acceptFriendRequest(int id) async {
    return await _friendService.acceptFriendRequest(id);
  }

  Future<bool> rejectFriendRequest(int id) async {
    return await _friendService.rejectFriendRequest(id);
  }

  Future<void> getMyFriendRequests() async {
    isLoadingFriendRequests = true;
    notifyListeners();

    myFriendRequests = await _friendService.getMyFriendRequests();

    isLoadingFriendRequests = false;
    notifyListeners();
  }

  Future<void> getMyFriends() async {
    isLoadingFriends = true;
    notifyListeners();

    myFriends = await _friendService.getMyFriends();

    isLoadingFriends = false;
    notifyListeners();
  }

  Future<bool> removeFriend(String id) async {
    bool result = await _friendService.removeFriend(id);

    if (result) {
      getMyFriends();
      return true;
    }
    return false;
  }
}
