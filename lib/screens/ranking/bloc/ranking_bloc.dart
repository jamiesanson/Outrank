import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outrank/model/model.dart';
import 'package:outrank/screens/ranking/bloc/bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:outrank/screens/ranking/bloc/ranking_repository.dart';
import 'package:rxdart/rxdart.dart';

class RankingBloc extends Bloc<RankScreenEvent, RankScreenState> {
  final RankingRepository _rankingRepository;
  final CompositeSubscription subscriptions = CompositeSubscription();

  RankingBloc(this._rankingRepository);

  @override
  RankScreenState get initialState => RanksLoading();

  @override
  void dispose() {
    super.dispose();
    subscriptions.dispose();
  }
  
  @override
  Stream<RankScreenState> transform(events, next) {
    return super.transform(
      (events as Observable<RankScreenEvent>).distinct(),
      next,
    );
  }

  @override
  Stream<RankScreenState> mapEventToState(RankScreenEvent event) async* {
    // User input events
    if (event is OfficeChanged) {
      // Change the state by updating the office
      _rankingRepository.updateOffice(event.office);
    }

    // Data events 
    if (event is FetchAll) {
      try {
        // Kick off a new office load
        _rankingRepository.fetch();

        // Await the first state
        Office currentOffice = await _rankingRepository.currentOffice.first;
        List<Office> allOffices = await _rankingRepository.allOffices.first;
        Game currentGame = await _rankingRepository.game.isEmpty ? null : await _rankingRepository.game.first;
        List<User> topUsers = await _rankingRepository.topUsers.first;
        
        String userId = (await FirebaseAuth.instance.currentUser()).uid;
        DocumentReference currentUser = Firestore.instance.document("users/" + userId);

        yield RanksLoaded(currentOffice, allOffices, currentGame, topUsers, currentUser);

        // Clear subscriptions and observe repo
        subscriptions.clear();
        subscriptions.add(_rankingRepository.currentOffice.listen((office) {
          dispatch(OfficeUpdated(office));
        }));

        subscriptions.add(_rankingRepository.game.listen((game) {
          dispatch(GameUpdated(game));
        }));

        subscriptions.add(_rankingRepository.topUsers.listen((users) {
          dispatch(UsersUpdated(users));
        }));
      } catch (e) {
        // TODO: Log this as a non-fatal
        print("Got exception: $e");
        yield RanksNotLoaded();
      }
    }

    // Process updates if in the right state
    RankScreenState state = currentState;
    if (state is RanksLoaded) {
      if (event is OfficeUpdated) {
        yield state.update(office: event.office);
      }

      if (event is OfficeChanged) {
        // Update the repo
        _rankingRepository.updateOffice(event.office);
      }

      if (event is GameUpdated) {
        yield state.update(game: event.game);
      }

      if (event is UsersUpdated) {
        yield state.update(users: event.users);
      }
    }
  }
}
