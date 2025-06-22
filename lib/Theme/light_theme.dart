import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme{
  final Color amaranthPurple = const Color(0xFFA63A50);
  final Color antiqueWhite = const Color(0xFFF0E7D8);
  final Color cinereous = const Color(0xFFAB9B96);
  final Color brownSugar = const Color(0xFFA1674A);
  final Color oldRose = const Color(0xFFBA6E6E);

  late ThemeData theme;

  LightTheme(){
    theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: amaranthPurple),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

}