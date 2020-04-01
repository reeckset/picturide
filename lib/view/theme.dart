import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 255, 255, 255);
const Color accentColor = Colors.teal;
const Color backgroundColor = Color.fromARGB(255, 0, 0, 0);
const Color lightBackgroundColor = Color.fromARGB(255, 50, 50, 50);

ThemeData themeData = ThemeData(
  brightness: Brightness.dark,
  primaryColorDark: primaryColor,
  accentColor: accentColor,
  canvasColor: backgroundColor,
  buttonColor: accentColor
);