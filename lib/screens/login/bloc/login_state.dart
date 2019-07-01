
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class Idle extends LoginState {}

class Loading extends LoginState {}

class LoginSuccessful extends LoginState {
  final String name;
  final String avatar;

  LoginSuccessful(this.name, this.avatar): super([name, avatar]);
}

class LoginError extends LoginState {}