import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context, String title, String content) {
  return showDialog(context: context, builder: (builder) {
    return AlertDialog(
      title: Text(content),
      content: Text(content),
    );
  });
}