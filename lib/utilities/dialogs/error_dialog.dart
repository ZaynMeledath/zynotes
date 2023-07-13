import 'package:flutter/material.dart';
import 'package:zynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  Navigator.of(context).pop();
  return showGenericDialog(
    context: context,
    title: 'An Error Occured',
    content: content,
    options: {'Dismiss': null},
  );
}
