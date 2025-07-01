import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartsplitclient/Authentication/Model/Account.dart';

class AccountConverter {
  Account convertFromResponse(http.Response response){
    final map = jsonDecode(response.body);

    return Account(map['data']['id'], map['data']['email'], map['data']['username'], map['data']['profilePictureLink']);
  }
}