import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatelessWidget {
  // Builds the user list widget containing everyones rankings
  Widget userList() {
    return Column(children: <Widget>[
      Flexible(child: Text("This months top players"), flex: 1),
      Flexible(
          flex: 4,
          child: Scaffold(
              body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('users')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  return ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return ListTile(
                        title: Text(document['name']),
                        subtitle: Text("${document['wins']} wins this month"),
                      );
                    }).toList(),
                  );
              }
            },
          )))
    ]);
  }

  // Builds the page header widget, with illustration, start game action and
  // whether or not the table's in use
  Widget pageHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Image.network(
          "https://www.trademe.co.nz/trust-safety/media/285465/kevin-nest-trademe.png",
          width: 200,
          height: 200,
        ),
        Text("The table is free!"),
        Padding(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  color: Color(0xFF3B71DC),
                  clipBehavior: Clip.antiAlias, // Add This
                  child: MaterialButton(
                    minWidth: 300,
                    height: 48,
                    child: Text(
                      "START PLAYING",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {},
                  ))),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: pageHeader(), flex: 5),
          Flexible(child: userList(), flex: 4)
        ],
      ),
    );
  }
}
