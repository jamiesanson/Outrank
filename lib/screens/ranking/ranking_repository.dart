import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outrank/model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingRepository {
  final BehaviorSubject<String> _officeSubject = BehaviorSubject<String>();

  Stream<List<Office>> get allOffices => Firestore.instance.collection('offices').snapshots().map((query) {
    return query.documents.map((doc) { return doc == null ? null : Office(doc); }).toList();
  });

  Stream<Office> get currentOffice => Observable.combineLatest2(_officeSubject, allOffices, (id, offices) {
    print("Updating to id: $id");
    return offices.firstWhere((office) { return office.id == id; });
  });

  Stream<Game> get game =>
      Firestore.instance.collection('games').snapshots().map((query) {
        return query.documents;
      }).map((documents) {
        return documents.singleWhere((game) {
          return Game(game).officeRef.documentID == _officeSubject.value;
        }, orElse: () {
          return null;
        });
      }).map((document) {
        return document == null ? null : Game(document);
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
  
  void updateOffice(Office newOffice) {
    _officeSubject.add(newOffice.id);
  }
}
