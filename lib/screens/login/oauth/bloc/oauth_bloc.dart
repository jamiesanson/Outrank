import 'dart:async';
import 'dart:convert';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'oauth_event.dart';
import 'oauth_state.dart';

import 'package:bloc/bloc.dart';

import 'package:http/http.dart';

class OAuthBloc extends Bloc<OAuthEvent, OAuthState> {
  StreamSubscription _subscription;

  final String _clientId = "21360951026.681252925094";
  final String _clientSecret = "d27a189920eeb8d3e57ebf7cbd74b8eb";

  @override
  OAuthState get initialState => WebviewPrompt(
      "https://slack.com/oauth/authorize?scope=identity.basic,identity.avatar&client_id=$_clientId");

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Stream<OAuthState> mapEventToState(OAuthEvent event) async* {
    if (event is BeginListening) {
      _subscription?.cancel();
      _subscription = FlutterWebviewPlugin().onUrlChanged.listen((newUrl) {
        dispatch(UrlChanged(newUrl));
      });
    }

    // User input events
    if (event is UrlChanged) {
      if (event.url.startsWith("http://localhost:8080")) {
        dispatch(RedirectUrlCaught(event.url));
      }
    }

    if (event is RedirectUrlCaught) {
      // Make network request, update state
      yield RequestingToken();

      try {
        var code = Uri.parse(event.url).queryParameters["code"];

        var url = Uri.https("slack.com", "/api/oauth.access", { "client_id": _clientId, "client_secret": _clientSecret, "code": code });
        Response response = await get(url);

        Map<String, dynamic> token = json.decode(response.body);

        yield TokenRetrieved(token);
      } catch (e) {
        print(e);
        yield TokenNotRetrieved();
      }
    }
  }
}
