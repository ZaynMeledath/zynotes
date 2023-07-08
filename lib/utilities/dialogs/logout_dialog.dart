import 'package:flutter/material.dart';
import 'package:zynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log Out',
    content: 'Are you sure you want to log out?',
    options: {
      'Cancel': false,
      'Log out': true,
    },
  ).then((value) => value ?? false);
}
