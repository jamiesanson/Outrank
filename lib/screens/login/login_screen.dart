import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

class LoginScreen extends StatelessWidget {

  _startOauth(BuildContext context) async {
    // TODO - Push OAuth screen for result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.network(
            "https://www.trademe.co.nz/trust-safety/media/285465/kevin-nest-trademe.png",
            width: 200,
            height: 200,
          ),
          Text("Outrank"),
          Text("Fun and competitive pool at Trade Me"),
          FlatButton(
            child: Image.network(
                "https://a.slack-edge.com/02728/img/sign_in_with_slack.png"),
            onPressed: () {
              _startOauth(context);
            },
          )
        ],
      )),
    );
  }
}
