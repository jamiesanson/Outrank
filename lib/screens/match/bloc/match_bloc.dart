import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  String _gameId;

  @override
  MatchState get initialState => LoadingGame();

  Stream<Game> _getGameStream(String officeId) {
    return Firestore.instance.collection('games').snapshots().map((query) {
        return query.documents.map((doc) {
          return doc == null ? null : Game(doc);
        }).toList();
      }).map((list) => list.firstWhere((game) => game.officeRef.documentID == officeId));
  }

  Future<Game> _getCurrentGame() async {
    return Game(await Firestore.instance.document("games/$_gameId").snapshots().first);
  }

  @override
  Stream<MatchState> mapEventToState(MatchEvent event) async* {
    if (event is OfficeProvided) {
      _subscription?.cancel();
      _subscription = _getGameStream(event.office.id).listen((game) {
        dispatch(GameUpdated(game));
      });

      // Check if a game exists
      var game = (await _repository.allGames.first).firstWhere((game) => game.officeRef.documentID == event.office.id, orElse: () => null);

      // Are we already in the game? If not, start or join it
      String uid = (await FirebaseAuth.instance.currentUser()).uid;
      var inGame = game.op1Ref == Firestore.instance.document("users/$uid");
      
      if (!inGame) {
        var params = game != null ? { "game_id": game.id} : { "office_id": event.office.id }; 
        // Join or start game
        await CloudFunctions.instance.getHttpsCallable(
          functionName: "joinOrStartGame"
        ).call(params);
      }
    }

    if (event is ResultReported) {
      var currentGame = await _getCurrentGame();
      _reportResult(currentGame, event.iWon);
    }

    if (event is ReadyToReport) {
      var currentGame = await _getCurrentGame();
      yield ReportingResult(await _opponentName(currentGame));
    }

    if (event is GameUpdated) {
      Game currentGame = event.game;
      _gameId = currentGame.id;

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
      // Join or start game
      await CloudFunctions.instance.getHttpsCallable(
        functionName: "reportGameResult"
      ).call(body);
    } catch (Exception) {}

  }
}
