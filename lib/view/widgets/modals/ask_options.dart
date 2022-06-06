import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<int> askOptions(
  String title,
  String msg,
  List<String>options,
  BuildContext context
) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: options.asMap().entries.map(
            (entry) => TextButton(
              child: Text(entry.value),
              onPressed: () {
                Navigator.of(context).pop(entry.key);
              },
            ),
          ).toList()
        )
    );
}