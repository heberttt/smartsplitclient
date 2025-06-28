import 'package:flutter/widgets.dart';

abstract class Friend {
  Widget getProfilePicture(double width);
  String getName();
}