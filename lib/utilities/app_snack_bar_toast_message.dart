import 'package:flutter/material.dart';

class SnackBarToastMessage {
  SnackBarToastMessage._();
  static showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        duration: Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,

        content: Text("$message"),
      ),
    );
  }
}