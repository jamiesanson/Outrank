import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


@immutable
abstract class OAuthEvent extends Equatable {
  OAuthEvent([List props = const []]) : super(props);
}

class UrlChanged extends OAuthEvent {
  final String url;

  UrlChanged(this.url): super([url]);
}

class RedirectUrlCaught extends OAuthEvent {
  final String url;

  RedirectUrlCaught(this.url): super([url]);
}

class RetrievingToken extends OAuthEvent {}

class TokenRetrieved extends OAuthEvent {
  final Map<String, dynamic> token;

  TokenRetrieved(this.token): super([token]);
}

class ErrorOccurred extends OAuthEvent {}
