import 'package:flutter/material.dart';

class IntroDialog {
  void show(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Set yourself up"),
            content: TextField(),
            actions: <Widget>[
              FlatButton(
                child: Text("Continue"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
