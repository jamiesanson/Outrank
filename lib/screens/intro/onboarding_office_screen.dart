import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef OfficeChosenCallback = void Function(DocumentSnapshot office);

class OnboardingOfficeScreen extends StatelessWidget {

  final OfficeChosenCallback callback; 

  OnboardingOfficeScreen(this.callback);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('offices')
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
                        onTap: () {
                          callback(document);
                        },
                      );
                    }).toList(),
                  );
              }
            },
          ));
  }

}