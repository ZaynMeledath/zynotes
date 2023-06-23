import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  text,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An Error Occured'),
          content: Text(text),
          actions: [
            CupertinoButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
