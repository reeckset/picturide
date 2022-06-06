import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

askUserConfirm(String msg, BuildContext context) async {
  bool result = false;
  await showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text('Are you sure?'),
          content: Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text('No'),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        )
    );
    return result;
}