import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class Dialogs {
  static Future<ConfirmAction> confirmDialog(BuildContext context,
      {String text, String title}) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
                height: 100,
                child: Column(
                  children: <Widget>[
                    Text("Please wait"),
                    SizedBox(height: 20),
                    Container(
                      child: CircularProgressIndicator(),
                      height: 50,
                      width: 50,
                    )
                  ],
                )));
      },
    );
  }

  static void simpleAlert(BuildContext context, String title, String text,
      {Function closeAction, String buttonText}) {
    Alert(context: context, title: title, desc: text, buttons: [
      DialogButton(
        child: Text(
          buttonText ?? "Close",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          if (closeAction == null)
            Navigator.pop(context);
          else
            closeAction();
        },
        width: 120,
      )
    ]).show();
  }

  static Future showMyDialog(BuildContext context, Widget dialogWidget) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: dialogWidget);
        });
  }
}
