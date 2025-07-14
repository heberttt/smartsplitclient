// ignore_for_file: constant_identifier_names
 

class BackendUrl {
  static const String GATEWAY_URL = "http://192.168.100.61:8080";

  static const String OCR_SERVICE_URL = "$GATEWAY_URL/ocr/scan";

  static const String DATA_TRANSFORM_URL = "$GATEWAY_URL/dataProcess/transform";

  static const String ACCOUNT_SERVICE_URL = "$GATEWAY_URL/accounts";

  static const String FRIEND_SERVICE = "$GATEWAY_URL/friends";

  static const String FRIEND_REQUEST_SERVICE = "$GATEWAY_URL/friendRequest";

  static const String GROUP_SERVICE = "$GATEWAY_URL/groups";

  static const String SPLIT_SERVICE = "$GATEWAY_URL/splits";

  static const String DEBT_SERVICE = "$GATEWAY_URL/debts";
}