import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outrank/screens/login/bloc/login_bloc.dart';
import 'package:outrank/screens/login/bloc/login_event.dart';
import 'package:outrank/screens/login/bloc/login_state.dart';
import 'package:outrank/screens/login/oauth/bloc/oauth_bloc.dart';
import 'package:outrank/widgets/empty_app_bar.dart';

import 'oauth/oauth_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginBloc _bloc = BlocProvider.of<LoginBloc>(context);

    return BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          if (state is Loading) {
            return Scaffold(
                appBar: EmptyAppBar(),
                body: Center(
                  child: CircularProgressIndicator(),
                ));
          }

          if (state is LoginError) {
            return _buildLoginIdle(context, _bloc, promptError: true);
          }

          if (state is LoginSuccessful) {
            return _buildLoggedInView(context, _bloc, state.name, state.avatar);
          }

          return _buildLoginIdle(context, _bloc);
        });
  }

  Widget _buildLoggedInView(
      BuildContext context, LoginBloc _bloc, String name, String avatar) {
    return Scaffold(
        appBar: EmptyAppBar(),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.network(
                  avatar,
                  width: 200,
                  height: 200,
                ),
                Text(name),
                FlatButton(
                  child: Text("CONTINUE", style: TextStyle(fontSize: 20.0)),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/home");
                  },
                )
              ]),
        ));
  }

  Widget _buildLoginIdle(BuildContext context, LoginBloc _bloc,
      {bool promptError}) {
    return Scaffold(
      appBar: EmptyAppBar(),
      body: Builder(builder: (ctx) {
        if (promptError == true) {
          Future.delayed(Duration(milliseconds: 100)).then((onValue) {
            Scaffold.of(ctx).showSnackBar(SnackBar(
              content: Text("An error occurred - please try again"),
            ));
          });
        }

        return Center(
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
                _startOauth(context, _bloc);
              },
            )
          ],
        ));
      }),
    );
  }

  _startOauth(BuildContext context, LoginBloc bloc) async {
    Map<String, dynamic> response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider(
                builder: (context) => OAuthBloc(), child: OAuthScreen())));

    if (response == null) {
      bloc.dispatch(LoginFailed());
    } else {
      bloc.dispatch(SlackTokenGranted(response));
    }
  }
}
