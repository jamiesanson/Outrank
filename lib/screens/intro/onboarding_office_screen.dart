import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef OfficeChosenCallback = void Function(DocumentSnapshot office);

class OnboardingOfficeScreen extends StatelessWidget {
  final OfficeChosenCallback callback;

  OnboardingOfficeScreen(this.callback);

  Widget _loadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _officesState(BuildContext context, List<DocumentSnapshot> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: documents.map((DocumentSnapshot document) {
        return Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            margin: EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              onTap: () {
                callback(document);
              },
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  document["name"],
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            ));
      }).toList(),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Text(error),
    );
  }

  Widget _offices(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('offices').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) _errorState(snapshot.error);
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return _loadingState();
          default:
            return _officesState(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Which office do you play at?",
            style: Theme.of(context)
                .textTheme
                .headline
                .apply(color: Color(0xFF3B71DC)),
          ),
          Text("You can change this later",
              style: Theme.of(context).textTheme.subhead)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[_header(context), _offices(context)],
      ),
    );
  }
}
