import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../routes/1.constants/common_constants.dart';

class ToastUtil {
  static getToast(BuildContext context, String title, String message) async {
    await Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 5),
    ).show(context);
  }

  static getToaste(String title, String message) async {
    await Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  static showSnackBarAtCurrentState(String message,
      {SnackBarAction? actions, int? seconds,isError = false}) {
    if (snackBarKey.currentContext != null &&
        !snackBarKey.currentContext!.mounted) {
      return;
    }
    final SnackBar snackBar = SnackBar(backgroundColor:isError ? Colors.red:Colors.black ,
      duration: Duration(seconds: seconds ?? 2),
      action: actions,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
    snackBarKey.currentState?.showSnackBar(snackBar);
  }

  static void showMessage(
      BuildContext context, String message, bool? isErrorMessage,
      {SnackBarAction? action, int duration = 3}) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: isErrorMessage == true ? Colors.red : Colors.green,
        action: action,
        duration: Duration(seconds: duration),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    });
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}
