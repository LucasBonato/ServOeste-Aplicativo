import 'package:flutter/material.dart';

class DialogUtils {
  static Future<void> showConfirmationDialog(
      BuildContext context,
      String title,
      String content,
      String confirmText,
      String cancelText,
      Function() onConfirm,
      ) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: MaterialStatePropertyAll(Colors.blue),
                    foregroundColor: MaterialStatePropertyAll(Colors.white)
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: Text(confirmText, style: const TextStyle(fontSize: 25)),
              ),
              TextButton(
                style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                    foregroundColor: MaterialStatePropertyAll(Colors.white)
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(cancelText, style: const TextStyle(fontSize: 25)),
              )
            ],
          );
        }
    );
  }
}