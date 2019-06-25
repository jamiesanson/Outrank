import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outrank/model/game.dart';
import 'package:outrank/model/office.dart';
import 'package:outrank/widgets/backdrop.dart';
import 'package:outrank/widgets/empty_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RankingScreenState();
  }
}

class RankingScreenState extends State<RankingScreen> {
  Office _currentOffice;

  @override
  void initState() {
    super.initState();
    _loadCurrentOffice();
  }

  void _loadCurrentOffice() async {
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
      prefs.setString('office_key', doc.documentID);
    }

    Office office = Office(doc);

    setState(() {
      _currentOffice = office;
    });
  }

  void _onOfficeSelected(Office office) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("office_key", office.id);

    setState(() {
      _currentOffice = office;
    });
  }

  // Builds the user list widget containing everyones rankings
  Widget _userList() {
    return Column(children: <Widget>[
      Text("This month's top players"),
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              return Column(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  String subtitleText = document['gameCount'] != null
                      ? "${document['gameCount']} games played this month"
                      : "No games this month";
                  return ListTile(
                    title: Text(document['name']),
                    subtitle: Text(subtitleText),
                  );
                }).toList(),
              );
          }
        },
      )
    ]);
  }

  // Builds the page header widget, with illustration, start game action and
  // whether or not the table's in use
  Widget _pageHeader(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.network(
          "https://www.trademe.co.nz/trust-safety/media/285465/kevin-nest-trademe.png",
          width: 200,
          height: 200,
        ),
        StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('games').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            bool loading = snapshot.connectionState == ConnectionState.waiting;

            DocumentSnapshot gameDoc =
                loading ? null : snapshot.data.documents.singleWhere((game) {
              return Game(game).officeRef.documentID == _currentOffice.id;
            }, orElse: () {
              return null;
            });

            Game currentGame = gameDoc == null ? null : Game(gameDoc);

            String tableText =
                currentGame == null ? "The table is free!" : "Game in progress";

            if (loading) {
              tableText = "Loading";
            }

            return Column(children: <Widget>[
              Text(tableText),
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        color: Color(0xFF3B71DC),
                        clipBehavior: Clip.antiAlias, 
                        child: MaterialButton(
                          minWidth: 300,
                          height: 48,
                          child: Text(
                            "START PLAYING",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          onPressed: loading ? null : () {
                            // Check state of game to make sure it's possible to start playing now

                            // Route to game screen
                          },
                        ))),
              )
            ]);
          },
        ),
      ],
    );
  }

  Widget _getLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
      appBar: EmptyAppBar(),
    );
  }

  Widget _getBackgroundView() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('offices').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('');
              default:
                return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return RadioListTile(
                        title: Text(
                          document['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                        value: Office(document).id,
                        groupValue: _currentOffice.id,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          _onOfficeSelected(Office(document));
                        });
                  }).toList(),
                );
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOffice == null) {
      return _getLoadingScreen();
    } else {
      return Backdrop(
        currentOffice: _currentOffice,
        frontLayer: SingleChildScrollView(
          child: Column(
            children: <Widget>[_pageHeader(context), _userList()],
          ),
        ),
        backLayer: _getBackgroundView(),
        frontTitle: Text(
          "Current: ${_currentOffice.name}",
          style: TextStyle(fontSize: 16),
        ),
        backTitle: Text(
          'Choose your office',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }
}
