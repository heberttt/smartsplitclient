import 'package:flutter/widgets.dart';
import 'package:smartsplitclient/Group/Model/group.dart';
import 'package:smartsplitclient/Group/Service/group_service.dart';

class GroupState with ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<Group> myGroups = [];

  bool isLoadingGroups = false;

  Future<void> getMyGroups() async {
    isLoadingGroups = true;
    notifyListeners();

    myGroups = await _groupService.getMyGroups();

    isLoadingGroups = false;
    notifyListeners();
  }

  void clear() {
    myGroups = [];
    notifyListeners();
  }
}
