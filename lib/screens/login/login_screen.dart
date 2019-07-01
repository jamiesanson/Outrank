import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

import 'oauth/oauth_bloc.dart';
import 'oauth/oauth_screen.dart';

class LoginScreen extends StatelessWidget {

  _startOauth(BuildContext context) async {
    Map<String, dynamic> response = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => BlocProvider(
        builder: (context) => OAuthBloc(), 
        child: OAuthScreen())
    ));

    if (response != null) {
      print("Token retrieved for user with ID: " + response["user"]["id"]);
      var tokenRequestBody = { "id": response["user"]["id"], "name": response["user"]["name"], "avatar": response["user"]["image_192"], "access_token": response["access_token"]};
      var tokenResponse = await post("https://us-central1-outrank-ba748.cloudfunctions.net/performSlackLogin", body: tokenRequestBody);

      print("Got response ${tokenResponse.body}");
      Map<String, dynamic> body = json.decode(tokenResponse.body);
      var user = await FirebaseAuth.instance.signInWithCustomToken(token: body["token"]);

      print("Signed in as ${user.uid}");
    }

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
