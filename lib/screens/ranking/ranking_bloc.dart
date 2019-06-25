import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outrank/model/model.dart';
import 'package:outrank/screens/ranking/ranking_event.dart';
import 'package:outrank/screens/ranking/ranking_repository.dart';
import 'package:outrank/screens/ranking/ranking_state.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingBloc extends Bloc<RankScreenEvent, RankScreenState> {
  final RankingRepository _rankingRepository;
  final CompositeSubscription subscriptions = CompositeSubscription();

  RankingBloc(this._rankingRepository);

  @override
  RankScreenState get initialState => RanksLoading();

  Future<Office> _loadOffice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentSnapshot doc;
    if (prefs.containsKey("office_key")) {
      doc = await Firestore.instance
          .collection('offices')
          .document(prefs.get("office_key"))
          .get();
    } else {
      // Set a sane default
      doc = await Firestore.instance
          .collection('offices')
          .getDocuments()
          .then((val) {
        return val.documents[0];
      });
    }

    return Office(doc);
  }

  Future<Game> _loadCurrentGame(Office currentOffice) async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('games').snapshots().single;

    snapshot.documents.singleWhere((game) {
      return Game(game).officeRef.documentID == currentOffice.id;
    }, orElse: () {
      return null;
    });
  }

  void _observeFirestore() async {

  }

  @override
  Stream<RankScreenState> mapEventToState(RankScreenEvent event) async* {
    if (event is FetchAll) {
      Office currentOffice = await _loadOffice();
      Game currentGame = await _loadCurrentGame(currentOffice);

      _observeFirestore();
    }

    if (event is OfficeChanged) {
      // Change the state by updating the office
      _rankingRepository.updateOffice(event.office);
    }
  }
}
