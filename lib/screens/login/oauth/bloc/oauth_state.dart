import 'package:equatable/equatable.dart';

abstract class OAuthState extends Equatable {
  OAuthState([List props = const []]) : super(props);
}

class WebviewPrompt extends OAuthState {
  final String url;

  WebviewPrompt(this.url): super([url]);
}

class RequestingToken extends OAuthState {}

class TokenRetrieved extends OAuthState {
  final Map<String, dynamic> token;

  TokenRetrieved(this.token): super([token]);
}

class TokenNotRetrieved extends OAuthState {}