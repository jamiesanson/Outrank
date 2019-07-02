
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
  final List<Office> allOffices;
  final Game currentGame;
  final List<User> users;

  RanksLoaded(this.office, this.allOffices, this.currentGame, this.users): super(
    [office, allOffices, currentGame, users]
  );

  RanksLoaded update({Office office, List<Office> allOffices, Game game, List<User> users}) =>
    RanksLoaded(
      office == null ? this.office : office,
      allOffices == null ? this.allOffices : allOffices,
      game == null ? this.currentGame : game,
      users == null ? this.users : users
    );
}

class RanksNotLoaded extends RankScreenState {}

class JoinedGame extends RankScreenState {}
