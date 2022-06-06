import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

informDialog(String title, String msg, BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
}