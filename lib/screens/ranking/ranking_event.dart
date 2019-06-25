import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:outrank/model/model.dart';

@immutable
abstract class RankScreenEvent extends Equatable {
  RankScreenEvent([List props = const []]) : super(props);
}

class FetchAll extends RankScreenEvent {}

class StartPlaying extends RankScreenEvent {}

class OfficeChanged extends RankScreenEvent {
  final Office office;

  OfficeChanged(this.office): super([office]);
}

class GameUpdated extends RankScreenEvent {
  final Game game;

  GameUpdated(this.game): super([game]);
}
