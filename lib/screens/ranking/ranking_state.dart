
import 'package:equatable/equatable.dart';
import 'package:outrank/model/game.dart';
import 'package:outrank/model/office.dart';
import 'package:outrank/model/user.dart';

abstract class RankScreenState extends Equatable {
  RankScreenState([List props = const []]) : super(props);
}

class RanksLoading extends RankScreenState {}

class RanksLoaded extends RankScreenState {

  final Office office;
  final Game currentGame;
  final List<User> users;

  RanksLoaded(this.office, this.currentGame, this.users): super(
    [office, currentGame, users]
  );
}

class RanksNotLoaded extends RankScreenState {}
