import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:outrank/model/model.dart';
import 'package:outrank/screens/match/bloc/match_event.dart';
import 'package:outrank/screens/match/bloc/match_state.dart';
import 'package:outrank/screens/ranking/bloc/ranking_repository.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {

  final String _resultFunction = "";

  final RankingRepository _repository = RankingRepository();

  StreamSubscription _subscription;  

  @override
  MatchState get initialState => LoadingGame();

  @override
  Stream<MatchState> mapEventToState(MatchEvent event) async* {
    if (event is OfficeProvided) {
      _subscription?.cancel();
      _subscription = _repository.game.listen((game) {
        dispatch(GameUpdated(game));
      });
    }

    if (event is ResultReported) {
      var currentGame = await _repository.game.first;
      _reportResult(currentGame, event.iWon);
    }

    if (event is ReadyToReport) {
      var currentGame = await _repository.game.first;
      yield ReportingResult(await _opponentName(currentGame));
    }

    if (event is GameUpdated) {
      Game currentGame = event.game;
      print("Game updated: $currentGame");

      switch (currentGame.state) {
        case GameState.waiting_for_opponent:
          yield WaitingOnOpponent();
          break;
        case GameState.in_progress:
          yield PlayingGame(await _opponentName(currentGame));
          break;
        case GameState.waiting_on_result:
          bool waitingOnCurrentUser = await _waitingOnCurrentUser(currentGame);

          // If the game gets to this state, the current user needs to report a result
          if (waitingOnCurrentUser) {
            yield ReportingResult(await _opponentName(currentGame));
          } else {
            yield WaitingOnOpponentResult(await _opponentName(currentGame));
          }
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  Future<String> _opponentName(Game game) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (game.op1Ref.documentID == user.uid) {
      return game.op1Name;
    } else {
      return game.op2Name;
    }
  }

  Future<bool> _waitingOnCurrentUser(Game game) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    bool currentUserIsOp1 = game.op1Ref.documentID == user.uid;

    return currentUserIsOp1 ? game.op1ResultRef == null : game.op2ResultRef == null;
  }

  Future _reportResult(Game game, bool iWon) async {
    var body = {
      "game_id": game.id,
      "current_user_won": iWon
    };

    try {
      await post(_resultFunction, body: body);
    } catch (Exception) {}

  }
}
