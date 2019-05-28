import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatelessWidget {
  Widget userList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('usergroups')
          .document('lm3VNbV4vbfWdVwhY0w5')
          .collection('users')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['name']),
                );
              }).toList(),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: Text("data"), flex: 1),
          Flexible(child: userList(), flex: 1)
        ],
      ),
    );
  }
}
