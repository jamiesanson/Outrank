
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class SlackTokenGranted extends LoginEvent {
  final Map<String, dynamic> response;

  SlackTokenGranted(this.response): super([response]);
}

class UserSignedIn extends LoginEvent {
  final String name;
  final String avatar;

  UserSignedIn(this.name, this.avatar): super([name, avatar]);
}

class LoginFailed extends LoginEvent {}
