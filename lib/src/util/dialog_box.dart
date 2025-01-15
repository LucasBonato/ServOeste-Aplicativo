import 'package:flutter/material.dart';

class DialogUtils {
  static Future<void> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
    String cancelText,
    dynamic onConfirm,
  ) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Text(title, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                    foregroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(confirmText, style: const TextStyle(fontSize: 25)),
              ),
              TextButton(
                style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                    foregroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(cancelText, style: const TextStyle(fontSize: 25)),
              )
            ],
          );
        });
  }
}
