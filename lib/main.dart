import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(Outrank());

final ThemeData outrankTheme = new ThemeData(
  brightness:     Brightness.light,
  primaryColor:   Color(0xFF3B71DC),
  accentColor:    Color(0xFFFFDA00),
);

class Outrank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outrank',
      theme: outrankTheme,
      home: OutrankHomePage(),
    );
  }
}

class OutrankHomePage extends StatefulWidget {

  @override
  OutrankHomeState createState() => OutrankHomeState();
}

class OutrankHomeState extends State<OutrankHomePage> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            title: Text('Rankings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            title: Text('Trade Me Rules'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            title: Text('My games'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('usergroups').document('lm3VNbV4vbfWdVwhY0w5').collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['name']),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
