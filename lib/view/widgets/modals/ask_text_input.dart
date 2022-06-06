import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

askTextInput(String msg, BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  await showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text(msg),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
    return controller.value.text;
}