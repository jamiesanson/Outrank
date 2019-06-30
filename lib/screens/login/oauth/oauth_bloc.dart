import 'dart:async';
import 'dart:convert';

import 'package:flutter_oauth/lib/model/config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:outrank/screens/login/oauth/token_request.dart';

import 'oauth_event.dart';
import 'oauth_state.dart';

import 'package:bloc/bloc.dart';

import 'package:http/http.dart';

class OAuthBloc extends Bloc<OAuthEvent, OAuthState> {
  StreamSubscription _subscription;

  final Config config = Config(
    "https://slack.com/oauth/authorize",
    "https://slack.com/api/oauth.access",
    "21360951026.681252925094",
    "d27a189920eeb8d3e57ebf7cbd74b8eb",
    "localhost:8080",
    "code",
    parameters: {"scope": "identity.basic,identity.avatar"}
  );

  @override
  OAuthState get initialState => WebviewPrompt(
      "https://slack.com/oauth/authorize?scope=identity.basic,identity.avatar&client_id=21360951026.681252925094");

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Stream<OAuthState> mapEventToState(OAuthEvent event) async* {
    if (_subscription == null) {
      _subscription = FlutterWebviewPlugin().onUrlChanged.listen((newUrl) {
        dispatch(UrlChanged(newUrl));
      });
    }

    // User input events
    if (event is UrlChanged) {
      if (event.url.startsWith("localhost:8080")) {
        dispatch(RedirectUrlCaught(event.url));
      }
    }

    if (event is RedirectUrlCaught) {
      // Make network request, update state
      yield RequestingToken();

      try {
        var code = UriData.fromString(event.url).parameters["code"];
        var tokenRequest = TokenRequestDetails(config, code);

        Response response = await post("${tokenRequest.url}",
            body: json.encode(tokenRequest.params),
            headers: tokenRequest.headers);

        Map<String, dynamic> token = json.decode(response.body);

        yield TokenRetrieved(token);

      } catch (Exception) {
        yield TokenNotRetrieved();
      }
    }
  }
}
