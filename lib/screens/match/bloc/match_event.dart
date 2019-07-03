import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:outrank/model/model.dart';

@immutable
abstract class MatchEvent extends Equatable {
  MatchEvent([List props = const []]) : super(props);
}

class OfficeProvided extends MatchEvent {
  final Office office;

  OfficeProvided(this.office) : super([office]);
}

class GameUpdated extends MatchEvent {
  final Game game;

  GameUpdated(this.game) : super([game]);
}

class ReadyToReport extends MatchEvent {}

class ResultReported extends MatchEvent {
  final bool iWon;

  ResultReported(this.iWon) : super([iWon]);
}
