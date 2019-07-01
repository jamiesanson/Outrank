import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:outrank/screens/login/bloc/login_event.dart';
import 'package:outrank/screens/login/bloc/login_state.dart';

import 'package:bloc/bloc.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final String _slackLoginFunction = "https://us-central1-outrank-ba748.cloudfunctions.net/performSlackLogin";

  @override
  LoginState get initialState => Idle();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginFailed) {
      yield LoginError();
      await Future.delayed(const Duration(seconds: 10));
      yield Idle();
    }

    if (event is UserSignedIn) {
      yield LoginSuccessful(event.name, event.avatar);
    }

    if (event is SlackTokenGranted) {
      yield Loading();

      var response = event.response;
      var tokenRequestBody = { 
        "id": response["user"]["id"], 
        "name": response["user"]["name"], 
        "avatar": response["user"]["image_192"], 
        "access_token": response["access_token"]};

      var tokenResponse = await post(_slackLoginFunction, body: tokenRequestBody);

      Map<String, dynamic> body = json.decode(tokenResponse.body);
      var user = await FirebaseAuth.instance.signInWithCustomToken(token: body["token"]);
      var updateInfo = UserUpdateInfo();
      updateInfo.displayName = response["user"]["name"];
      updateInfo.photoUrl = response["user"]["image_192"];

      await user.updateProfile(updateInfo);

      dispatch(UserSignedIn(updateInfo.displayName, updateInfo.photoUrl));
    }
  }
}