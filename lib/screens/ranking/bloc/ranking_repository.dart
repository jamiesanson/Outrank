import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outrank/model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingRepository {
  final BehaviorSubject<String> _officeSubject = BehaviorSubject<String>();

  Stream<List<Office>> get allOffices =>
      Firestore.instance.collection('offices').snapshots().map((query) {
        return query.documents.map((doc) {
          return doc == null ? null : Office(doc);
        }).toList();
      });

  Stream<Office> get currentOffice =>
      Observable.combineLatest2(_officeSubject, allOffices, (id, offices) {
        return offices.firstWhere((office) {
          return office.id == id;
        });
      });

  Stream<List<Game>> get allGames =>
      Firestore.instance.collection('games').snapshots().map((query) {
        return query.documents.map((doc) {
          return doc == null ? null : Game(doc);
        }).toList();
      });

  Stream<Game> get game =>
      Observable.combineLatest2(allGames, currentOffice, (games, office) {
        return games.firstWhere((game) {
          return game.officeRef.documentID == office.id;
        }, orElse: () {
          return Game.empty();
        });
      });

  Stream<List<User>> get topUsers => Firestore.instance
          .collection('users')
          .orderBy('rating')
          .limit(5)
          .snapshots()
          .map((query) {
        return query.documents.map((doc) {
          return User(doc);
        }).toList();
      });

  Future<String> _loadOfficeKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Office office;

    if (!prefs.containsKey("office_key")) {
      // Set a sane default
      office = await allOffices.first.then((offices) {
        return offices[0];
      });

      prefs.setString("office_key", office.id);
    }

    return prefs.getString("office_key");
  }

  void fetch() async {
    // Load the first office
    _officeSubject.add(await _loadOfficeKey());
  }

  void updateOffice(Office newOffice) async {
    // Update the users preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("office_key", newOffice.id);

    _officeSubject.add(newOffice.id);
  }
}
