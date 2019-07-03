import 'package:equatable/equatable.dart';

abstract class MatchState extends Equatable {
  MatchState([List props = const []]) : super(props);
}

class LoadingGame extends MatchState {}

class WaitingOnOpponent extends MatchState {}

class PlayingGame extends MatchState {
  final String opponentName;

  PlayingGame(this.opponentName) : super([opponentName]);
}

class ReportingResult extends MatchState {
  final String opponentName;

  ReportingResult(this.opponentName) : super([opponentName]);
}

class WaitingOnOpponentResult extends MatchState {
  final String opponentName;

  WaitingOnOpponentResult(this.opponentName) : super([opponentName]);
}
