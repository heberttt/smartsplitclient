import 'package:flutter/widgets.dart';

abstract class Friend {
  Image getProfilePicture(double width);
  String getName();
}