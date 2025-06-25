// ignore_for_file: constant_identifier_names
 

class BackendUrl {
  static const String GATEWAY_URL = "http://192.168.100.61:8080";

  static const String OCR_SERVICE_URL = "$GATEWAY_URL/ocr/scan";

  static const String DATA_TRANSFORM_URL = "$GATEWAY_URL/dataProcess/transform";
}