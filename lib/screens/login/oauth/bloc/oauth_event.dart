import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


@immutable
abstract class OAuthEvent extends Equatable {
  OAuthEvent([List props = const []]) : super(props);
}

class BeginListening extends OAuthEvent {}

class UrlChanged extends OAuthEvent {
  final String url;

  UrlChanged(this.url): super([url]);
}

class RedirectUrlCaught extends OAuthEvent {
  final String url;

  RedirectUrlCaught(this.url): super([url]);
}

class ErrorOccurred extends OAuthEvent {}
